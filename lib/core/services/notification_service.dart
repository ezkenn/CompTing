import 'package:compting/core/utils/currency_formatter.dart';
import 'package:compting/features/debts/domain/debt_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _timeZonesInitialized = false;

  void _ensureTimeZonesInitialized() {
    if (_timeZonesInitialized) return;
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {
      // Fallback ke UTC jika zona waktu tidak tersedia
    }
    _timeZonesInitialized = true;
  }

  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings();
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _plugin.initialize(settings);

      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();

      _initialized = true;
    } catch (e) {
      debugPrint('Inisialisasi notifikasi lokal dilewati: $e');
    }
  }

  Future<void> scheduleDebtReminder(DebtModel debt) async {
    if (!_initialized || !debt.reminderEnabled || debt.isPaid) return;

    try {
      _ensureTimeZonesInitialized();

      final now = DateTime.now();
      var scheduledDate = DateTime(
        debt.dueDate.year,
        debt.dueDate.month,
        debt.dueDate.day,
        9,
        0,
      );

      // Jika sudah lewat jam 09:00 hari ini, jadwalkan 1 menit dari sekarang.
      if (!scheduledDate.isAfter(now)) {
        scheduledDate = now.add(const Duration(minutes: 1));
      }

      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
      final title = debt.type == DebtType.piutang
          ? 'Pengingat Piutang Jatuh Tempo'
          : 'Pengingat Utang Supplier Jatuh Tempo';
      final body =
          '${debt.partyName} • ${CurrencyFormatter.format(debt.amount)}';

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'compting_debt_reminders',
          'Pengingat Utang & Piutang',
          channelDescription:
              'Notifikasi otomatis tanggal jatuh tempo utang supplier dan piutang customer.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _plugin.zonedSchedule(
        debt.notificationId,
        title,
        body,
        tzDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Gagal menjadwalkan notifikasi jatuh tempo: $e');
    }
  }

  Future<void> cancelDebtReminder(DebtModel debt) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(debt.notificationId);
    } catch (e) {
      debugPrint('Gagal membatalkan notifikasi: $e');
    }
  }
}
