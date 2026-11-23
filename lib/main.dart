import 'package:compting/app.dart';
import 'package:compting/core/config/app_env.dart';
import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!AppEnv.isSupabaseConfigured) {
    runApp(const _MissingConfigApp());
    return;
  }

  runApp(const _CompTingBootstrap());
}

class _CompTingBootstrap extends StatefulWidget {
  const _CompTingBootstrap();

  @override
  State<_CompTingBootstrap> createState() => _CompTingBootstrapState();
}

class _CompTingBootstrapState extends State<_CompTingBootstrap> {
  bool _ready = false;
  Object? _initError;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await Future.wait([
        initializeDateFormatting('id_ID'),
        Supabase.initialize(
          url: AppEnv.supabaseUrl,
          publishableKey: AppEnv.supabaseAnonKey,
        ),
      ]);
      if (!mounted) return;
      setState(() => _ready = true);
      Future<void>.delayed(const Duration(seconds: 2), () {
        NotificationService.instance.init();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _initError = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return const ProviderScope(child: CompTingApp());
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: _initError != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppColors.danger,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Gagal menginisialisasi aplikasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => _initError = null);
                          _bootstrap();
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Memuat CompTing...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
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
