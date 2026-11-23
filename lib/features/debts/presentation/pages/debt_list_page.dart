import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/router/route_paths.dart';
import 'package:compting/core/utils/date_formatter.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/widgets/app_card.dart';
import 'package:compting/core/widgets/currency_text.dart';
import 'package:compting/core/widgets/state_views.dart';
import 'package:compting/core/widgets/status_badge.dart';
import 'package:compting/features/debts/domain/debt_model.dart';
import 'package:compting/features/debts/presentation/providers/debt_provider.dart';
import 'package:compting/features/debts/presentation/widgets/settle_debt_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DebtListPage extends ConsumerStatefulWidget {
  const DebtListPage({super.key, this.standalone = false});

  final bool standalone;

  @override
  ConsumerState<DebtListPage> createState() => _DebtListPageState();
}

class _DebtListPageState extends ConsumerState<DebtListPage> {
  DebtType _activeType = DebtType.piutang;
  bool _showPaid = false;

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(debtsProvider);

    final body = Column(
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<DebtType>(
                  segments: const [
                    ButtonSegment(
                      value: DebtType.piutang,
                      label: Text('Piutang (Customer)'),
                      icon: Icon(Icons.call_received_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: DebtType.utang,
                      label: Text('Utang (Supplier)'),
                      icon: Icon(Icons.call_made_rounded, size: 16),
                    ),
                  ],
                  selected: {_activeType},
                  onSelectionChanged: (s) =>
                      setState(() => _activeType = s.first),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Belum Lunas'),
                    selected: !_showPaid,
                    onSelected: (_) => setState(() => _showPaid = false),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Sudah Lunas'),
                    selected: _showPaid,
                    onSelected: (_) => setState(() => _showPaid = true),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: debtsAsync.when(
            loading: () => const LoadingStateView(),
            error: (e, _) => ErrorRetryView(
              message: AppErrorMapper.toUserMessage(e),
              onRetry: () => ref.invalidate(debtsProvider),
            ),
            data: (all) {
              final filtered = all.where((d) {
                if (d.type != _activeType) return false;
                return _showPaid ? d.isPaid : !d.isPaid;
              }).toList();

              final totalAmount = filtered.fold<double>(
                0,
                (sum, d) => sum + d.amount,
              );

              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(debtsProvider),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 92),
                  children: [
                    AppCard(
                      backgroundColor: _activeType == DebtType.piutang
                          ? AppColors.infoSurface
                          : AppColors.warningSurface,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total ${_activeType == DebtType.piutang ? 'Piutang' : 'Utang'} (${_showPaid ? 'Lunas' : 'Belum Lunas'})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              CurrencyText(
                                totalAmount,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${filtered.length} tagihan',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      EmptyStateView(
                        icon: Icons.request_quote_outlined,
                        title: 'Daftar Kosong',
                        subtitle:
                            'Belum ada data ${_activeType.label.toLowerCase()} pada filter ini.',
                      )
                    else
                      ...filtered.map(
                        (debt) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _DebtCard(
                            debt: debt,
                            onSettle: debt.isPaid
                                ? null
                                : () => SettleDebtSheet.show(
                                      context,
                                      debt: debt,
                                    ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: widget.standalone
          ? AppBar(title: const Text('Utang & Piutang'))
          : null,
      backgroundColor: AppColors.background,
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.debtNew),
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('Tambah Tagihan'),
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({
    required this.debt,
    this.onSettle,
  });

  final DebtModel debt;
  final VoidCallback? onSettle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  debt.partyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
              ),
              StatusBadge.fromDebt(debt),
            ],
          ),
          if ((debt.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              debt.notes!,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CurrencyText(
                      debt.amount,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.event_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${DateFormatter.shortDate(debt.dueDate)} • ${DateFormatter.dueRelative(debt.dueDate)}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: debt.isOverdue
                                ? AppColors.danger
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onSettle != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size(116, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: onSettle,
                  child: const Text(
                    'Lunasi',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
