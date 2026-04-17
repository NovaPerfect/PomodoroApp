import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final _audio = AudioService();

  @override
  void initState() {
    super.initState();
    _audio.addListener(() {
      if (mounted) setState(() {});
    });
  }

  bool get _isThisPlaylist => _audio.playlistName == widget.playlist.name;

  @override
  Widget build(BuildContext context) {
    final playlist = widget.playlist;

    return Scaffold(
      body: CustomScrollView(
        slivers: [

          // ═══ ШАПКА ═══
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // картинка плейлиста
                SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: Image.asset(
                    playlist.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.accent2, AppColors.accent],
                        ),
                      ),
                    ),
                  ),
                ),

                // затемнение снизу
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.6),
                          AppColors.background,
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // кнопка назад
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ═══ ИНФО ═══
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // название + описание + треки
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${playlist.tracks.length} tracks  •  ~${playlist.totalMinutes} min',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // кнопка play/pause всего плейлиста
                  GestureDetector(
                    onTap: () async {
                      if (_isThisPlaylist) {
                        await _audio.playPause();
                      } else {
                        await _audio.playPlaylist(playlist);
                      }
                    },
                    child: Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withValues(alpha: 0.15),
                        border: Border.all(
                            color: AppColors.accent, width: 1.5),
                      ),
                      child: Icon(
                        _isThisPlaylist && _audio.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.accent,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // разделитель
          SliverToBoxAdapter(
            child: Divider(
              color: Colors.white.withValues(alpha: 0.08),
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ═══ СПИСОК ТРЕКОВ ═══
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                final track = playlist.tracks[i];
                final isActive = _isThisPlaylist &&
                    _audio.currentIndex == i;

                return GestureDetector(
                  onTap: () async {
                    await _audio.playPlaylist(playlist, startIndex: i);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // номер
                        SizedBox(
                          width: 32,
                          child: Text(
                            isActive ? '▶' : '${i + 1}'.padLeft(2, '0'),
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.accent
                                  : AppColors.textMuted,
                              fontSize: 13,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // название трека
                        Expanded(
                          child: Text(
                            track.title,
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.accent
                                  : AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),

                        // длительность (примерная)
                        Text(
                          '3:00',
                          style: TextStyle(
                            color: isActive
                                ? AppColors.accent
                                : AppColors.textMuted,
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: playlist.tracks.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}