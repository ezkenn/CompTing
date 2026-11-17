import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ===== COLOR PALETTE =====
const kPrimary = Color(0xFF1E293B);
const kBackground = Color(0xFFF8F9FA);
const kSecondary = Color(0xFF10B981);
const kAccent = Color(0xFF1E3A8A);
const kDanger = Color(0xFFEF4444);
const kMuted = Color(0xFF64748B);

void main() => runApp(const ReportsApp());

class ReportsApp extends StatelessWidget {
  const ReportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CompTing Reports',
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: kBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          primary: kPrimary,
          secondary: kSecondary,
        ),
      ),
      home: const ReportsPage(),
    );
  }
}

// ===== HELPERS & DUMMY DATA =====
String rp(num v) {
  final s = v.abs().round().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}Rp $b';
}

const _months = ['Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov'];
const _income = [82e6, 95e6, 88e6, 110e6, 104e6, 126e6];
const _expense = [64e6, 70e6, 73e6, 81e6, 79e6, 92e6];

const _periods = ['Bulan Ini', '3 Bulan', 'Tahun Ini', 'Custom'];
const _tabs = ['Laba Rugi', 'Arus Kas', 'Piutang', 'Utang'];

class _Item {
  final String name, note;
  final double amount;
  final int status; // 0 = aman, 1 = segera, 2 = terlambat
  const _Item(this.name, this.note, this.amount, this.status);
}

const _piutang = [
  _Item('PT Sinar Abadi', 'INV-0231 • jatuh tempo 5 hari lagi', 24500000, 1),
  _Item('CV Maju Jaya', 'INV-0224 • terlambat 8 hari', 12000000, 2),
  _Item('Toko Berkah', 'INV-0240 • jatuh tempo 21 hari lagi', 7250000, 0),
  _Item('PT Nusa Retail', 'INV-0219 • terlambat 15 hari', 18900000, 2),
];

const _utang = [
  _Item(
    'Supplier Kertas Prima',
    'PO-118 • jatuh tempo 3 hari lagi',
    15400000,
    1,
  ),
  _Item('PT Logistik Cepat', 'PO-121 • jatuh tempo 18 hari lagi', 9800000, 0),
  _Item('CV Teknik Mandiri', 'PO-109 • terlambat 4 hari', 6300000, 2),
];

