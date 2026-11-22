import 'dart:async';

import 'package:compting/core/utils/error_mapper.dart';
import 'package:compting/features/auth/domain/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthExceptionMessage implements Exception {
  const AuthExceptionMessage(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository({required this.client});

  final SupabaseClient client;

  Future<UserProfile?> getCurrentProfile() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    final row = await client
        .from('profiles')
        .select('id, full_name, role')
        .eq('id', user.id)
        .maybeSingle()
        .timeout(const Duration(seconds: 15));

    if (row == null) {
      await client.auth.signOut();
      return null;
    }
    return UserProfile.fromJson(row, emailFallback: user.email ?? '');
  }

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    try {
      final response = await client.auth
          .signInWithPassword(
            email: cleanEmail,
            password: password,
          )
          .timeout(const Duration(seconds: 15));
      final user = response.user;
      if (user == null) {
        throw const AuthExceptionMessage('Autentikasi gagal. Coba lagi.');
      }

      final row = await client
          .from('profiles')
          .select('id, full_name, role')
          .eq('id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 15));

      if (row == null) {
        await client.auth.signOut();
        throw const AuthExceptionMessage(
          'Profil akun belum terdaftar di sistem. Hubungi admin Finance.',
        );
      }

      return UserProfile.fromJson(row, emailFallback: user.email ?? cleanEmail);
    } on TimeoutException {
      throw const AuthExceptionMessage(
        'Koneksi ke server melebihi batas waktu. Periksa jaringan Anda dan coba lagi.',
      );
    } on AuthException catch (e) {
      throw AuthExceptionMessage(AppErrorMapper.toUserMessage(e));
    } on PostgrestException catch (_) {
      throw const AuthExceptionMessage(
        'Gagal memuat profil pengguna. Coba lagi beberapa saat.',
      );
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
