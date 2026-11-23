import 'dart:async';
import 'dart:io';

import 'package:compting/features/auth/data/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Memetakan exception teknis/backend ke pesan aman yang ramah pengguna
/// agar tidak membocorkan detail skema database atau struktur server ke UI.
abstract final class AppErrorMapper {
  static String toUserMessage(
    Object error, {
    String fallback = 'Terjadi kesalahan. Silakan coba lagi beberapa saat.',
  }) {
    if (kDebugMode) {
      debugPrint('[AppErrorMapper] $error');
    }

    if (error is AuthExceptionMessage) {
      return error.message;
    }

    if (error is ArgumentError) {
      return error.message?.toString() ?? 'Data yang dimasukkan tidak valid.';
    }

    if (error is TimeoutException) {
      return 'Koneksi ke server melebihi batas waktu. Periksa jaringan Anda.';
    }

    if (error is SocketException) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    }

    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials')) {
        return 'Email atau kata sandi salah.';
      }
      if (msg.contains('email not confirmed')) {
        return 'Email akun belum terverifikasi. Hubungi admin.';
      }
      if (msg.contains('too many requests') || msg.contains('rate limit')) {
        return 'Terlalu banyak percobaan. Tunggu beberapa menit lalu coba lagi.';
      }
      return 'Autentikasi gagal. Periksa kembali kredensial Anda.';
    }

    if (error is PostgrestException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('saldo akun tidak mencukupi')) {
        return 'Saldo akun tidak mencukupi untuk menyetujui pengeluaran ini.';
      }
      if (msg.contains('transaksi milik sendiri')) {
        return 'Anda tidak dapat menyetujui atau menolak transaksi milik sendiri.';
      }
      if (msg.contains('sudah berstatus')) {
        return 'Transaksi ini sudah diproses sebelumnya.';
      }
      if (msg.contains('sudah berstatus lunas') ||
          msg.contains('sudah lunas')) {
        return 'Tagihan ini sudah berstatus lunas.';
      }
      if (msg.contains('akses ditolak') || error.code == '42501') {
        return 'Anda tidak memiliki izin untuk melakukan tindakan ini.';
      }
      if (error.code == '23505') {
        return 'Data yang sama sudah tercatat di sistem.';
      }
      return 'Gagal memproses data di server. Silakan coba lagi.';
    }

    if (error is StorageException) {
      return 'Gagal memproses berkas bukti transaksi. Pastikan ukuran dan format gambar valid.';
    }

    return fallback;
  }
}
