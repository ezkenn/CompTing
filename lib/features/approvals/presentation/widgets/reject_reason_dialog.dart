import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/utils/validators.dart';
import 'package:compting/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class RejectReasonDialog extends StatefulWidget {
  const RejectReasonDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RejectReasonDialog(),
    );
  }

  @override
  State<RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<RejectReasonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_noteController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.cancel_outlined, color: AppColors.danger),
          SizedBox(width: 8),
          Text(
            'Tolak Pengajuan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sesuai kebijakan audit, alasan penolakan wajib diisi agar Staf mengetahui hal yang harus direvisi.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Catatan Penolakan',
              controller: _noteController,
              hintText: 'Misal: Nominal nota tidak sesuai atau foto buram',
              maxLines: 3,
              validator: AppValidators.rejectionNote,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            minimumSize: const Size(120, 44),
          ),
          onPressed: _confirm,
          child: const Text('Tolak Transaksi'),
        ),
      ],
    );
  }
}
