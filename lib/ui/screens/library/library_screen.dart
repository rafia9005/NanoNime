import 'package:flutter/material.dart';
import 'package:nanonime/core/theme/colors.dart';
import 'package:nanonime/data/models/anime.dart';
import 'package:nanonime/ui/widgets/bouncing_button.dart';
import 'package:nanonime/ui/widgets/proxy_image.dart';
import '../../widgets/custom_tab_selector.dart';
import 'package:nanonime/ui/screens/anime/anime_detail.dart';
import 'package:nanonime/ui/screens/manga/manga_detail.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _favSearchController = TextEditingController();

  // Dummy Data for Favorites
  List<dynamic> _favorites = []; // Will be populated in initState
  List<dynamic> _filteredFavorites = [];
  String _sortOption = 'Recently Added';

  // Dummy Data for History
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _populateDummyData();
    _tabController.addListener(() {
      setState(() {});
    });
  }

  void _populateDummyData() {
    // Mock data based on Anime model structure
    final dummyAnime = [
      Anime(
        title: 'One Piece',
        poster: 'https://cdn.myanimelist.net/images/anime/6/73245.jpg',
        episodes: 'Ep 1080',
        animeId: 'one-piece',
        latestReleaseDate: 'Today',
      ),
      Anime(
        title: 'Jujutsu Kaisen',
        poster: 'https://cdn.myanimelist.net/images/anime/1171/109222.jpg',
        episodes: 'Ep 45',
        animeId: 'jujutsu-kaisen',
        latestReleaseDate: 'Yesterday',
      ),
      Anime(
        title: 'Frieren: Beyond Journey\'s End',
        poster: 'https://cdn.myanimelist.net/images/anime/1015/138006.jpg',
        episodes: 'Ep 16',
        animeId: 'sousou-no-frieren',
        latestReleaseDate: '2 days ago',
      ),
      Anime(
        title: 'Solo Leveling',
        poster: 'https://cdn.myanimelist.net/images/manga/3/222295.jpg',
        episodes: 'Ch 179',
        animeId: 'solo-leveling',
        latestReleaseDate: 'Completed',
      ), // Pretending Manga
    ];

    // Mark last one as Manga via some property if needed, but for now mixing them is fine as 'dynamic'
    // Actually let's make a Map for flexibility
    _favorites = [
      {
        'data': dummyAnime[0],
        'isManga': false,
        'added': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'data': dummyAnime[1],
        'isManga': false,
        'added': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'data': dummyAnime[2],
        'isManga': false,
        'added': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'data': dummyAnime[3],
        'isManga': true,
        'added': DateTime.now().subtract(const Duration(days: 0)),
      }, // Newest
      // ... duplicate to fill grid
      {
        'data': dummyAnime[0],
        'isManga': false,
        'added': DateTime.now().subtract(const Duration(days: 10)),
      },
      {
        'data': dummyAnime[1],
        'isManga': false,
        'added': DateTime.now().subtract(const Duration(days: 12)),
      },
    ];

    _history = [
      {'data': dummyAnime[3], 'isManga': true, 'progress': 'Ch 150/179'},
      {'data': dummyAnime[0], 'isManga': false, 'progress': 'Ep 1010/1080'},
      {'data': dummyAnime[2], 'isManga': false, 'progress': 'Ep 10/28'},
    ];

    _filterFavorites();
  }

  void _filterFavorites() {
    String query = _favSearchController.text.toLowerCase();

    // Filter
    var temp = _favorites.where((item) {
      final anime = item['data'] as Anime;
      return anime.title.toLowerCase().contains(query);
    }).toList();

    // Sort
    if (_sortOption == 'A-Z') {
      temp.sort(
        (a, b) =>
            (a['data'] as Anime).title.compareTo((b['data'] as Anime).title),
      );
    } else if (_sortOption == 'Z-A') {
      temp.sort(
        (a, b) =>
            (b['data'] as Anime).title.compareTo((a['data'] as Anime).title),
      );
    } else {
      // Recently Added (Newest First)
      temp.sort(
        (a, b) => (b['added'] as DateTime).compareTo(a['added'] as DateTime),
      );
    }

    setState(() {
      _filteredFavorites = temp;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _favSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Title and Tabs
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search & Sort Bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _favSearchController,
                            onChanged: (_) => _filterFavorites(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(
                                Icons.search,
                                size: 20,
                                color: Colors.grey,
                              ),
                              hintText: 'Search favorites...',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Sort Button
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            _sortOption = value;
                            _filterFavorites();
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'Recently Added',
                            child: Text('Recently Added'),
                          ),
                          const PopupMenuItem(value: 'A-Z', child: Text('A-Z')),
                          const PopupMenuItem(value: 'Z-A', child: Text('Z-A')),
                        ],
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.sort_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTabSelector(
                    tabs: const ['Favorites', 'History'],
                    selectedIndex: _tabController.index,
                    onTabSelected: (index) => _tabController.animateTo(index),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildFavoritesTab(), _buildHistoryTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.68, // Portrait aspect ratio
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
      ),
      itemCount: _filteredFavorites.length,
      itemBuilder: (context, index) {
        final item = _filteredFavorites[index];
        final anime = item['data'] as Anime;
        final isManga = item['isManga'] as bool;

        return BouncingButton(
          onTap: () {
            if (isManga) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MangaDetailScreen(
                    endpoint: anime.animeId,
                    title: anime.title,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnimeDetailScreen(id: anime.animeId),
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ProxyImage(
                        imageUrl: anime.poster,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (isManga)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'MANGA',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                anime.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = _history[index];
        final anime = item['data'] as Anime;
        final isManga = item['isManga'] as bool;
        final progress = item['progress'] as String;

        return BouncingButton(
          onTap: () {
            if (isManga) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MangaDetailScreen(
                    endpoint: anime.animeId,
                    title: anime.title,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnimeDetailScreen(id: anime.animeId),
                ),
              );
            }
          },
          child: AspectRatio(
            aspectRatio: 16 / 7, // Wide Card
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProxyImage(imageUrl: anime.poster, fit: BoxFit.cover),
                  // Dark Overlay
                  Container(color: Colors.black.withOpacity(0.6)),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 80,
                            height: 120,
                            child: ProxyImage(
                              imageUrl: anime.poster,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                anime.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isManga ? 'Manga' : 'Anime',
                                style: TextStyle(
                                  color: isManga
                                      ? Colors.orange
                                      : AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Continued at $progress',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Progress Bar (Fake)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: 0.7, // Dummy value
                                  backgroundColor: Colors.white24,
                                  color: AppColors.primary,
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
