/// Konfigurasi environment aplikasi CompTing.
///
/// Nilai WAJIB disuntikkan saat build/run menggunakan `--dart-define` atau
/// `--dart-define-from-file`:
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=xxx
/// ```
abstract final class AppEnv {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  static const String receiptBucket = String.fromEnvironment(
    'SUPABASE_RECEIPT_BUCKET',
    defaultValue: 'receipts',
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.startsWith('https://') && supabaseAnonKey.isNotEmpty;
}
