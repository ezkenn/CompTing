import 'package:compting/app.dart';
import 'package:compting/core/config/app_env.dart';
import 'package:compting/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID');

  if (!AppEnv.isSupabaseConfigured) {
    runApp(const _MissingConfigApp());
    return;
  }

  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    publishableKey: AppEnv.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: CompTingApp()));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.instance.init();
  });
}

class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Konfigurasi Lingkungan Tidak Lengkap',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Jalankan aplikasi dengan --dart-define=SUPABASE_URL=... dan --dart-define=SUPABASE_ANON_KEY=...',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
