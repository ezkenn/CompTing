import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/utils/currency_formatter.dart';
import 'package:compting/core/utils/date_formatter.dart';
import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/core/utils/validators.dart';
import 'package:compting/core/widgets/app_card.dart';
import 'package:compting/core/widgets/app_text_field.dart';
import 'package:compting/features/debts/domain/debt_model.dart';
import 'package:compting/features/debts/presentation/providers/debt_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DebtFormPage extends ConsumerStatefulWidget {
  const DebtFormPage({super.key});

  @override
  ConsumerState<DebtFormPage> createState() => _DebtFormPageState();
}

class _DebtFormPageState extends ConsumerState<DebtFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _partyController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DebtType _type = DebtType.piutang;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _reminderEnabled = true;

  @override
  void dispose() {
    _partyController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(debtActionProvider.notifier).create(
          type: _type,
          partyName: _partyController.text.trim(),
          amount: CurrencyFormatter.parse(_amountController.text),
          dueDate: _dueDate,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          reminderEnabled: _reminderEnabled,
        );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _reminderEnabled
                ? 'Tagihan disimpan & pengingat jatuh tempo dijadwalkan!'
                : 'Tagihan berhasil disimpan!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      final err = ref.read(debtActionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err != null
                ? AppErrorMapper.toUserMessage(err)
                : 'Gagal menyimpan tagihan. Silakan coba lagi.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(debtActionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Utang / Piutang')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppFieldLabel('Kategori Kewajiban / Tagihan'),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<DebtType>(
                    segments: const [
                      ButtonSegment(
                        value: DebtType.piutang,
                        label: Text('Piutang'),
                      ),
                      ButtonSegment(
                        value: DebtType.utang,
                        label: Text('Utang'),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) =>
                        setState(() => _type = s.first),
                  ),
                ),
                const SizedBox(height: 18),

                AppTextField(
                  label: _type == DebtType.piutang
                      ? 'Nama Customer / Klien'
                      : 'Nama Supplier / Vendor',
                  controller: _partyController,
                  hintText: _type == DebtType.piutang
                      ? 'Contoh: PT Global Retail Sejahtera'
                      : 'Contoh: CV Sumber Packaging Jaya',
                  prefixIcon: Icons.business_outlined,
                  validator: (v) => AppValidators.requiredText(
                    v,
                    'Nama pihak terkait',
                    maxLength: 150,
                  ),
                ),
                const SizedBox(height: 18),

                AppTextField(
                  label: 'Nominal Tagihan (Rupiah)',
                  controller: _amountController,
                  hintText: '0',
                  prefixText: 'Rp ',
                  keyboardType: TextInputType.number,
                  inputFormatters: [RupiahInputFormatter()],
                  validator: AppValidators.positiveAmount,
                ),
                const SizedBox(height: 18),

                const AppFieldLabel('Tanggal Jatuh Tempo'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDueDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today_outlined, size: 19),
                      suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                    ),
                    child: Text(
                      DateFormatter.shortDate(_dueDate),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                AppTextField(
                  label: 'Nomor Invoice / Catatan',
                  controller: _notesController,
                  hintText: 'Opsional: Nomor PO atau termin pembayaran',
                  isRequired: false,
                  maxLines: 2,
                  validator: (v) => AppValidators.optionalText(
                    v,
                    'Catatan',
                    maxLength: 500,
                  ),
                ),
                const SizedBox(height: 14),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.accent,
                  title: const Text(
                    'Pengingat Jatuh Tempo Otomatis',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Kirim notifikasi lokal pada tanggal jatuh tempo pukul 09:00',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _reminderEnabled,
                  onChanged: (v) => setState(() => _reminderEnabled = v),
                ),
                const SizedBox(height: 18),

                ElevatedButton.icon(
                  onPressed: actionState.isLoading ? null : _submit,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: Text(
                    actionState.isLoading
                        ? 'Menyimpan...'
                        : 'Simpan Tagihan',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
