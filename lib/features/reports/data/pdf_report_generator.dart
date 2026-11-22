import 'dart:typed_data';

import 'package:compting/core/utils/currency_formatter.dart';
import 'package:compting/core/utils/date_formatter.dart';
import 'package:compting/features/reports/domain/financial_report_models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfReportGenerator {
  static Future<Uint8List> buildProfitLossPdf({
    required ProfitLossReport report,
    required String generatedBy,
  }) async {
    final doc = pw.Document();
    final navy = PdfColor.fromHex('#1E293B');
    final brandBlue = PdfColor.fromHex('#263C7B');
    final accentGreen = PdfColor.fromHex('#00A980');
    final borderGrey = PdfColor.fromHex('#E2E8F0');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          _buildHeader(
            title: 'LAPORAN LABA RUGI (PROFIT & LOSS)',
            period:
                '${DateFormatter.shortDate(report.startDate)} - ${DateFormatter.shortDate(report.endDate)}',
            brandBlue: brandBlue,
            navy: navy,
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              _summaryBox(
                label: 'Total Pendapatan',
                value: CurrencyFormatter.format(report.totalIncome),
                accent: accentGreen,
                border: borderGrey,
              ),
              pw.SizedBox(width: 10),
              _summaryBox(
                label: 'Total Beban',
                value: CurrencyFormatter.format(report.totalExpense),
                accent: PdfColor.fromHex('#DC2626'),
                border: borderGrey,
              ),
              pw.SizedBox(width: 10),
              _summaryBox(
                label: 'Laba / Rugi Bersih',
                value: CurrencyFormatter.format(report.netProfit),
                accent: brandBlue,
                border: borderGrey,
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Rincian Pendapatan (Income)',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: navy,
            ),
          ),
          pw.SizedBox(height: 6),
          _breakdownTable(report.incomeBreakdown, borderGrey),
          pw.SizedBox(height: 18),
          pw.Text(
            'Rincian Pengeluaran (Expense)',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: navy,
            ),
          ),
          pw.SizedBox(height: 6),
          _breakdownTable(report.expenseBreakdown, borderGrey),
          pw.SizedBox(height: 24),
          _buildFooter(generatedBy: generatedBy),
        ],
      ),
    );

    return doc.save();
  }

  static Future<Uint8List> buildCashFlowPdf({
    required CashFlowReport report,
    required String generatedBy,
  }) async {
    final doc = pw.Document();
    final navy = PdfColor.fromHex('#1E293B');
    final brandBlue = PdfColor.fromHex('#263C7B');
    final accentGreen = PdfColor.fromHex('#00A980');
    final borderGrey = PdfColor.fromHex('#E2E8F0');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          _buildHeader(
            title: 'LAPORAN ARUS KAS (CASH FLOW)',
            period:
                '${DateFormatter.shortDate(report.startDate)} - ${DateFormatter.shortDate(report.endDate)}',
            brandBlue: brandBlue,
            navy: navy,
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              _summaryBox(
                label: 'Arus Kas Masuk',
                value: CurrencyFormatter.format(report.totalCashIn),
                accent: accentGreen,
                border: borderGrey,
              ),
              pw.SizedBox(width: 10),
              _summaryBox(
                label: 'Arus Kas Keluar',
                value: CurrencyFormatter.format(report.totalCashOut),
                accent: PdfColor.fromHex('#DC2626'),
                border: borderGrey,
              ),
              pw.SizedBox(width: 10),
              _summaryBox(
                label: 'Posisi Saldo Akhir',
                value: CurrencyFormatter.format(report.endingBalance),
                accent: brandBlue,
                border: borderGrey,
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Posisi Saldo per Akun Kas & Bank',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: navy,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: borderGrey),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: brandBlue),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headers: const ['Nama Akun', 'Tipe', 'Saldo Saat Ini'],
            data: report.accounts
                .map(
                  (a) => [
                    a.name,
                    a.type.label,
                    CurrencyFormatter.format(a.balance),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Ringkasan Arus Kas per Interval',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: navy,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: borderGrey),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: navy),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headers: const ['Periode', 'Kas Masuk', 'Kas Keluar', 'Arus Bersih'],
            data: report.series
                .map(
                  (p) => [
                    p.label,
                    CurrencyFormatter.format(p.cashIn),
                    CurrencyFormatter.format(p.cashOut),
                    CurrencyFormatter.format(p.cashIn - p.cashOut),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 24),
          _buildFooter(generatedBy: generatedBy),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader({
    required String title,
    required String period,
    required PdfColor brandBlue,
    required PdfColor navy,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: brandBlue, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CompTing - Company Accounting',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: brandBlue,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: navy,
                ),
              ),
            ],
          ),
          pw.Text(
            'Periode: $period',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryBox({
    required String label,
    required String value,
    required PdfColor accent,
    required PdfColor border,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: border),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _breakdownTable(
    List<CategoryBreakdown> items,
    PdfColor borderGrey,
  ) {
    if (items.isEmpty) {
      return pw.Text(
        'Belum ada transaksi disetujui pada periode ini.',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      );
    }

    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: borderGrey),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#1E293B')),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headers: const ['Kategori', 'Cost Center', 'Jumlah Trx', 'Total'],
      data: items
          .map(
            (e) => [
              e.categoryName,
              e.costCenter,
              '${e.transactionCount}',
              CurrencyFormatter.format(e.total),
            ],
          )
          .toList(),
    );
  }

  static pw.Widget _buildFooter({required String generatedBy}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Dicetak oleh: $generatedBy',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
        pw.Text(
          'Tanggal cetak: ${DateFormatter.dateTime(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ],
    );
  }
}
