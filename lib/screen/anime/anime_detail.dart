import 'package:flutter/material.dart';
import '../../styles/colors.dart';
import '../../models/anime.dart';
import '../../services/anime.service.dart';
import '../episode/episode_watch.dart';

class AnimeDetailScreen extends StatefulWidget {
  final String id;
  const AnimeDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  late Future<AnimeDetail> animeDetailFuture;

  @override
  void initState() {
    super.initState();
    animeDetailFuture = ApiService().fetchAnimeDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Detail Anime'),
        elevation: 0,
      ),
      body: FutureBuilder<AnimeDetail>(
        future: animeDetailFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // Show a more descriptive error and a retry button
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Gagal memuat detail anime.",
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // retry the request
                        setState(() {
                          animeDetailFuture = ApiService().fetchAnimeDetail(
                            widget.id,
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Handle case where API returned no data gracefully
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'No data available for this anime.',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            );
          }

          final anime = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster & Judul
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: anime.poster.isNotEmpty
                        ? Image.network(
                            anime.poster,
                            width: 180,
                            height: 240,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 180,
                              height: 240,
                              color: Colors.grey.shade800,
                              child: const Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            width: 180,
                            height: 240,
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.broken_image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  anime.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
                if (anime.japanese.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 8),
                    child: Text(
                      anime.japanese,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                // Info Bar
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _InfoChip(label: "Type", value: anime.type),
                    _InfoChip(label: "Status", value: anime.status),
                    _InfoChip(label: "Episodes", value: anime.episodes),
                    _InfoChip(label: "Aired", value: anime.aired),
                    _InfoChip(label: "Duration", value: anime.duration),
                    _InfoChip(label: "Studios", value: anime.studios),
                    _InfoChip(label: "Producers", value: anime.producers),
                  ],
                ),
                const SizedBox(height: 14),
                // Genre
                if (anime.genres.isNotEmpty) ...[
                  const Text(
                    "Genre",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: anime.genres
                        .map(
                          (g) => Chip(
                            label: Text(g.title),
                            backgroundColor: AppColors.card,
                            labelStyle: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                ],
                // Sinopsis
                const Text(
                  "Sinopsis",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 6),
                ...anime.synopsis.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      p,
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Episode List
                if (anime.episodesList.isNotEmpty) ...[
                  const Text(
                    "Episode List",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: anime.episodesList.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, idx) {
                      final ep = anime.episodesList[idx];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Episode ${ep.title}",
                          style: const TextStyle(
                            color: AppColors.foreground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.play_circle_fill,
                          color: AppColors.primary,
                        ),
                        onTap: () {
                          // Try to navigate using episodeId first, otherwise extract id from otakudesuUrl
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EpisodeWatchScreen(episodeId: episodeId),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Episode id tidak tersedia'),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                ],
                // Rekomendasi Anime
                if (anime.recommendedAnimeList.isNotEmpty) ...[
                  const Text(
                    "Rekomendasi Anime",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: anime.recommendedAnimeList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, idx) {
                        final rec = anime.recommendedAnimeList[idx];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AnimeDetailScreen(id: rec.animeId),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    rec.poster,
                                    width: 120,
                                    height: 160,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 120,
                                      height: 160,
                                      color: Colors.grey.shade800,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  rec.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.foreground,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty || value == "Unknown") return const SizedBox.shrink();
    return Chip(
      label: Text("$label: $value"),
      backgroundColor: AppColors.card,
      labelStyle: const TextStyle(
        color: AppColors.foreground,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
