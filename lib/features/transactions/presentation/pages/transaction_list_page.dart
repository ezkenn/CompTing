import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/router/route_paths.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/widgets/state_views.dart';
import 'package:compting/features/transactions/domain/category_model.dart';
import 'package:compting/features/transactions/domain/transaction_model.dart';
import 'package:compting/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:compting/features/transactions/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TransactionListPage extends ConsumerStatefulWidget {
  const TransactionListPage({super.key});

  @override
  ConsumerState<TransactionListPage> createState() =>
      _TransactionListPageState();
}

class _TransactionListPageState extends ConsumerState<TransactionListPage> {
  TransactionStatus? _statusFilter;
  TransactionType? _typeFilter;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  decoration: const InputDecoration(
                    hintText: 'Cari deskripsi atau kategori...',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        selected: _statusFilter == null,
                        onSelected: () => setState(() => _statusFilter = null),
                      ),
                      const SizedBox(width: 8),
                      ...TransactionStatus.values.map(
                        (status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: status.label,
                            selected: _statusFilter == status,
                            onSelected: () =>
                                setState(() => _statusFilter = status),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      _FilterChip(
                        label: _typeFilter == null
                            ? 'Semua Tipe'
                            : _typeFilter!.label,
                        selected: _typeFilter != null,
                        onSelected: () {
                          setState(() {
                            if (_typeFilter == null) {
                              _typeFilter = TransactionType.income;
                            } else if (_typeFilter == TransactionType.income) {
                              _typeFilter = TransactionType.expense;
                            } else {
                              _typeFilter = null;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: transactionsAsync.when(
              loading: () => const LoadingStateView(),
              error: (e, _) => ErrorRetryView(
                message: AppErrorMapper.toUserMessage(e),
                onRetry: () => ref.invalidate(transactionsProvider),
              ),
              data: (items) {
                final filtered = items.where((t) {
                  if (_statusFilter != null && t.status != _statusFilter) {
                    return false;
                  }
                  if (_typeFilter != null && t.type != _typeFilter) {
                    return false;
                  }
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    final matchesDesc =
                        t.description.toLowerCase().contains(q);
                    final matchesCat =
                        (t.categoryName ?? '').toLowerCase().contains(q);
                    if (!matchesDesc && !matchesCat) return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.receipt_long_outlined,
                    title: 'Tidak Ada Transaksi Cocok',
                    subtitle:
                        'Ubah filter pencarian atau catat transaksi baru Anda.',
                    actionLabel: 'Catat Transaksi',
                    onAction: () => context.push(RoutePaths.transactionNew),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(transactionsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 92),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final trx = filtered[index];
                      return TransactionTile(
                        transaction: trx,
                        onTap: () => context.push(
                          RoutePaths.transactionDetail,
                          extra: trx,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.transactionNew),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Catat Transaksi'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textSecondary,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.borderStrong,
      ),
      showCheckmark: false,
      onSelected: (_) => onSelected(),
    );
  }
}
