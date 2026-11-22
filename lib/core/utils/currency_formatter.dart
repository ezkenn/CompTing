import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _plainNumberFormat = NumberFormat.decimalPattern(
    'id_ID',
  );

  static String format(num amount, {bool showSign = false}) {
    final absValue = amount.abs();
    final formatted = _rupiahFormat.format(absValue);
    if (amount < 0) {
      return '-$formatted';
    }
    if (showSign && amount > 0) {
      return '+$formatted';
    }
    return formatted;
  }

  static String formatCompact(num amount) {
    final absVal = amount.abs();
    final prefix = amount < 0 ? '-' : '';
    if (absVal >= 1000000000) {
      return '${prefix}Rp ${(absVal / 1000000000).toStringAsFixed(1)} M';
    }
    if (absVal >= 1000000) {
      return '${prefix}Rp ${(absVal / 1000000).toStringAsFixed(1)} jt';
    }
    if (absVal >= 1000) {
      return '${prefix}Rp ${(absVal / 1000).toStringAsFixed(0)} rb';
    }
    return format(amount);
  }

  static String formatPlain(num amount) => _plainNumberFormat.format(amount);

  static double parse(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return double.tryParse(digits) ?? 0;
  }
}

/// Formatter otomatis pemisah ribuan untuk input nominal Rupiah.
class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue();
    }
    final number = int.tryParse(digits);
    if (number == null) return oldValue;
    final formatted = CurrencyFormatter.formatPlain(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
