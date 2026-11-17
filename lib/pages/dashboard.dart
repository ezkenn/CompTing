import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const CompTingApp());

// ---------------------------------------------------------------------------
// Warna & util
// ---------------------------------------------------------------------------
class AppColors {
  static const navy = Color(0xFF1B2A3A);
  static const green = Color(0xFF2E9E6B);
  static const greenLight = Color(0xFFDDF3E8);
  static const red = Color(0xFFD9534F);
  static const redLight = Color(0xFFFBE3E3);
  static const bg = Color(0xFFF6F8F7);
  static const border = Color(0xFFE6EAE8);
  static const muted = Color(0xFF6B7780);
}

/// 950000000 -> "950.000.000"
String fmtDot(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// 12850000000 -> "12,850,000,000" (gaya saldo di screenshot)
String fmtComma(int v) => fmtDot(v).replaceAll('.', ',');

// ---------------------------------------------------------------------------
// App
// ---------------------------------------------------------------------------
class CompTingApp extends StatelessWidget {
  const CompTingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CompTing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: const MainShell(),
    );
  }
}

// ---------------------------------------------------------------------------
// Role & navigasi (sesuai README: menu bawah berubah menurut peran)
// ---------------------------------------------------------------------------
enum UserRole { demo, staf, manager, finance }

class NavItem {
  final String label;
  final IconData icon;
  final Widget page;
  const NavItem(this.label, this.icon, this.page);
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  UserRole role = UserRole.demo; // demo = 4 tab seperti di screenshot
  int index = 0;

  // Antrean approval dipakai bersama oleh Beranda & halaman Approval
  final List<PendingTx> pending = [
    PendingTx('Gaji Karyawan - Staf A', 48000000),
    PendingTx('Vendor PT Maju Sejahtera', 15000000),
    PendingTx('Perlengkapan Kantor', 7000000),
  ];