// ===== PAGE =====
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _period = 0;
  int _tab = 0;
  int _nav = 3;

  double get _totalIn => _income.last;
  double get _totalOut => _expense.last;

  void _showExport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ekspor Laporan ${_tabs[_tab]}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kPrimary,
              ),
            ),
            Text(
              'Periode: ${_periods[_period]}',
              style: const TextStyle(fontSize: 12, color: kMuted),
            ),
            const SizedBox(height: 12),
            _exportTile(
              Icons.picture_as_pdf_outlined,
              'PDF',
              'Cocok untuk dicetak & dibagikan',
            ),
            _exportTile(
              Icons.table_chart_outlined,
              'Excel (.xlsx)',
              'Untuk diolah lebih lanjut',
            ),
            _exportTile(
              Icons.share_outlined,
              'Bagikan via aplikasi lain',
              'WhatsApp, email, dll.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _exportTile(IconData icon, String title, String sub) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kSecondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: kSecondary),
    ),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
    subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
    onTap: () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menyiapkan $title...'),
          backgroundColor: kPrimary,
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Laporan',
          style: TextStyle(fontWeight: FontWeight.w800, color: kPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _showExport,
            icon: const Icon(Icons.file_download_outlined, color: kPrimary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          _periodChips(),
          const SizedBox(height: 16),
          _heroCard(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _miniCard(
                  'Pemasukan',
                  _totalIn,
                  Icons.south_west_rounded,
                  kSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniCard(
                  'Pengeluaran',
                  _totalOut,
                  Icons.north_east_rounded,
                  kDanger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _tabSelector(),
          const SizedBox(height: 16),
          if (_tab == 0) ..._labaRugi(),
          if (_tab == 1) ..._arusKas(),
          if (_tab == 2) ..._agingList(_piutang, 'Total Piutang', kAccent),
          if (_tab == 3) ..._agingList(_utang, 'Total Utang', kDanger),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _showExport,
              icon: const Icon(
                Icons.picture_as_pdf_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Ekspor Laporan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: kSecondary.withOpacity(0.15),
        selectedIndex: _nav,
        onDestinationSelected: (i) => setState(() => _nav = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_rounded),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_outlined),
            label: 'Approval',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }

  // ----- period filter -----
  Widget _periodChips() => SizedBox(
    height: 38,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _periods.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final sel = i == _period;
        return ChoiceChip(
          label: Text(_periods[i]),
          selected: sel,
          showCheckmark: false,
          avatar: i == 3
              ? Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: sel ? Colors.white : kMuted,
                )
              : null,
          labelStyle: TextStyle(
            color: sel ? Colors.white : kPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          selectedColor: kPrimary,
          backgroundColor: Colors.white,
          side: BorderSide(color: sel ? kPrimary : Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onSelected: (_) async {
            if (i == 3) {
              await showDateRangePicker(
                context: context,
                firstDate: DateTime(2024),
                lastDate: DateTime(2027),
              );
            }
            setState(() => _period = i);
          },
        );
      },
    ),
  );

  // ----- summary -----
  Widget _heroCard() {
    final net = _totalIn - _totalOut;
    final margin = net / _totalIn * 100;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laba Bersih',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            rp(net),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: kSecondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: kSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+12,4% vs bulan lalu',
                      style: const TextStyle(
                        color: kSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Margin ${margin.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniCard(String label, double v, IconData icon, Color c) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDeco(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: c.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: c, size: 18),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: kMuted, fontSize: 12)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            rp(v),
            style: const TextStyle(
              color: kPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  BoxDecoration _cardDeco() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey.shade200),
  );

  // ----- tab selector -----
  Widget _tabSelector() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: List.generate(_tabs.length, (i) {
        final sel = i == _tab;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                _tabs[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                  color: sel ? kAccent : kMuted,
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );

  // ----- tab: laba rugi -----
  List<Widget> _labaRugi() => [
    _sectionCard(
      'Pemasukan vs Pengeluaran',
      _barChart(_income, _expense, legend: true),
    ),
    const SizedBox(height: 12),
    _sectionCard(
      'Rincian Pendapatan',
      Column(
        children: [
          _breakdownRow('Penjualan', 118e6, 126e6, kSecondary),
          _breakdownRow('Jasa & lainnya', 8e6, 126e6, kSecondary),
        ],
      ),
    ),
    const SizedBox(height: 12),
    _sectionCard(
      'Rincian Beban',
      Column(
        children: [
          _breakdownRow('Gaji karyawan', 48e6, 92e6, kDanger),
          _breakdownRow('Operasional', 22e6, 92e6, kDanger),
          _breakdownRow('Vendor', 15e6, 92e6, kDanger),
          _breakdownRow('Lainnya', 7e6, 92e6, kDanger),
        ],
      ),
    ),
  ];

  // ----- tab: arus kas -----
  List<Widget> _arusKas() {
    final net = List.generate(_months.length, (i) => _income[i] - _expense[i]);
    return [
      _sectionCard(
        'Arus Kas Bersih (6 Bulan)',
        _barChart(net, null, legend: false),
      ),
      const SizedBox(height: 12),
      _sectionCard(
        'Saldo Kas & Bank',
        Column(
          children: [
            _balanceRow(Icons.payments_outlined, 'Kas Tunai', 18500000),
            _balanceRow(
              Icons.account_balance_outlined,
              'Bank BCA ••4821',
              142300000,
            ),
            _balanceRow(
              Icons.account_balance_outlined,
              'Bank Mandiri ••9917',
              56800000,
            ),
            _balanceRow(
              Icons.account_balance_wallet_outlined,
              'E-Wallet',
              6400000,
            ),
          ],
        ),
      ),
    ];
  }

  Widget _balanceRow(IconData i, String name, double v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(i, color: kAccent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 13, color: kPrimary),
          ),
        ),
        Text(
          rp(v),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: kPrimary,
          ),
        ),
      ],
    ),
  );

  // ----- tab: piutang / utang -----
  List<Widget> _agingList(List<_Item> items, String title, Color c) {
    final total = items.fold<double>(0, (s, e) => s + e.amount);
    final late = items
        .where((e) => e.status == 2)
        .fold<double>(0, (s, e) => s + e.amount);
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: kMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rp(total),
                    style: TextStyle(
                      color: c,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 36, color: Colors.grey.shade200),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Terlambat',
                    style: TextStyle(color: kMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rp(late),
                    style: const TextStyle(
                      color: kDanger,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ...items.map((e) {
        final col = [kSecondary, Colors.orange, kDanger][e.status];
        final lbl = ['Aman', 'Segera', 'Terlambat'][e.status];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: _cardDeco(),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: kPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      e.note,
                      style: const TextStyle(fontSize: 11, color: kMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rp(e.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: kPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: col.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      lbl,
                      style: TextStyle(
                        color: col,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    ];
  }

  // ----- reusable pieces -----
  Widget _sectionCard(String title, Widget child) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDeco(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: kPrimary,
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );

  Widget _breakdownRow(String label, double v, double total, Color c) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 13, color: kPrimary),
                  ),
                ),
                Text(
                  rp(v),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: v / total,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                color: c,
              ),
            ),
          ],
        ),
      );

  // simple bar chart without extra packages
  Widget _barChart(List<double> a, List<double>? b, {required bool legend}) {
    final all = [...a, ...?b].map((e) => e.abs());
    final maxV = all.reduce((x, y) => x > y ? x : y);
    const h = 130.0;
    return Column(
      children: [
        if (legend)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                _dot(kSecondary, 'Pemasukan'),
                const SizedBox(width: 16),
                _dot(kAccent, 'Pengeluaran'),
              ],
            ),
          ),
        SizedBox(
          height: h + 22,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_months.length, (i) {
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _bar(a[i] / maxV * h, kSecondary),
                        if (b != null) ...[
                          const SizedBox(width: 3),
                          _bar(b[i] / maxV * h, kAccent),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _months[i],
                      style: const TextStyle(fontSize: 11, color: kMuted),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _bar(double height, Color c) => Container(
    width: 10,
    height: height,
    decoration: BoxDecoration(
      color: c,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
    ),
  );

  Widget _dot(Color c, String t) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(t, style: const TextStyle(fontSize: 11, color: kMuted)),
    ],
  );
}
