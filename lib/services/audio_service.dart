import 'package:flutter/material.dart';
import 'audio_handler.dart';

// Переэкспортируем TrackInfo под старым именем для совместимости
typedef TrackModel = TrackInfo;

class PlaylistModel {
  final String name;
  final String imagePath;
  final List<TrackModel> tracks;

  const PlaylistModel({
    required this.name,
    required this.imagePath,
    required this.tracks,
  });

  int get totalMinutes => tracks.length * 3;
}

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  StudyFlowAudioHandler? _handler;

  List<TrackModel> _queue       = [];
  int              _index       = 0;
  bool             _isPlaying   = false;
  bool             _isShuffle   = false;
  bool             _isLoop      = false;
  Duration         _position    = Duration.zero;
  Duration         _duration    = Duration.zero;
  String?          _playlistName;

  bool        get isPlaying    => _isPlaying;
  bool        get isShuffle    => _isShuffle;
  bool        get isLoop       => _isLoop;
  Duration    get position     => _position;
  Duration    get duration     => _duration;
  String?     get playlistName => _playlistName;
  bool        get hasTrack     => _queue.isNotEmpty;
  TrackModel? get currentTrack => hasTrack ? _queue[_index] : null;
  int         get queueLength  => _queue.length;
  int         get currentIndex => _index;
  // Доступ к нижележащему плееру (для настройки громкости и т.д.)
  dynamic     get player       => _handler?.player;

  void setHandler(StudyFlowAudioHandler handler) {
    _handler = handler;
    final p = handler.player;

    p.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });
    p.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });
    p.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });
    // Синхронизируем индекс после авто-перехода (skipToNext внутри handler)
    p.playerStateStream.listen((_) {
      if (_handler != null) {
        _index = _handler!.currentIndex;
        notifyListeners();
      }
    });
  }

  // Оставляем для обратной совместимости (если вызывается до setHandler)
  void init() {}

  Future<void> playPlaylist(PlaylistModel playlist, {int startIndex = 0}) async {
    _queue        = playlist.tracks;
    _index        = startIndex;
    _playlistName = playlist.name;
    await _handler?.loadQueue(playlist.tracks, startIndex);
    notifyListeners();
  }

  Future<void> playPause() async {
    if (_handler == null) return;
    if (_handler!.player.playing) {
      await _handler!.pause();
    } else {
      await _handler!.play();
    }
  }

  Future<void> next() async {
    await _handler?.skipToNext();
    _index = _handler?.currentIndex ?? _index;
    notifyListeners();
  }

  Future<void> prev() async {
    await _handler?.skipToPrevious();
    _index = _handler?.currentIndex ?? _index;
    notifyListeners();
  }

  Future<void> seek(Duration pos) async {
    await _handler?.seek(pos);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    _handler?.setShuffle(_isShuffle);
    notifyListeners();
  }

  Future<void> toggleLoop() async {
    _isLoop = !_isLoop;
    await _handler?.setLoopMode(_isLoop);
    notifyListeners();
  }

  Future<void> initDefaultPlaylist(PlaylistModel playlist) async {
    _queue        = playlist.tracks;
    _index        = 0;
    _playlistName = playlist.name;
    // Загружаем первый трек, но не играем
    if (_handler != null) {
      await _handler!.player.setAsset(playlist.tracks[0].assetPath);
    }
    notifyListeners();
  }
}
