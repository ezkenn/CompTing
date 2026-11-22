import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/features/debts/domain/debt_model.dart';
import 'package:compting/features/transactions/domain/transaction_model.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    this.icon,
  });

  factory StatusBadge.fromTransactionStatus(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.approved:
        return const StatusBadge(
          label: 'Disetujui',
          foregroundColor: AppColors.success,
          backgroundColor: AppColors.successSurface,
          icon: Icons.check_circle_outline_rounded,
        );
      case TransactionStatus.rejected:
        return const StatusBadge(
          label: 'Ditolak',
          foregroundColor: AppColors.danger,
          backgroundColor: AppColors.dangerSurface,
          icon: Icons.cancel_outlined,
        );
      case TransactionStatus.pending:
        return const StatusBadge(
          label: 'Pending',
          foregroundColor: AppColors.warning,
          backgroundColor: AppColors.warningSurface,
          icon: Icons.schedule_rounded,
        );
    }
  }

  factory StatusBadge.fromDebt(DebtModel debt) {
    if (debt.isPaid) {
      return const StatusBadge(
        label: 'Lunas',
        foregroundColor: AppColors.success,
        backgroundColor: AppColors.successSurface,
        icon: Icons.verified_outlined,
      );
    }
    if (debt.isOverdue) {
      return const StatusBadge(
        label: 'Terlambat',
        foregroundColor: AppColors.danger,
        backgroundColor: AppColors.dangerSurface,
        icon: Icons.warning_amber_rounded,
      );
    }
    if (debt.isDueSoon) {
      return const StatusBadge(
        label: 'Segera Jatuh Tempo',
        foregroundColor: AppColors.warning,
        backgroundColor: AppColors.warningSurface,
        icon: Icons.notifications_active_outlined,
      );
    }
    return const StatusBadge(
      label: 'Belum Lunas',
      foregroundColor: AppColors.info,
      backgroundColor: AppColors.infoSurface,
      icon: Icons.hourglass_bottom_rounded,
    );
  }

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foregroundColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
