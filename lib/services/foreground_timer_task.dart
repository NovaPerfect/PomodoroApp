import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Top-level entry point — must be annotated so the AOT compiler keeps it.
@pragma('vm:entry-point')
void startTimerCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTimerTask());
}

class ForegroundTimerTask extends TaskHandler {
  static const _keyStartTime     = 'timer_start_time';
  static const _keySeconds       = 'timer_seconds';
  static const _keyMode          = 'timer_mode';
  static const _keyWorkLabel     = 'timer_work_label';
  static const _keyBreakLabel    = 'timer_break_label';
  static const _keyNotifications = 'timer_notifications_enabled';

  static const _countdownNotifId = 43; // OS-managed chronometre (real-time)
  static const _alertNotifId     = 42; // completion alert

  DateTime? _startTime;
  int    _savedSeconds = 0;
  bool   _isWork       = true;
  bool   _alertShown   = false;
  String _workLabel    = 'FOCUS';
  String _breakLabel   = 'BREAK';

  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotif.initialize(
      const InitializationSettings(android: androidInit),
    );

    final prefs       = await SharedPreferences.getInstance();
    final startTimeMs = prefs.getInt(_keyStartTime);
    final savedSecs   = prefs.getInt(_keySeconds) ?? 0;
    final modeStr     = prefs.getString(_keyMode) ?? 'work';

    _isWork       = modeStr == 'work';
    _savedSeconds = savedSecs;
    _workLabel    = prefs.getString(_keyWorkLabel)  ?? 'FOCUS';
    _breakLabel   = prefs.getString(_keyBreakLabel) ?? 'BREAK';
    _startTime    = startTimeMs != null
        ? DateTime.fromMillisecondsSinceEpoch(startTimeMs)
        : DateTime.now();

    final elapsed   = DateTime.now().difference(_startTime!).inSeconds;
    final remaining = (_savedSeconds - elapsed).clamp(0, _savedSeconds);

    if (remaining > 0) {
      _showCountdownNotification(remaining);
    }
  }

  // ─── Каждую секунду ──────────────────────────────────────────────────────

  @override
  void onRepeatEvent(DateTime timestamp) {
    if (_alertShown || _startTime == null) return;

    // Всегда считаем от настенных часов — без накопленного дрейфа
    final elapsed   = DateTime.now().difference(_startTime!).inSeconds;
    final remaining = (_savedSeconds - elapsed).clamp(0, _savedSeconds);

    // Принудительно обновляем countdown каждую секунду.
    // notify() с тем же id обновляет существующее уведомление без пересоздания —
    // onlyAlertOnce:true гарантирует отсутствие звука/вибрации при каждом вызове.
    // Нужно потому что некоторые прошивки (Samsung One UI и др.) не обновляют
    // chronometerCountDown автоматически каждую секунду без явного вызова.
    _showCountdownNotification(remaining);

    // Пересылаем реальное время в основной изолят (для синхронизации UI)
    FlutterForegroundTask.sendDataToMain(remaining);

    if (remaining <= 0) {
      _alertShown = true;
      unawaited(_localNotif.cancel(_countdownNotifId));
      _showCompletionNotification();
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // Всегда убираем countdown при остановке сервиса
    await _localNotif.cancel(_countdownNotifId);
  }

  @override
  void onReceiveData(Object data) {
    if (data is! String || data.isEmpty) return;

    // Обновление метки от пользователя (приходит пока сервис жив = таймер бежит)
    if (_isWork) { _workLabel = data; }
    else         { _breakLabel = data; }

    // Пересоздаём countdown уведомление с новым заголовком
    if (_startTime != null && !_alertShown) {
      final elapsed   = DateTime.now().difference(_startTime!).inSeconds;
      final remaining = (_savedSeconds - elapsed).clamp(0, _savedSeconds);
      if (remaining > 0) { _showCountdownNotification(remaining); }
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Показывает уведомление с системным обратным отсчётом.
  /// [when] = время окончания → ОС сама рисует разницу (remaining),
  /// обновляет каждую миллисекунду без каких-либо вызовов с нашей стороны.
  void _showCountdownNotification(int remainingSeconds) {
    final endTimeMs = DateTime.now().millisecondsSinceEpoch +
        remainingSeconds * 1000;
    final title = _isWork ? _workLabel : _breakLabel;

    unawaited(_localNotif.show(
      _countdownNotifId,
      title,
      null, // тело не нужно — хронометр занимает его место
      NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro_countdown',
          'Pomodoro Countdown',
          channelDescription: 'Live timer countdown',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          when: endTimeMs,
          usesChronometer: true,
          chronometerCountDown: true,
          showWhen: true,
          playSound: false,
          enableVibration: false,
          onlyAlertOnce: true,
        ),
      ),
    ));
  }

  /// Сигнальное уведомление — показывается когда сессия закончена.
  void _showCompletionNotification() {
    unawaited(_doShowCompletion());
  }

  Future<void> _doShowCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_keyNotifications) ?? true)) return;

    final title = _isWork ? '🎉 Focus complete!' : '⏰ Break over!';
    final body  = _isWork
        ? 'Great work! Time for a break.'
        : 'Break finished. Ready to focus?';

    await _localNotif.show(
      _alertNotifId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro_alert',
          'Pomodoro Alerts',
          channelDescription: 'Plays when a Pomodoro session ends',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          sound: null,
        ),
      ),
    );
  }
}
