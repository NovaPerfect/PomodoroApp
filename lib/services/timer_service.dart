import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/stats_repository.dart';

enum TimerMode { work, breakTime }

class TimerService extends ChangeNotifier {
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

  int       _workMinutes      = 25;
  int       _breakMinutes     = 5;
  int       _seconds          = 25 * 60;
  bool      _isRunning        = false;
  TimerMode _mode             = TimerMode.work;
  int       _sessions         = 0;
  int       _pendingSeconds   = 0;
  DateTime? _sessionStartTime;
  Timer?    _timer;

  int       get seconds      => _seconds;
  bool      get isRunning    => _isRunning;
  TimerMode get mode         => _mode;
  int       get sessions     => _sessions;
  int       get workMinutes  => _workMinutes;
  int       get breakMinutes => _breakMinutes;

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
    final prefs = await SharedPreferences.getInstance();

    // загружаем настройки длительности
    _workMinutes  = prefs.getInt(_keyWorkMins)  ?? 25;
    _breakMinutes = prefs.getInt(_keyBreakMins) ?? 5;

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
    if (!_isRunning && _mode == TimerMode.work) {
      _seconds = mins * 60;
    }
    notifyListeners();
  }

  Future<void> setBreakMinutes(int mins) async {
    _breakMinutes = mins;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBreakMins, mins);
    if (!_isRunning && _mode == TimerMode.breakTime) {
      _seconds = mins * 60;
    }
    notifyListeners();
  }

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
    final prefs = await SharedPreferences.getInstance();

    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;

      if (_sessionStartTime != null && _mode == TimerMode.work) {
        final elapsed = DateTime.now()
            .difference(_sessionStartTime!)
            .inSeconds;
        _pendingSeconds += elapsed;
        _sessionStartTime = null;
      }

      // Сохраняем накопленные секунды в Firestore при паузе (без засчитывания сессии)
      debugPrint('[TimerService] pause: _pendingSeconds=$_pendingSeconds mode=$_mode');
      if (_pendingSeconds > 0 && _mode == TimerMode.work) {
        await _saveStats(_pendingSeconds, countSession: false);
        _pendingSeconds = 0;
      }

      await prefs.remove(_keyStartTime);
      await prefs.setInt(_keySeconds,  _seconds);
      await prefs.setInt(_keyPending,  _pendingSeconds);
      await prefs.setInt(_keySessions, _sessions);
      await prefs.setString(_keyMode,
          _mode == TimerMode.work ? 'work' : 'break');
    } else {
      _sessionStartTime = DateTime.now();
      _startTicking();
      _isRunning = true;

      await prefs.setInt(_keyStartTime,
          _sessionStartTime!.millisecondsSinceEpoch);
      await prefs.setInt(_keySeconds,  _seconds);
      await prefs.setInt(_keyPending,  _pendingSeconds);
      await prefs.setInt(_keySessions, _sessions);
      await prefs.setString(_keyMode,
          _mode == TimerMode.work ? 'work' : 'break');
    }
    notifyListeners();
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

    _clearSavedStateSync();
    notifyListeners();
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

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void skip() => _onEnd();

  Future<void> reset() async {
    _timer?.cancel();
    _isRunning        = false;
    _mode             = TimerMode.work;
    _seconds          = _workMinutes * 60;
    _pendingSeconds   = 0;
    _sessionStartTime = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStartTime);
    await prefs.remove(_keySeconds);
    await prefs.remove(_keyPending);
    await prefs.remove(_keySessions);
    await prefs.remove(_keyMode);

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
