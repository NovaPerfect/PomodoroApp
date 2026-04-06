import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'playlist_detail_screen.dart';
import 'package:untitled/l10n/app_localizations.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final _audio = AudioService();

  final List<PlaylistModel> _playlists = [
    PlaylistModel(
      name: 'Genshin Music',
      imagePath: 'assets/images/playlist1.jpg',
      tracks: const [
        TrackModel(title: 'Legend of the Wind', artist: 'Hoyo-Mix', assetPath: 'assets/music/track1.ogg'),
        TrackModel(title: 'Twinlight Serenity', artist: 'Genshin Impact', assetPath: 'assets/music/track2.ogg'),
      ],
    ),
    PlaylistModel(
      name: 'Anime Beats',
      imagePath: 'assets/images/playlist2.jpg',
      tracks: const [
        TrackModel(title: 'Sakura Evening',  artist: 'Anime Beats', assetPath: 'assets/music/track3.mp3'),
        TrackModel(title: 'Study Session',   artist: 'Anime Beats', assetPath: 'assets/music/track4.mp3'),
      ],
    ),
    PlaylistModel(
      name: 'Focus Mode',
      imagePath: 'assets/images/playlist3.jpg',
      tracks: const [
        TrackModel(title: 'Deep Focus',      artist: 'Chill Hop',   assetPath: 'assets/music/track5.mp3'),
        TrackModel(title: 'Midnight Work',   artist: 'Chill Hop',   assetPath: 'assets/music/track6.mp3'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _audio.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.music,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.musicSubtitle,
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _PlaylistCard(
                  playlist: _playlists[i],
                  isPlaying: _audio.playlistName == _playlists[i].name && _audio.isPlaying,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(playlist: _playlists[i]),
                    ),
                  ),
                  onPlay: () {
                    if (_audio.playlistName == _playlists[i].name && _audio.isPlaying) {
                      _audio.playPause();
                    } else {
                      _audio.playPlaylist(_playlists[i]);
                    }
                  },
                ),
                childCount: _playlists.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const _PlaylistCard({
    required this.playlist,
    required this.isPlaying,
    required this.onTap,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPlaying ? AppColors.accent.withValues(alpha: 0.6) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isPlaying
              ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.2), blurRadius: 20)]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                playlist.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context2, err, stack) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.accent2, AppColors.accent]),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '${playlist.tracks.length} tracks  ·  ~${playlist.totalMinutes} min',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onPlay,
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPlaying ? AppColors.accent : Colors.white.withValues(alpha: 0.2),
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
