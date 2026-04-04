import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class TrackModel {
  final String title;
  final String artist;
  final String assetPath;

  const TrackModel({
    required this.title,
    required this.artist,
    required this.assetPath,
  });
}

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

  final AudioPlayer player = AudioPlayer();

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

  void init() {
    // ✅ слушаем реальное состояние плеера
    player.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        next();
      }
    });
  }

  Future<void> playPlaylist(PlaylistModel playlist, {int startIndex = 0}) async {
    _queue        = playlist.tracks;
    _index        = startIndex;
    _playlistName = playlist.name;
    await _loadAndPlay();
  }

  Future<void> _loadAndPlay() async {
    if (_queue.isEmpty) return;
    await player.setAsset(_queue[_index].assetPath);
    await player.play();
    // ✅ не меняем _isPlaying вручную — playingStream сам обновит
    notifyListeners();
  }

  Future<void> playPause() async {
    // ✅ проверяем реальное состояние плеера а не _isPlaying
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    if (_isShuffle) {
      _index = DateTime.now().millisecondsSinceEpoch % _queue.length;
    } else {
      _index = (_index + 1) % _queue.length;
    }
    await _loadAndPlay();
  }

  Future<void> prev() async {
    if (_queue.isEmpty) return;
    if (_position.inSeconds > 3) {
      await player.seek(Duration.zero);
      return;
    }
    _index = (_index - 1 + _queue.length) % _queue.length;
    await _loadAndPlay();
  }

  Future<void> seek(Duration pos) async {
    await player.seek(pos);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  Future<void> toggleLoop() async {
    _isLoop = !_isLoop;
    await player.setLoopMode(_isLoop ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  Future<void> initDefaultPlaylist(PlaylistModel playlist) async {
    try {
      _queue        = playlist.tracks;
      _index        = 0;
      _playlistName = playlist.name;
      await player.setAsset(_queue[0].assetPath);
      // ✅ не меняем _isPlaying — плеер стоит на паузе по умолчанию
      notifyListeners();
    } catch (e) {
      debugPrint('initDefaultPlaylist error: $e');
    }
  }
}