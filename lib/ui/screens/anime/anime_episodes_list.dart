import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../data/models/anime.dart';
import '../../../core/router/app_router.dart';

class AnimeEpisodesScreen extends StatelessWidget {
  final List<EpisodeInfo> episodes;
  final String animeTitle;

  const AnimeEpisodesScreen({
    Key? key,
    required this.episodes,
    required this.animeTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Episodes - $animeTitle'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: episodes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ep = episodes[index];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                ep.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  _navigateToEpisode(context, ep);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
                ),
                child: const Text('Play'),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToEpisode(BuildContext context, EpisodeInfo ep) {
    String episodeId = '';
    if (ep.episodeId.isNotEmpty) {
      episodeId = ep.episodeId;
    } else if (ep.otakudesuUrl.isNotEmpty) {
      final uri = Uri.tryParse(ep.otakudesuUrl);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        episodeId = uri.pathSegments.last;
      }
    }

    if (episodeId.isNotEmpty) {
      AppRouter.toEpisodeWatch(context, episodeId: episodeId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Episode id tidak tersedia')),
      );
    }
  }
}
