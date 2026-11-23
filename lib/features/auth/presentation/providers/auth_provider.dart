import 'package:compting/core/config/supabase_client.dart';
import 'package:compting/features/auth/data/auth_repository.dart';
import 'package:compting/features/auth/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _rememberMePrefsKey = 'compting_remember_me';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(client: ref.watch(supabaseClientProvider));
});

class AuthController extends StateNotifier<AsyncValue<UserProfile?>> {
  AuthController(this._repository) : super(const AsyncValue.data(null)) {
    restoreSession();
  }

  final AuthRepository _repository;

  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_rememberMePrefsKey) ?? true;
      if (!rememberMe) {
        await _repository.signOut();
        if (mounted) {
          state = const AsyncValue.data(null);
        }
        return;
      }

      final existing = await _repository.getCurrentProfile();
      if (mounted) {
        state = AsyncValue.data(existing);
      }
    } catch (_) {
      if (mounted) {
        state = const AsyncValue.data(null);
      }
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.signIn(
        email: email,
        password: password,
      );
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_rememberMePrefsKey, rememberMe);
      } catch (_) {
        // Abaikan jika SharedPreferences tidak tersedia di environment test
      }
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_rememberMePrefsKey);
    } catch (_) {}
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserProfile?>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

final currentUserProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authControllerProvider).valueOrNull;
});
