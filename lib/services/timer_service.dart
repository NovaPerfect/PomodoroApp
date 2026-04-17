import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/stats_repository.dart';
import 'foreground_timer_task.dart';

enum TimerMode { work, breakTime }

class TimerService extends ChangeNotifier with WidgetsBindingObserver {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  // ключи для SharedPreferences
  static const _keyStartTime     = 'timer_start_time';
  static const _keySeconds       = 'timer_seconds';
  static const _keyMode          = 'timer_mode';
  static const _keyPending       = 'timer_pending_seconds';
  static const _keySessions      = 'timer_sessions';
  static const _keyWorkMins      = 'timer_work_mins';
  static const _keyBreakMins     = 'timer_break_mins';
  static const _keyWorkLabel     = 'timer_work_label';
  static const _keyBreakLabel    = 'timer_break_label';
  static const _keyNotifications = 'timer_notifications_enabled';

  /// Максимальная длина пользовательской метки (символов)
  static const int maxLabelLength = 14;

  int       _workMinutes      = 25;
  int       _breakMinutes     = 5;
  String    _workLabel           = 'FOCUS';
  String    _breakLabel          = 'BREAK';
  bool      _notificationsEnabled = true;
  int       _seconds          = 25 * 60;
  bool      _isRunning        = false;
  TimerMode _mode             = TimerMode.work;
  int       _sessions         = 0;
  int       _pendingSeconds   = 0;
  DateTime? _sessionStartTime;
  Timer?    _timer;
  bool      _sessionStartCounted = false;
  // Флаг: foreground-сервис сейчас запущен (чтобы не останавливать/запускать его при каждой паузе)
  bool      _serviceRunning = false;


  int       get seconds      => _seconds;
  bool      get isRunning    => _isRunning;
  TimerMode get mode         => _mode;
  int       get sessions     => _sessions;
  int       get workMinutes  => _workMinutes;
  int       get breakMinutes => _breakMinutes;
  String    get workLabel            => _workLabel;
  String    get breakLabel           => _breakLabel;
  String    get currentLabel         => _mode == TimerMode.work ? _workLabel : _breakLabel;
  bool      get notificationsEnabled => _notificationsEnabled;

  int get currentMaxSeconds => _mode == TimerMode.work 
      ? _workMinutes * 60 
      : _breakMinutes * 60;

  double get progress => 1 - _seconds / currentMaxSeconds;

  String get timeString {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds  % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // вызывается при старте приложения
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);

    // Слушаем данные от foreground-сервиса через публичный API.
    // Сервис шлёт реальное оставшееся время (int), чтобы UI совпадал с шторкой.
    FlutterForegroundTask.addTaskDataCallback(_onForegroundData);
    final prefs = await SharedPreferences.getInstance();

    // загружаем настройки длительности и метки
    _workMinutes  = prefs.getInt(_keyWorkMins)      ?? 25;
    _breakMinutes = prefs.getInt(_keyBreakMins)     ?? 5;
    _workLabel             = prefs.getString(_keyWorkLabel)   ?? 'FOCUS';
    _breakLabel            = prefs.getString(_keyBreakLabel)  ?? 'BREAK';
    _notificationsEnabled  = prefs.getBool(_keyNotifications) ?? true;

    // восстанавливаем состояние
    _mode     = (prefs.getString(_keyMode) ?? 'work') == 'work'
        ? TimerMode.work
        : TimerMode.breakTime;
    _sessions        = prefs.getInt(_keySessions)  ?? 0;
    _pendingSeconds  = prefs.getInt(_keyPending)   ?? 0;

    final startTimeMs = prefs.getInt(_keyStartTime);
    final savedSeconds = prefs.getInt(_keySeconds);

