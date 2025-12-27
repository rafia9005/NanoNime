import 'package:flutter/material.dart';
import 'package:nanonime/ui/widgets/proxy_image.dart';
import '../../data/models/anime.dart';
import '../../core/theme/colors.dart';

/// Reusable Anime card used in grid/list views.
///
/// - `anime`: domain model containing title, poster, episodes, animeId, latestReleaseDate.
/// - `onTap`: optional callback when card is tapped.
class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onTap;

  const AnimeCard({Key? key, required this.anime, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double titleFontSize = width < 340 ? 11 : 12;

    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: AppColors.card,
        elevation: 3,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Poster area
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ProxyImage(
                      imageUrl: anime.poster,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Episode badge in corner
                  Positioned(
                    top: 8,
                    left: 8,
                    child: EpisodeBadge(episode: anime.episodes),
                  ),
                  // Optional bottom fade for readability (small)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 36,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title and meta
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                        height: 1.18,
                      ),
                    ),
                    const Spacer(),
                    // Release date / meta row
                    if (anime.latestReleaseDate != "" &&
                        anime.latestReleaseDate.trim().isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 11,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              anime.latestReleaseDate,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small badge to display episode count/label.
///
/// If `episode` is empty or "Unknown" it will still render but can be
/// easily customized to hide for unknown values.
class EpisodeBadge extends StatelessWidget {
  final String episode;

  const EpisodeBadge({Key? key, required this.episode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double fontSize = width < 340 ? 8 : 9;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'EP $episode',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Simple episode list tile used in anime detail page.
/// Displays episode title and provides a trailing action indicator.
class EpisodeTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final String? subtitle;
  final IconData leadingIcon;

  const EpisodeTile({
    Key? key,
    required this.title,
    this.onTap,
    this.subtitle,
    this.leadingIcon = Icons.play_circle_fill,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(leadingIcon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.foreground,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
