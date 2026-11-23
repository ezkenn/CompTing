import 'dart:io';

import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/utils/currency_formatter.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/utils/validators.dart';
import 'package:compting/core/widgets/app_card.dart';
import 'package:compting/core/widgets/app_text_field.dart';
import 'package:compting/core/widgets/state_views.dart';
import 'package:compting/features/transactions/domain/category_model.dart';
import 'package:compting/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:compting/features/transactions/presentation/widgets/receipt_picker_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  const TransactionFormPage({super.key});

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedAccountId;
  String? _selectedCategoryId;
  File? _receiptFile;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih akun kas/bank dan kategori transaksi.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final ok = await ref
        .read(transactionSubmissionProvider.notifier)
        .submit(
          accountId: _selectedAccountId!,
          categoryId: _selectedCategoryId!,
          type: _type,
          amount: CurrencyFormatter.parse(_amountController.text),
          description: _descriptionController.text.trim(),
          receiptFile: _receiptFile,
        );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi diajukan! Menunggu persetujuan Manager.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      final err = ref.read(transactionSubmissionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err != null
                ? AppErrorMapper.toUserMessage(err)
                : 'Gagal mengirim transaksi. Silakan coba lagi.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final submissionState = ref.watch(transactionSubmissionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catat Transaksi Baru')),
      body: accountsAsync.when(
        loading: () => const LoadingStateView(),
        error: (e, _) => ErrorRetryView(
          message: AppErrorMapper.toUserMessage(e),
          onRetry: () => ref.invalidate(accountsProvider),
        ),
        data: (accounts) => categoriesAsync.when(
          loading: () => const LoadingStateView(),
          error: (e, _) => ErrorRetryView(
            message: AppErrorMapper.toUserMessage(e),
            onRetry: () => ref.invalidate(categoriesProvider),
          ),
          data: (allCategories) {
            final filteredCategories = allCategories
                .where((c) => c.type == _type)
                .toList();

            _selectedAccountId ??= accounts.isNotEmpty
                ? accounts.first.id
                : null;
            if (_selectedCategoryId == null ||
                !filteredCategories.any((c) => c.id == _selectedCategoryId)) {
              _selectedCategoryId = filteredCategories.isNotEmpty
                  ? filteredCategories.first.id
                  : null;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppFieldLabel('Jenis Transaksi'),
                      const SizedBox(height: 8),
                      SegmentedButton<TransactionType>(
                        segments: const [
                          ButtonSegment(
                            value: TransactionType.expense,
                            label: Text('Pengeluaran'),
                            icon: Icon(Icons.arrow_upward_rounded, size: 16),
                          ),
                          ButtonSegment(
                            value: TransactionType.income,
                            label: Text('Pemasukan'),
                            icon: Icon(Icons.arrow_downward_rounded, size: 16),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _type = selection.first;
                            _selectedCategoryId = null;
                          });
                        },
                      ),
                      const SizedBox(height: 18),

                      AppTextField(
                        label: 'Nominal (Rupiah)',
                        controller: _amountController,
                        hintText: '0',
                        prefixText: 'Rp ',
                        keyboardType: TextInputType.number,
                        inputFormatters: [RupiahInputFormatter()],
                        validator: AppValidators.positiveAmount,
                      ),
                      const SizedBox(height: 18),

                      const AppFieldLabel('Akun Kas / Bank'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAccountId,
                        isExpanded: true,
                        items: accounts
                            .map(
                              (a) => DropdownMenuItem(
                                value: a.id,
                                child: Text(
                                  '${a.name} (${a.type.label})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedAccountId = v),
                      ),
                      const SizedBox(height: 18),

                      const AppFieldLabel('Kategori Akun & Cost Center'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,
                        isExpanded: true,
                        items: filteredCategories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  c.displayLabel,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategoryId = v),
                      ),
                      const SizedBox(height: 18),

                      AppTextField(
                        label: 'Keterangan / Deskripsi',
                        controller: _descriptionController,
                        hintText: 'Contoh: Pembelian BBM pengiriman atau pelunasan invoice',
                        maxLines: 3,
                        validator: (v) =>
                            AppValidators.requiredText(v, 'Keterangan'),
                      ),
                      const SizedBox(height: 18),

                      ReceiptPickerBox(
                        onChanged: (file) => _receiptFile = file,
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: submissionState.isLoading ? null : _submit,
                        icon: submissionState.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          submissionState.isLoading
                              ? 'Mengirim Pengajuan...'
                              : 'Ajukan Transaksi',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