    if (startTimeMs != null && savedSeconds != null) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMs);
      final elapsed   = DateTime.now().difference(startTime).inSeconds;

      if (_mode == TimerMode.work) {
        _pendingSeconds += elapsed;
      }

      final remaining = savedSeconds - elapsed;

      if (remaining <= 0) {
        _seconds          = 0;
        _sessionStartTime = null;
        await _clearSavedState(prefs);
        _onEnd();
      } else {
        _seconds          = remaining;
        _sessionStartTime = DateTime.now();
        _isRunning        = true;
        _startTicking();
      }
    } else {
      _seconds = savedSeconds ?? currentMaxSeconds;
    }

    notifyListeners();
  }

  Future<void> setWorkMinutes(int mins) async {
    _workMinutes = mins;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWorkMins, mins);
    if (_mode == TimerMode.work) {
      // Если таймер бежит — сбрасываем; если стоит — просто обновляем секунды
      if (_isRunning) {
        await _resetToMode(TimerMode.work, mins * 60, prefs);
      } else {
        _seconds = mins * 60;
      }
    }
    notifyListeners();
  }

  Future<void> setBreakMinutes(int mins) async {
    _breakMinutes = mins;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBreakMins, mins);
    if (_mode == TimerMode.breakTime) {
      if (_isRunning) {
        await _resetToMode(TimerMode.breakTime, mins * 60, prefs);
      } else {
        _seconds = mins * 60;
      }
    }
    notifyListeners();
  }

  /// Сбрасывает текущую сессию и ставит новую длительность (без смены режима).
  Future<void> _resetToMode(TimerMode mode, int newSeconds, SharedPreferences prefs) async {
    _timer?.cancel();
    _isRunning           = false;
    _seconds             = newSeconds;
    _pendingSeconds      = 0;
    _sessionStartTime    = null;
    _sessionStartCounted = false;
    _terminateForegroundTask();
    await _clearSavedState(prefs);
    unawaited(prefs.setString(_keyMode, mode == TimerMode.work ? 'work' : 'break'));
  }

  Future<void> setWorkLabel(String label) async {
    _workLabel = label.substring(0, label.length.clamp(0, maxLabelLength));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyWorkLabel, _workLabel);
    // Обновляем уведомление прямо сейчас, если таймер работает в режиме фокуса
    if (_isRunning && _mode == TimerMode.work) {
      unawaited(FlutterForegroundTask.updateService(notificationTitle: _workLabel));
      FlutterForegroundTask.sendDataToTask(_workLabel);
    }
    notifyListeners();
  }

  Future<void> setBreakLabel(String label) async {
    _breakLabel = label.substring(0, label.length.clamp(0, maxLabelLength));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBreakLabel, _breakLabel);
    // Обновляем уведомление прямо сейчас, если таймер работает в режиме перерыва
    if (_isRunning && _mode == TimerMode.breakTime) {
      unawaited(FlutterForegroundTask.updateService(notificationTitle: _breakLabel));
      FlutterForegroundTask.sendDataToTask(_breakLabel);
    }
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
    notifyListeners();
  }

  // ─── Foreground service helpers ──────────────────────────────────────────

  /// Запускает сервис заново. Префы уже записаны до вызова,
  /// поэтому onStart в задаче читает актуальные данные без гонки.
  void _startForegroundTask() {
    _serviceRunning = true;
    unawaited(FlutterForegroundTask.startService(
      serviceId: 300,
      notificationTitle: '',   // скрыто: реальное уведомление — countdown (id=43)
      notificationText: '',
      callback: startTimerCallback,
    ));
  }

  /// Пауза и сброс — полностью останавливает сервис.
  /// Уведомление исчезает: Android не показывает уведомление без сервиса.
  void _stopForegroundTask() {
    if (!_serviceRunning) return;
    _serviceRunning = false;
    unawaited(FlutterForegroundTask.stopService());
  }

  // Псевдоним для читаемости вызовов при reset/onEnd
  void _terminateForegroundTask() => _stopForegroundTask();

  // ─── Internal ticking ────────────────────────────────────────────────────

  void _startTicking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        _seconds--;
        notifyListeners();
      } else {
        _onEnd();
      }
    });
  }

  Future<void> startPause() async {
    if (_isRunning) {
      // ─── ПАУЗА ───────────────────────────────────────────────────────────
      _timer?.cancel();
      _isRunning = false;

      if (_sessionStartTime != null && _mode == TimerMode.work) {
        _pendingSeconds += DateTime.now().difference(_sessionStartTime!).inSeconds;
        _sessionStartTime = null;
      }

      // ← UI отзывается мгновенно
      notifyListeners();

      // Async-работа в фоне — не блокирует UI
      final toSave = _pendingSeconds;
      if (toSave > 0 && _mode == TimerMode.work) {
        _pendingSeconds = 0;
        unawaited(_saveStats(toSave, countSession: false));
      }

      // Останавливаем сервис → уведомление исчезает
      _stopForegroundTask();

      final prefs = await SharedPreferences.getInstance();
      unawaited(prefs.remove(_keyStartTime));
      unawaited(prefs.setInt(_keySeconds,  _seconds));
      unawaited(prefs.setInt(_keyPending,  _pendingSeconds));
      unawaited(prefs.setInt(_keySessions, _sessions));
      unawaited(prefs.setString(_keyMode,
          _mode == TimerMode.work ? 'work' : 'break'));

    } else {
      // ─── СТАРТ / ВОЗОБНОВЛЕНИЕ ───────────────────────────────────────────
      if (!_sessionStartCounted && _mode == TimerMode.work) {
        _sessionStartCounted = true;
        unawaited(_countStartedSession());
      }

      _sessionStartTime = DateTime.now();
      _startTicking();
      _isRunning = true;

      // ← UI отзывается мгновенно
      notifyListeners();

      // Пишем startTime и seconds до старта сервиса — onStart читает актуальные данные
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyStartTime, _sessionStartTime!.millisecondsSinceEpoch);
      await prefs.setInt(_keySeconds,   _seconds);
      await prefs.setString(_keyMode,   _mode == TimerMode.work ? 'work' : 'break');
      unawaited(prefs.setInt(_keyPending,  _pendingSeconds));
      unawaited(prefs.setInt(_keySessions, _sessions));

      // Стартуем сервис — уведомление появляется
      _startForegroundTask();
    }
  }

  void _onEnd() {
    _timer?.cancel();
    _isRunning = false;

    if (_mode == TimerMode.work) {
      _sessions++;

      if (_sessionStartTime != null) {
        final elapsed = DateTime.now()
            .difference(_sessionStartTime!)
            .inSeconds;
        _pendingSeconds += elapsed;
        _sessionStartTime = null;
      }

      if (_pendingSeconds > 0) {
        _saveStats(_pendingSeconds, countSession: true);
      }
      _pendingSeconds = 0;

      _mode    = TimerMode.breakTime;
      _seconds = _breakMinutes * 60;
    } else {
      _mode    = TimerMode.work;
      _seconds = _workMinutes * 60;
    }

    _sessionStartCounted = false;
    _clearSavedStateSync();
    // Даём foreground-задаче 1.5 с показать уведомление об окончании,
    // затем реально останавливаем сервис.
    Future.delayed(const Duration(milliseconds: 1500), _terminateForegroundTask);
    notifyListeners();
  }

  Future<void> _countStartedSession() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final key = StatsRepository.dateKey(_todayDate());
      await StatsRepository().incrementStartedSession(uid, key);
    } catch (e) {
      debugPrint('[TimerService] _countStartedSession ERROR: $e');
    }
  }

  Future<void> _saveStats(int seconds, {bool countSession = true}) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      debugPrint('[TimerService] _saveStats: seconds=$seconds countSession=$countSession uid=$uid');
      if (uid == null) {
        debugPrint('[TimerService] _saveStats: uid is null, skipping');
        return;
      }
      final today = _todayDate();
      final key   = StatsRepository.dateKey(today);
      debugPrint('[TimerService] _saveStats: saving to key=$key');
      await StatsRepository().addFocusSeconds(uid, key, seconds,
          countSession: countSession);
      debugPrint('[TimerService] _saveStats: SUCCESS');
    } catch (e, stack) {
      debugPrint('[TimerService] _saveStats ERROR: $e');
      debugPrint('[TimerService] _saveStats STACK: $stack');
    }
  }

  Future<void> _clearSavedState(SharedPreferences prefs) async {
    await prefs.remove(_keyStartTime);
    await prefs.remove(_keySeconds);
    await prefs.remove(_keyPending);
  }

  void _clearSavedStateSync() async {
    final prefs = await SharedPreferences.getInstance();
    await _clearSavedState(prefs);
  }

  DateTime _todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Пересчитываем таймер при возврате из фона
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isRunning) {
      _recalculateOnResume();
    }
  }

  Future<void> _recalculateOnResume() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeMs  = prefs.getInt(_keyStartTime);
    final savedSeconds = prefs.getInt(_keySeconds);
    if (startTimeMs == null || savedSeconds == null) return;

    final elapsed   = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(startTimeMs))
        .inSeconds;
    final remaining = savedSeconds - elapsed;

    _timer?.cancel();
    if (remaining <= 0) {
      _seconds = 0;
      _onEnd();
    } else {
      _seconds = remaining;
      _startTicking();
      notifyListeners();
    }
  }

  void skip() => _onEnd();

  Future<void> reset() async {
    _timer?.cancel();
    _isRunning           = false;
    _mode                = TimerMode.work;
    _seconds             = _workMinutes * 60;
    _pendingSeconds      = 0;
    _sessionStartTime    = null;
    _sessionStartCounted = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStartTime);
    await prefs.remove(_keySeconds);
    await prefs.remove(_keyPending);
    await prefs.remove(_keySessions);
    await prefs.remove(_keyMode);

    _terminateForegroundTask();
    notifyListeners();
  }

  // Callback для данных от foreground-сервиса
  void _onForegroundData(Object data) {
    if (!_isRunning) return;
    if (data is int && data >= 0) {
      // Обновляем только если разница > 1 с — мелкий джиттер игнорируем
      if ((_seconds - data).abs() > 1) {
        _seconds = data;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FlutterForegroundTask.removeTaskDataCallback(_onForegroundData);
    _timer?.cancel();
    super.dispose();
  }
}