  void _approve(PendingTx tx) {
    setState(() => pending.remove(tx));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${tx.title} disetujui')),
    );
  }

  Future<void> _reject(PendingTx tx) async {
    final note = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak transaksi'),
        content: TextField(
          controller: note,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Tulis alasan penolakan (wajib)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (note.text.trim().isEmpty) return;
              Navigator.pop(ctx, note.text.trim());
            },
            child: const Text('Tolak',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (reason != null) {
      setState(() => pending.remove(tx));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tx.title} ditolak: $reason')),
        );
      }
    }
  }

  List<NavItem> get items {
    final home = NavItem(
      'Beranda',
      Icons.dashboard_rounded,
      BerandaPage(
        pending: pending,
        onApprove: _approve,
        onReject: _reject,
      ),
    );
    const transaksi = NavItem('Transaksi', Icons.swap_horiz_rounded,
        PlaceholderPage('Form input & riwayat transaksi'));
    const utang = NavItem('Utang/Piutang', Icons.receipt_long_rounded,
        PlaceholderPage('Daftar tagihan & pelunasan'));
    final approval = NavItem(
      'Approval',
      Icons.verified_outlined,
      ApprovalPage(pending: pending, onApprove: _approve, onReject: _reject),
    );
    const laporan = NavItem('Laporan', Icons.bar_chart_rounded,
        PlaceholderPage('Laba rugi, arus kas, ekspor PDF & Audit Log'));

    switch (role) {
      case UserRole.staf:
        return [home, transaksi, utang];
      case UserRole.manager:
        return [home, approval];
      case UserRole.finance:
        return [home, const NavItem('Laporan & Log', Icons.bar_chart_rounded,
            PlaceholderPage('Laba rugi, arus kas, ekspor PDF & Audit Log'))];
      case UserRole.demo:
        return [home, transaksi, approval, laporan];
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = items;
    if (index >= nav.length) index = 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Pemilih peran (hanya untuk demo/pengujian)
            Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<UserRole>(
                tooltip: 'Ganti peran',
                icon: const Icon(Icons.manage_accounts_outlined,
                    color: AppColors.muted),
                onSelected: (r) => setState(() {
                  role = r;
                  index = 0;
                }),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: UserRole.demo, child: Text('Semua tab (demo)')),
                  PopupMenuItem(value: UserRole.staf, child: Text('Staf')),
                  PopupMenuItem(
                      value: UserRole.manager, child: Text('Manager')),
                  PopupMenuItem(
                      value: UserRole.finance, child: Text('Finance')),
                ],
              ),
            ),
            Expanded(child: nav[index].page),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        items: nav,
        current: index,
        onTap: (i) => setState(() => index = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final List<NavItem> items;
  final int current;
  final ValueChanged<int> onTap;
  const _BottomNav(
      {required this.items, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < items.length; i++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 6),
                        decoration: BoxDecoration(
                          color: i == current
                              ? AppColors.greenLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(items[i].icon,
                            color: i == current
                                ? AppColors.navy
                                : AppColors.muted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: i == current
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: i == current
                              ? AppColors.navy
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------
class PendingTx {
  final String title;
  final int amount;
  PendingTx(this.title, this.amount);
}

// ---------------------------------------------------------------------------
// Beranda
// ---------------------------------------------------------------------------
class BerandaPage extends StatefulWidget {
  final List<PendingTx> pending;
  final void Function(PendingTx) onApprove;
  final void Function(PendingTx) onReject;
  const BerandaPage({
    super.key,
    required this.pending,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int filter = 0;
  static const filters = ['Bulan Ini', '3 Bulan', 'Tahun Ini', 'Custom'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            children: [
              const Text('Beranda',
                  style:
                      TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              _FilterChips(
                selected: filter,
                labels: filters,
                onSelect: (i) => setState(() => filter = i),
              ),
              const SizedBox(height: 16),
              const _SaldoCard(),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.south_west_rounded,
                      color: AppColors.green,
                      bg: AppColors.greenLight,
                      label: 'Total Piutang',
                      value: 'Rp 950,000,000',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.north_east_rounded,
                      color: AppColors.red,
                      bg: AppColors.redLight,
                      label: 'Total Utang',
                      value: 'Rp 1,120,000,000',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Quick Actions',
                  style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              const _QuickActions(),
              const SizedBox(height: 16),
              _ApprovalListCard(
                pending: widget.pending,
                onApprove: widget.onApprove,
                onReject: widget.onReject,
              ),
              const SizedBox(height: 16),
              const _ChartCard(),
              const SizedBox(height: 16),
              const _RincianRow(),
            ],
          ),
        ),
        // Tombol ekspor tetap di bawah (seperti screenshot)
        Container(
          color: AppColors.bg,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mengekspor laporan ke PDF...')),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Ekspor Laporan PDF',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  final int selected;
  final List<String> labels;
  final ValueChanged<int> onSelect;
  const _FilterChips(
      {required this.selected, required this.labels, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: i == selected ? AppColors.navy : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: i == selected
                            ? AppColors.navy
                            : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      if (labels[i] == 'Custom') ...[
                        const Icon(Icons.calendar_today_outlined,
                            size: 16, color: AppColors.muted),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: i == selected
                              ? Colors.white
                              : AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu saldo kas & bank
// ---------------------------------------------------------------------------
class _SaldoCard extends StatelessWidget {
  const _SaldoCard();

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Bank BCA Operasional', 8400000000),
      ('Bank Mandiri Deposito', 3100000000),
      ('Kas Utama', 1350000000),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Saldo Kas & Bank',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Rp ${fmtComma(12850000000)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.green.withAlpha((0.25 * 255).round()),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up, color: Color(0xFF5BD79E), size: 16),
                SizedBox(width: 6),
                Text('+3.2% vs. minggu lalu',
                    style: TextStyle(color: Color(0xFF5BD79E), fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(r.$1,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14)),
                  ),
                  SizedBox(
                    width: 60,
                    height: 18,
                    child: CustomPaint(painter: _SparkPainter()),
                  ),
                  const SizedBox(width: 12),
                  Text('Rp ${fmtComma(r.$2)}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const pts = [0.7, 0.55, 0.65, 0.4, 0.5, 0.25, 0.3, 0.1];
    final path = Path();
    for (var i = 0; i < pts.length; i++) {
      final x = size.width * i / (pts.length - 1);
      final y = size.height * pts[i];
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = Colors.white24);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final String label;
  final String value;
  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.bg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBox(icon: icon, color: color, bg: bg),
          const SizedBox(height: 12),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.navy)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Actions
// ---------------------------------------------------------------------------
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.download_rounded, 'Entri\nPemasukan'),
      (Icons.arrow_circle_down_outlined, 'Entri\nPengeluaran'),
      (Icons.description_outlined, 'Kirim\nInvoice'),
      (Icons.note_add_outlined, 'Catat\nUtang'),
    ];
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        actions[i].$2.replaceAll('\n', ' '))),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(actions[i].$1, size: 26, color: AppColors.navy),
                    const SizedBox(height: 8),
                    Text(actions[i].$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, height: 1.25)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Approval list
// ---------------------------------------------------------------------------
class _ApprovalListCard extends StatelessWidget {
  final List<PendingTx> pending;
  final void Function(PendingTx) onApprove;
  final void Function(PendingTx) onReject;
  const _ApprovalListCard({
    required this.pending,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Approval List (Menunggu Otorisasi)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (pending.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Tidak ada transaksi yang menunggu persetujuan.',
                  style: TextStyle(color: AppColors.muted)),
            ),
          for (var i = 0; i < pending.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.border),
            _ApprovalTile(
              tx: pending[i],
              onApprove: () => onApprove(pending[i]),
              onReject: () => onReject(pending[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApprovalTile extends StatelessWidget {
  final PendingTx tx;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _ApprovalTile(
      {required this.tx, required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('Rp ${fmtDot(tx.amount)}',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          _PillButton(
            label: 'Approve',
            color: AppColors.green,
            bg: AppColors.greenLight,
            onTap: onApprove,
          ),
          const SizedBox(width: 8),
          _PillButton(
            label: 'Reject',
            color: AppColors.red,
            bg: AppColors.redLight,
            icon: Icons.chat_bubble_outline,
            onTap: onReject,
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final IconData? icon;
  final VoidCallback onTap;
  const _PillButton({
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha((0.6 * 255).round())),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w500,
                    fontSize: 13)),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: AppColors.navy),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grafik Pemasukan vs Pengeluaran (tanpa package eksternal)
// ---------------------------------------------------------------------------
class _ChartCard extends StatelessWidget {
  const _ChartCard();

  static const months = ['Agustus', 'September', 'Oktober', 'November'];
  static const income = [8000, 7210, 9000, 10600];
  static const expense = [3500, 4600, 4800, 4200];
  static const highlight = {2, 3}; // bar yang menampilkan tooltip

  @override
  Widget build(BuildContext context) {
    const maxH = 190.0;
    const maxV = 10600;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Perbandingan Pemasukan vs. Pengeluaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          const Center(
            child: Wrap(
              spacing: 18,
              runSpacing: 6,
              children: [
                _LegendDot(color: AppColors.green, label: 'Pemasukan'),
                _LegendDot(color: AppColors.navy, label: 'Pengeluaran'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Lebar bar dihitung dari lebar yang tersedia, sehingga tidak
          // pernah melebihi layar (tidak ada "RIGHT OVERFLOWED").
          LayoutBuilder(
            builder: (context, constraints) {
              final slot = constraints.maxWidth / months.length;
              final barW = ((slot - 8) / 2).clamp(8.0, 28.0);
              return SizedBox(
                height: maxH + 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < months.length; i++)
                      SizedBox(
                        width: slot,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _Bar(
                                  value: income[i],
                                  width: barW,
                                  height: income[i] / maxV * maxH,
                                  color: AppColors.green,
                                  showTip: highlight.contains(i),
                                ),
                                const SizedBox(width: 2),
                                _Bar(
                                  value: expense[i],
                                  width: barW,
                                  height: expense[i] / maxV * maxH,
                                  color: AppColors.navy,
                                  showTip: false,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: slot,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(months[i],
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final int value;
  final double width;
  final double height;
  final Color color;
  final bool showTip;
  const _Bar({
    required this.value,
    required this.width,
    required this.height,
    required this.color,
    required this.showTip,
  });

  @override
  Widget build(BuildContext context) {
    final label = fmtDot(value);
    // Label dikecilkan otomatis (scaleDown) agar selalu muat di lebar bar.
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: width + 2,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              margin: const EdgeInsets.only(bottom: 3),
              padding: showTip
                  ? const EdgeInsets.symmetric(horizontal: 5, vertical: 2)
                  : EdgeInsets.zero,
              decoration: showTip
                  ? BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(5),
                    )
                  : null,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: showTip ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rincian Pendapatan & Rincian Beban
// ---------------------------------------------------------------------------
class _RincianRow extends StatelessWidget {
  const _RincianRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _RincianCard(
            icon: Icons.arrow_upward_rounded,
            color: AppColors.green,
            bg: AppColors.greenLight,
            title: 'Rincian Pendapatan',
            rows: [
              (Icons.storefront_outlined, 'Penjualan Produk', 7200000000),
              (Icons.volunteer_activism_outlined, 'Jasa Konsultasi',
                  4100000000),
              (Icons.pie_chart_outline, 'Dividen', 1050000000),
              (Icons.format_list_bulleted, 'Lain-lain', 500000000),
            ],
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _RincianCard(
            icon: Icons.arrow_downward_rounded,
            color: AppColors.red,
            bg: AppColors.redLight,
            title: 'Rincian Beban',
            rows: [
              (Icons.work_outline, 'Gaji Karyawan', 1100000000),
              (Icons.inventory_2_outlined, 'HPP Barang', 4800000000),
              (Icons.business_center_outlined, 'Operasional Kantor',
                  3500000000),
              (Icons.sell_outlined, 'Pemasaran', 720000000),
            ],
          ),
        ),
      ],
    );
  }
}

class _RincianCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final List<(IconData, String, int)> rows;
  const _RincianCard({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBox(icon: icon, color: color, bg: bg),
          const SizedBox(height: 10),
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(r.$1, size: 20, color: AppColors.navy),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.$2, style: const TextStyle(fontSize: 13)),
                        Text('Rp ${fmtDot(r.$3)}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
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

// ---------------------------------------------------------------------------
// Halaman Approval (peran Manager)
// ---------------------------------------------------------------------------
class ApprovalPage extends StatelessWidget {
  final List<PendingTx> pending;
  final void Function(PendingTx) onApprove;
  final void Function(PendingTx) onReject;
  const ApprovalPage({
    super.key,
    required this.pending,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: [
        const Text('Approval',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        _ApprovalListCard(
            pending: pending, onApprove: onApprove, onReject: onReject),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Halaman sementara untuk tab yang belum dibuat
// ---------------------------------------------------------------------------
class PlaceholderPage extends StatelessWidget {
  final String text;
  const PlaceholderPage(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted)),
    );
  }
}

// ---------------------------------------------------------------------------
// Komponen dasar
// ---------------------------------------------------------------------------
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  const _IconBox({required this.icon, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 20, color: color),
    );
  }
}