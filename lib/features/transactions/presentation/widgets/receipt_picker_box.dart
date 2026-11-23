import 'dart:io';

import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/services/image_compression_service.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptPickerBox extends StatefulWidget {
  const ReceiptPickerBox({
    super.key,
    required this.onChanged,
  });

  final ValueChanged<File?> onChanged;

  @override
  State<ReceiptPickerBox> createState() => _ReceiptPickerBoxState();
}

class _ReceiptPickerBoxState extends State<ReceiptPickerBox> {
  final ImagePicker _picker = ImagePicker();
  final ImageCompressionService _compressor = ImageCompressionService();

  File? _selectedFile;
  int? _sizeInKb;
  bool _compressing = false;

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (picked == null) return;

      setState(() => _compressing = true);
      final previousFile = _selectedFile;
      final result = await _compressor.compressReceipt(File(picked.path));
      if (previousFile != null && previousFile.path != result.file.path) {
        await _compressor.cleanupTempFile(previousFile);
      }
      if (!mounted) {
        await _compressor.cleanupTempFile(result.file);
        return;
      }
      setState(() {
        _selectedFile = result.file;
        _sizeInKb = result.sizeInKb;
        _compressing = false;
      });
      widget.onChanged(result.file);
    } catch (e) {
      if (!mounted) return;
      setState(() => _compressing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppErrorMapper.toUserMessage(
              e,
              fallback: 'Gagal mengambil foto struk. Coba lagi.',
            ),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _clear() async {
    final oldFile = _selectedFile;
    setState(() {
      _selectedFile = null;
      _sizeInKb = null;
    });
    widget.onChanged(null);
    await _compressor.cleanupTempFile(oldFile);
  }

  @override
  void dispose() {
    _compressor.cleanupTempFile(_selectedFile);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppFieldLabel('Foto Bukti Nota / Struk', isRequired: false),
        const SizedBox(height: 8),
        if (_compressing)
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(strokeWidth: 2.5),
                SizedBox(height: 10),
                Text(
                  'Mengompres foto nota (< 300 KB)...',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        else if (_selectedFile != null)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Image.file(
                  _selectedFile!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Foto terkompres: ${_sizeInKb ?? 0} KB',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _clear,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.danger,
                        ),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.document_scanner_outlined,
                  size: 32,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lampirkan Foto Nota Fisik',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Otomatis dikompres < 300 KB agar unggah cepat',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text('Kamera'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: const Text('Galeri'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
