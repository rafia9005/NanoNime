import 'package:flutter/material.dart';
import 'package:nanonime/data/services/anime_service.dart';
import '../../data/models/anime.dart';
import '../../core/theme/colors.dart';
import '../../core/router/app_router.dart';
import '../widgets/anime_card.dart';
import '../widgets/loading_grid.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<List<Anime>>? animeListFuture;
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSearching = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    animeListFuture = _apiService.fetchOngoingAnime();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentQuery = query;
      if (query.isEmpty) {
        _isSearching = false;
        animeListFuture = _apiService.fetchOngoingAnime();
      } else {
        _isSearching = true;
        animeListFuture = _apiService.searchAnime(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _currentQuery = '';
      animeListFuture = _apiService.fetchOngoingAnime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double maxCrossAxisExtent = screenWidth > 400 ? 180 : screenWidth / 2 - 20;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      const Text(
                        'Nanonime',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'v1.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search bar
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColors.foreground),
                    decoration: InputDecoration(
                      hintText: 'Search anime...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: _clearSearch,
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 12),
                  // Results info
                  if (_isSearching && _currentQuery.isNotEmpty)
                    Text(
                      'Search results for "$_currentQuery"',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    )
                  else
                    const Text(
                      'Ongoing Anime',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            // Anime Grid
            Expanded(
              child: animeListFuture == null
                  ? const Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<Anime>>(
                      future: animeListFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return LoadingGrid(
                            maxCrossAxisExtent: maxCrossAxisExtent,
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Failed to load anime",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _getCleanErrorMessage(snapshot.error!),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          );
                        }

                        final animes = snapshot.data!;

                        if (animes.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _isSearching
                                      ? 'No results found for "$_currentQuery"'
                                      : 'No anime available',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_isSearching) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try a different search term',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: maxCrossAxisExtent,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.55,
                              ),
                          itemCount: animes.length,
                          itemBuilder: (context, index) {
                            final anime = animes[index];
                            return AnimeCard(
                              anime: anime,
                              onTap: () {
                                AppRouter.toAnimeDetail(
                                  context,
                                  animeId: anime.animeId,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

String _getCleanErrorMessage(Object error) {
  final errorString = error.toString();
  // Extract clean message from "Exception: message" format
  if (errorString.startsWith('Exception: ')) {
    final message = errorString.substring('Exception: '.length);
    // Extract status code if present (e.g., "404 Not Found")
    final statusMatch = RegExp(r'(\d{3}\s+[\w\s]+)').firstMatch(message);
    if (statusMatch != null) {
      return statusMatch.group(1) ?? message;
    }
    return message;
  }
  return errorString;
}
