import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nanonime/data/services/anime_service.dart';
import 'package:nanonime/data/services/manga_service.dart';
import '../../data/models/anime.dart';
import '../../core/theme/colors.dart';
import '../widgets/anime_card.dart';
import 'package:nanonime/ui/widgets/proxy_image.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Filter state
  int _selectedFilterIndex = 0; // 0: All, 1: Anime, 2: Manga
  final List<String> _filters = ['All', 'Anime', 'Manga'];

  // Data futures
  Future<List<Anime>>? _animeListFuture;
  Future<List<dynamic>>? _mangaListFuture;
  Future<List<dynamic>>? _displayDataFuture; // Combined/Filtered data for UI

  // Services
  final ApiService _animeService = ApiService();
  final MangaService _mangaService = MangaService();

  // Search state
  final TextEditingController _searchController = TextEditingController();
  // bool _isSearching = false; // Removed unused field

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    _animeListFuture = _animeService.fetchOngoingAnime();
    _mangaListFuture = _mangaService.fetchMangaList();
    _updateDisplayFuture();
  }

  void _updateDisplayFuture() {
    setState(() {
      _displayDataFuture = _computeCombinedData();
    });
  }

  Future<List<dynamic>> _computeCombinedData() async {
    final animeList = (await _animeListFuture) ?? [];
    final mangaList = (await _mangaListFuture) ?? [];

    if (_selectedFilterIndex == 1) {
      // Anime Only
      return List<dynamic>.from(animeList);
    } else if (_selectedFilterIndex == 2) {
      // Manga Only
      return List<dynamic>.from(mangaList);
    } else {
      // All - Interleave for Balance
      List<dynamic> mixed = [];
      int len = animeList.length > mangaList.length
          ? animeList.length
          : mangaList.length;
      for (int i = 0; i < len; i++) {
        if (i < animeList.length) mixed.add(animeList[i]);
        if (i < mangaList.length) mixed.add(mangaList[i]);
      }
      return mixed;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Header & Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NanoNime',
                          style: GoogleFonts.pixelifySans(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: AppColors.primary,
                          ),
                        ),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.card,
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search anime or manga...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Filter Tabs (Pill Style)
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 24),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilterIndex == index;
                    return GestureDetector(
                      onTap: () {
                        _selectedFilterIndex = index; // Update index
                        _updateDisplayFuture(); // Re-compute list (no network)
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 0,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(100),
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          _filters[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade400,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 3. Continue Watching (Wide Gradient Card)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Continue Watching',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pick up where you left off',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGradientContinueCard(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // 4. Featured / Fresh Picks (Balanced Mix)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fresh Picks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Recommended for you today',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: FutureBuilder<List<dynamic>>(
                      future: _displayDataFuture, // Use combined data
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final list = snapshot.data!
                            .take(6)
                            .toList(); // Show top 6 mixed items
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final item = list[index];
                            Anime animeData;
                            bool isMangaItem = false;

                            if (item is Anime) {
                              animeData = item;
                              isMangaItem = false;
                            } else {
                              // Map manga
                              animeData = Anime(
                                title: item['title'] ?? '',
                                poster: item['thumb'] ?? '',
                                episodes: item['type'] ?? 'Manga',
                                animeId: item['endpoint'] ?? '',
                                latestReleaseDate: '',
                              );
                              isMangaItem = true;
                            }
                            return _buildWideFeatureCard(
                              animeData,
                              isManga: isMangaItem,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // 5. Explore Collections
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Collections',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Explore by genre',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.category_outlined,
                          color: Colors.grey.shade600,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 60,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildGenreChip(
                          'Action',
                          AppColors.primary,
                          Icons.flash_on,
                        ),
                        const SizedBox(width: 12),
                        _buildGenreChip('Adventure', Colors.white, Icons.map),
                        const SizedBox(width: 12),
                        _buildGenreChip(
                          'Fantasy',
                          AppColors.primary,
                          Icons.auto_awesome,
                        ),
                        const SizedBox(width: 12),
                        _buildGenreChip(
                          'Romance',
                          Colors.white,
                          Icons.favorite,
                        ),
                        const SizedBox(width: 12),
                        _buildGenreChip(
                          'Sci-Fi',
                          AppColors.primary,
                          Icons.science,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // 6. Trending Now (Ranked List - Mixed)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFilterIndex == 2
                                  ? 'Trending Manga'
                                  : 'Trending Now',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Top hits this week',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.show_chart_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 280,
                    child: FutureBuilder<List<dynamic>>(
                      future: _displayDataFuture, // Combined Future
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        final list = snapshot.data!.take(10).toList();
                        return ListView.separated(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 24),
                          itemBuilder: (context, index) {
                            final item = list[index];
                            Anime animeData;
                            if (item is Anime) {
                              animeData = item;
                            } else {
                              animeData = Anime(
                                title: item['title'] ?? '',
                                poster: item['thumb'] ?? '',
                                episodes: item['type'] ?? 'Manga',
                                animeId: item['endpoint'] ?? '',
                                latestReleaseDate: '',
                              );
                            }

                            // Ranked Creative Card
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Card itself
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0,
                                    right: 0,
                                  ),
                                  child: SizedBox(
                                    width: 145,
                                    child: AnimeCard(anime: animeData),
                                  ),
                                ),

                                // Ranking Number Overlay (Right)
                                Positioned(
                                  bottom: -10,
                                  right: -5,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 85,
                                      fontWeight: FontWeight.w900,
                                      fontStyle: FontStyle.italic,
                                      height: 1,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(4, 4),
                                          color: Colors.black,
                                          blurRadius: 0,
                                        ),
                                        Shadow(
                                          offset: Offset(0, 0),
                                          color: AppColors.primary.withOpacity(
                                            0.5,
                                          ),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // 7. Latest Updates (Mixed List)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Just Updated',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Latest releases',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 140, // Smaller cards
                child: FutureBuilder<List<dynamic>>(
                  future: _displayDataFuture, // Combined Future
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final list = snapshot.data!
                        .skip(6)
                        .take(20)
                        .toList(); // Skip Fresh Picks area (roughly)
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        Anime animeData;
                        bool isManga = false;
                        if (item is Anime) {
                          animeData = item;
                          isManga = false;
                        } else {
                          animeData = Anime(
                            title: item['title'] ?? '',
                            poster: item['thumb'] ?? '',
                            episodes: item['type'] ?? 'Manga',
                            animeId: item['endpoint'] ?? '',
                            latestReleaseDate: '',
                          );
                          isManga = true;
                        }

                        return AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ProxyImage(
                                  imageUrl: animeData.poster,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0),
                                        Colors.black.withOpacity(0.9),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  right: 8,
                                  child: Text(
                                    animeData.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (isManga)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Manga',
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
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(top: 40, bottom: 90),
                child: Column(
                  children: [
                    const Divider(
                      color: Colors.white10,
                      thickness: 1,
                      indent: 80,
                      endIndent: 80,
                    ),
                    const SizedBox(height: 24),
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white24,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You've reached the end",
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

  // Helper Widget: Purple Gradient Card for "Continue Watching"
  Widget _buildGradientContinueCard() {
    return Container(
      width: double.infinity,
      height: 180, // Increased Height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 1. Background Image
            Positioned.fill(
              child: ProxyImage(
                imageUrl:
                    'https://otakudesu.best/wp-content/uploads/2022/07/One-Piece-Sub-Indo.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // 2. Gradient Overlay (Blended)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.9), // Strong Purple
                      Colors.black.withOpacity(0.95), // Fade to Black
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // 3. Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 70,
                      width: 70, // Bigger Icon BG
                      color: Colors.white10,
                      // Placeholder icon
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'One Piece',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22, // Bigger Title
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Episode 1089',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Progress Bar Indicator
                        Container(
                          height: 4,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.7,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Wide Feature Card (Text Left, Image Right)
  Widget _buildWideFeatureCard(Anime anime, {required bool isManga}) {
    return Container(
      width: 320, // Wider card
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 6, // More space for text
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        anime.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Tags/Badges
                      Wrap(
                        spacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(
                                0.2,
                              ), // Uniform Purple
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isManga ? 'Manga' : 'Anime',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 10, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  '8.5',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          isManga ? 'Read Now' : 'Watch Now', // Dynamic Text
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProxyImage(imageUrl: anime.poster, fit: BoxFit.cover),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.card, Colors.transparent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
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
