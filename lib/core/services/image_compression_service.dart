import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class CompressedImageResult {
  const CompressedImageResult({
    required this.file,
    required this.bytes,
    required this.sizeInKb,
  });

  final File file;
  final Uint8List bytes;
  final int sizeInKb;
}

class ImageCompressionService {
  static const int maxTargetBytes = 300 * 1024; // 300 KB

  /// Mengompres foto struk hingga di bawah 300 KB sebelum diunggah ke Supabase Storage.
  Future<CompressedImageResult> compressReceipt(File sourceFile) async {
    final originalBytes = await sourceFile.readAsBytes();
    if (originalBytes.lengthInBytes <= maxTargetBytes) {
      return CompressedImageResult(
        file: sourceFile,
        bytes: originalBytes,
        sizeInKb: (originalBytes.lengthInBytes / 1024).ceil(),
      );
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';

      Uint8List? bestBytes;
      for (final quality in const [80, 65, 50, 35, 25]) {
        final compressed = await FlutterImageCompress.compressWithFile(
          sourceFile.absolute.path,
          minWidth: 1280,
          minHeight: 1280,
          quality: quality,
          format: CompressFormat.jpeg,
        );
        if (compressed == null) continue;
        bestBytes = compressed;
        if (compressed.lengthInBytes <= maxTargetBytes) {
          break;
        }
      }

      if (bestBytes != null) {
        final outFile = File(targetPath);
        await outFile.writeAsBytes(bestBytes, flush: true);
        return CompressedImageResult(
          file: outFile,
          bytes: bestBytes,
          sizeInKb: (bestBytes.lengthInBytes / 1024).ceil(),
        );
      }
    } catch (e) {
      debugPrint('Kompresi gambar gagal, menggunakan file asli: $e');
    }

    return CompressedImageResult(
      file: sourceFile,
      bytes: originalBytes,
      sizeInKb: (originalBytes.lengthInBytes / 1024).ceil(),
    );
  }

  /// Menghapus file temporer hasil kompresi dari direktori temp secara aman.
  Future<void> cleanupTempFile(File? file) async {
    if (file == null) return;
    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;
      if (file.path.startsWith(tempPath) && await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Abaikan error pembersihan file temporer
    }
  }
}
