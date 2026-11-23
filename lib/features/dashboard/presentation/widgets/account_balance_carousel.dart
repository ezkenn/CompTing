import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/widgets/app_card.dart';
import 'package:compting/core/widgets/currency_text.dart';
import 'package:compting/features/transactions/domain/account_model.dart';
import 'package:flutter/material.dart';

class AccountBalanceCarousel extends StatelessWidget {
  const AccountBalanceCarousel({
    super.key,
    required this.accounts,
  });

  final List<AccountModel> accounts;

  IconData _iconFor(AccountType type) {
    switch (type) {
      case AccountType.kas:
        return Icons.payments_outlined;
      case AccountType.bank:
        return Icons.account_balance_outlined;
      case AccountType.ewallet:
        return Icons.qr_code_2_rounded;
    }
  }

  Color _colorFor(AccountType type) {
    switch (type) {
      case AccountType.kas:
        return AppColors.accent;
      case AccountType.bank:
        return AppColors.primary;
      case AccountType.ewallet:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final account = accounts[index];
          final color = _colorFor(account.type);
          return SizedBox(
            width: 208,
            child: AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_iconFor(account.type), size: 16, color: color),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          account.type.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      CurrencyText(
                        account.balance,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
