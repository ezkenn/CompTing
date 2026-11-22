import 'package:compting/core/config/app_env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    final fallback = SupabaseClient(
      AppEnv.isSupabaseConfigured
          ? AppEnv.supabaseUrl
          : 'https://unconfigured.invalid',
      AppEnv.isSupabaseConfigured ? AppEnv.supabaseAnonKey : 'unconfigured',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    ref.onDispose(fallback.dispose);
    return fallback;
  }
});
