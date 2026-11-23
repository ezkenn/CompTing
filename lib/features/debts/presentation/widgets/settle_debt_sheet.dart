import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/widgets/app_text_field.dart';
import 'package:compting/core/widgets/currency_text.dart';
import 'package:compting/features/debts/domain/debt_model.dart';
import 'package:compting/features/debts/presentation/providers/debt_provider.dart';
import 'package:compting/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettleDebtSheet extends ConsumerStatefulWidget {
  const SettleDebtSheet({super.key, required this.debt});

  final DebtModel debt;

  static Future<void> show(BuildContext context, {required DebtModel debt}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SettleDebtSheet(debt: debt),
    );
  }

  @override
  ConsumerState<SettleDebtSheet> createState() => _SettleDebtSheetState();
}

class _SettleDebtSheetState extends ConsumerState<SettleDebtSheet> {
  String? _selectedAccountId;

  Future<void> _confirm() async {
    if (_selectedAccountId == null) return;
    final ok = await ref.read(debtActionProvider.notifier).settle(
          debt: widget.debt,
          accountId: _selectedAccountId!,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.debt.partyName} ditandai Lunas & transaksi kas otomatis tercatat!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final err = ref.read(debtActionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err != null
                ? AppErrorMapper.toUserMessage(err)
                : 'Gagal memproses pelunasan. Silakan coba lagi.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final actionState = ref.watch(debtActionProvider);
    final isPiutang = widget.debt.type == DebtType.piutang;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: accountsAsync.when(
          loading: () => const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text(AppErrorMapper.toUserMessage(e)),
          data: (accounts) {
            _selectedAccountId ??=
                accounts.isNotEmpty ? accounts.first.id : null;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderStrong,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isPiutang ? 'Konfirmasi Terima Pelunasan' : 'Bayar Utang Supplier',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.debt.partyName} • Pelunasan akan otomatis membuat transaksi ${isPiutang ? 'Kas Masuk' : 'Kas Keluar'}.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nominal Pelunasan',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      CurrencyText(
                        widget.debt.amount,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isPiutang
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppFieldLabel(
                  isPiutang ? 'Masuk ke Akun Kas/Bank' : 'Bayar dari Akun Kas/Bank',
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedAccountId,
                  items: accounts
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedAccountId = v),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  onPressed: actionState.isLoading ? null : _confirm,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: Text(
                    actionState.isLoading
                        ? 'Memproses Pelunasan...'
                        : 'Tandai Lunas Sekarang',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
