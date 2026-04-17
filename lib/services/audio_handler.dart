import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

// Модели треков — дублируем тут чтобы избежать circular import
class TrackInfo {
  final String title;
  final String artist;
  final String assetPath;
  const TrackInfo({required this.title, required this.artist, required this.assetPath});
}

class StudyFlowAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  List<TrackInfo> _queue    = [];
  int             _index    = 0;
  bool            _shuffle  = false;

  AudioPlayer get player          => _player;
  List<TrackInfo> get trackQueue  => _queue;
  int get currentIndex            => _index;
  bool get isShuffle              => _shuffle;

  StudyFlowAudioHandler() {
    // Транслируем состояние плеера в PlaybackState (виден в уведомлении)
    _player.playingStream.listen((_) => _broadcastState());
    _player.processingStateStream.listen((_) => _broadcastState());
    _player.positionStream.listen((pos) {
      playbackState.add(playbackState.value.copyWith(updatePosition: pos));
    });
    _player.durationStream.listen((dur) {
      final item = mediaItem.value;
      if (item != null && dur != null) {
        mediaItem.add(item.copyWith(duration: dur));
      }
    });
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  void _broadcastState() {
    final playing = _player.playing;
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: {
        ProcessingState.idle:      AudioProcessingState.idle,
        ProcessingState.loading:   AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready:     AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState] ?? AudioProcessingState.idle,
      playing: playing,
      updatePosition: _player.position,
    ));
  }

  Future<void> loadQueue(List<TrackInfo> tracks, int startIndex) async {
    _queue = tracks;
    _index = startIndex;
    await _loadAndPlay();
  }

  Future<void> _loadAndPlay() async {
    if (_queue.isEmpty) return;
    final track = _queue[_index];
    mediaItem.add(MediaItem(
      id: track.assetPath,
      title: track.title,
      artist: track.artist,
      album: 'StudyFlow',
    ));
    await _player.setAsset(track.assetPath);
    await _player.play();
  }

  @override Future<void> play()                => _player.play();
  @override Future<void> pause()               => _player.pause();
  @override Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;
    _index = _shuffle
        ? DateTime.now().millisecondsSinceEpoch % _queue.length
        : (_index + 1) % _queue.length;
    await _loadAndPlay();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    _index = (_index - 1 + _queue.length) % _queue.length;
    await _loadAndPlay();
  }

  void setShuffle(bool v) => _shuffle = v;

  Future<void> setLoopMode(bool loop) =>
      _player.setLoopMode(loop ? LoopMode.one : LoopMode.off);

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }
}
