import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nanonime/core/theme/colors.dart';
import 'package:nanonime/data/models/anime.dart';
import 'package:nanonime/data/services/anime_service.dart';
import 'package:nanonime/data/services/manga_service.dart';
import 'package:nanonime/ui/widgets/bouncing_button.dart';
import 'package:nanonime/ui/widgets/proxy_image.dart';
import 'anime/anime_detail.dart';
import 'manga/manga_detail.dart';

class AppSearchDelegate extends SearchDelegate {
  final ApiService _apiService = ApiService();
  final MangaService _mangaService = MangaService();

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        Theme.of(context).textTheme,
      ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary,
        selectionHandleColor: AppColors.primary,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text(
          'Type to search...',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    // robust search that ignores errors from one source if the other succeeds
    final animeFuture = _apiService.searchAnime(query).onError((_, __) => []);
    final mangaFuture = _mangaService.searchManga(query).onError((_, __) => []);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([animeFuture, mangaFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // No explicit error check needed as we catch errors above.
        // But if strict mode, we can check snapshot.hasError

        final animeList = (snapshot.data?[0] as List<Anime>?) ?? [];
        final mangaList = (snapshot.data?[1] as List<dynamic>?) ?? [];
        final combined = [...animeList, ...mangaList];

        if (combined.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No results found',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: combined.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = combined[index];
            final isAnime = item is Anime;

            final title = isAnime ? item.title : (item['title'] ?? 'Unknown');
            final image = isAnime ? item.poster : (item['thumb'] ?? '');
            final type = isAnime ? 'Anime' : 'Manga';
            final color = isAnime ? AppColors.primary : Colors.orange;

            return BouncingButton(
              onTap: () {
                if (isAnime) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnimeDetailScreen(id: item.animeId),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MangaDetailScreen(
                        endpoint: item['endpoint'],
                        title: title,
                      ),
                    ),
                  );
                }
              },
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: SizedBox(
                        width: 80,
                        height: double.infinity,
                        child: ProxyImage(imageUrl: image, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                height: 1.2,
                              ),
                            ),
                            const Spacer(),
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Arrow
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
