import 'package:compting/core/utils/currency_formatter.dart';

abstract final class AppValidators {
  /// Batas maksimum nominal sesuai tipe NUMERIC(15, 2) di PostgreSQL.
  static const double maxTransactionAmount = 9999999999999;

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Email kantor wajib diisi';
    }
    if (trimmed.length > 254) {
      return 'Email terlalu panjang';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    if (value.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    if (value.length > 128) {
      return 'Kata sandi terlalu panjang';
    }
    return null;
  }

  static String? requiredText(
    String? value,
    String fieldName, {
    int maxLength = 500,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '$fieldName wajib diisi';
    }
    if (trimmed.length > maxLength) {
      return '$fieldName maksimal $maxLength karakter';
    }
    return null;
  }

  static String? optionalText(
    String? value,
    String fieldName, {
    int maxLength = 500,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length > maxLength) {
      return '$fieldName maksimal $maxLength karakter';
    }
    return null;
  }

  static String? positiveAmount(String? value) {
    final parsed = CurrencyFormatter.parse(value ?? '');
    if (parsed <= 0) {
      return 'Nominal harus lebih besar dari Rp 0';
    }
    if (parsed > maxTransactionAmount) {
      return 'Nominal melebihi batas maksimum transaksi';
    }
    return null;
  }

  /// Validasi alasan penolakan (selaras dengan PostgreSQL check constraint).
  static String? rejectionNote(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Alasan penolakan wajib diisi';
    }
    if (trimmed.length < 5) {
      return 'Alasan penolakan minimal 5 karakter';
    }
    if (trimmed.length > 500) {
      return 'Alasan penolakan maksimal 500 karakter';
    }
    return null;
  }
}
