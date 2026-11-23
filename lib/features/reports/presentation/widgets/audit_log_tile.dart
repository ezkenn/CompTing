import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/utils/date_formatter.dart';
import 'package:compting/core/widgets/app_card.dart';
import 'package:compting/features/reports/domain/audit_log_model.dart';
import 'package:flutter/material.dart';

class AuditLogTile extends StatelessWidget {
  const AuditLogTile({super.key, required this.log});

  final AuditLogModel log;

  Color get _actionColor {
    switch (log.action.toUpperCase()) {
      case 'INSERT':
        return AppColors.info;
      case 'DELETE':
        return AppColors.danger;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: _actionColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              log.action.toUpperCase(),
              style: TextStyle(
                color: _actionColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.actorName ?? log.actorId,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    Text(
                      log.targetTable,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  log.readableSummary,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${DateFormatter.dateTime(log.createdAt)} • ID: ${log.targetId}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
