import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import 'package:nanonime/data/services/anime_service.dart';
import 'package:nanonime/data/services/manga_service.dart';
import 'package:nanonime/data/models/anime.dart';
import 'package:nanonime/ui/widgets/proxy_image.dart';
import 'package:nanonime/ui/widgets/bouncing_button.dart';
import '../anime/anime_detail.dart';
import '../manga/manga_detail.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // 0 = Anime, 1 = Manga
  int _selectedMode = 0;

  // 0 = Mon, 1 = Tue, ... 6 = Sun
  int _selectedDayIndex = DateTime.now().weekday - 1;

  final List<String> _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  // Map to API day names (Indonesian for Otakudesu)
  final List<String> _fullDays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  final TextEditingController _searchController = TextEditingController();

  final ApiService _animeService = ApiService();
  final MangaService _mangaService = MangaService();

  Future<List<Anime>>? _rankingAnimeFuture;
  Future<List<AnimeScheduleDay>>? _animeScheduleFuture;
  Future<List<dynamic>>? _animeGenresFuture; // New

  Future<List<dynamic>>? _rankingMangaFuture;
  Future<List<dynamic>>? _mangaUpdatesFuture;
  Future<List<dynamic>>? _mangaGenresFuture; // New

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _rankingAnimeFuture = _animeService.fetchOngoingAnimeSlider();
      _animeScheduleFuture = _animeService.fetchSchedule();
      _animeGenresFuture = _animeService.fetchGenres();

      _rankingMangaFuture = _mangaService.fetchMangaList(page: 1); // Popular
      _mangaUpdatesFuture = _mangaService.fetchLatestManga(page: 1); // Latest
      _mangaGenresFuture = _mangaService.fetchGenres();
    });
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
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // Sticky Search & Toggle (Outer Header)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (val) => setState(
                          () => _searchQuery = val,
                        ), // Trigger search
                        decoration: InputDecoration(
                          hintText: 'Cari judul, genre, atau studio...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Toggle Switch
                    Container(
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(child: _buildToggleOption('Anime', 0)),
                          Expanded(child: _buildToggleOption('Manga', 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: _searchQuery.isNotEmpty
              ? _buildSearchResults()
              : CustomScrollView(
                  slivers: _selectedMode == 0
                      ? _buildAnimeSlivers()
                      : _buildMangaSlivers(),
                ),
        ),
      ),
    );
  }

  Widget _buildToggleOption(String label, int index) {
    final isSelected = _selectedMode == index;
    return BouncingButton(
      scale: 0.95,
      onTap: () => setState(() => _selectedMode = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final isAnime = _selectedMode == 0;
    final future = isAnime
        ? _animeService.searchAnime(_searchQuery)
        : _mangaService.searchManga(_searchQuery);

    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No results found for "$_searchQuery"',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            String title = '';
            String image = '';
            String extra = '';

            if (isAnime && item is Anime) {
              title = item.title;
              image = item.poster;
              extra = item.episodes;
            } else if (item is Map) {
              title = item['title'] ?? 'Unknown';
              image = item['thumb'] ?? '';
              extra = item['type'] ?? 'Manga';
            }

            return _buildDetailedCard(
              title: title,
              infoPrefix: isAnime ? 'Anime' : 'Manga',
              chapterInfo: extra,
              imageUrl: image,
              timeRel: '',
              isAnime: isAnime,
              onTap: () {
                if (isAnime && item is Anime) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnimeDetailScreen(id: item.animeId),
                    ),
                  );
                } else if (item is Map && item['endpoint'] != null) {
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
            );
          },
        );
      },
    );
  }

  // --- ANIME SLIVERS ---
  List<Widget> _buildAnimeSlivers() {
    return [
      // 1. Top Section (Ranking & Genres) - Scrolls away
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Trending
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Trending',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 240,
                child: FutureBuilder<List<Anime>>(
                  future: _rankingAnimeFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildMockRankingList(
                        isManga: false,
                      ); // Fallback to mock if empty/error
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final anime = snapshot.data![index];
                        return _buildRankedCard(
                          index + 1,
                          anime.title,
                          anime.episodes.isNotEmpty ? anime.episodes : 'Anime',
                          anime.poster,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AnimeDetailScreen(id: anime.animeId),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Genres
              const Text(
                'Browse by Genre',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FutureBuilder<List<dynamic>>(
                    future: _animeGenresFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final list = snapshot.data!
                          .take(14)
                          .toList(); // Limit for UI tidiness
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: list.map((g) {
                          final name = g is String
                              ? g
                              : (g['title'] ?? g['genre_name'] ?? 'Unknown');
                          return _buildGenreChip(name);
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // 2. Sticky Header (Schedule Title + Tabs)
      SliverPersistentHeader(
        pinned: true,
        delegate: _SectionHeaderDelegate(
          height: 100, // Taller for title + tabs
          child: Container(
            color: AppColors
                .background, // Opaque background to hide content under it
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Airing Schedule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _days.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedDayIndex == index;
                      return BouncingButton(
                        scale: 0.9,
                        onTap: () => setState(() => _selectedDayIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(100),
                            border: isSelected
                                ? null
                                : Border.all(color: Colors.white12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _days[index].toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 3. Scrollable List (The Data)
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        sliver: FutureBuilder<List<AnimeScheduleDay>>(
          future: _animeScheduleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            List<AnimeScheduleItem> items = [];
            if (snapshot.hasData) {
              // Filter by day
              final targetDay = _fullDays[_selectedDayIndex];
              final dayData = snapshot.data!.firstWhere(
                (d) => d.title.toLowerCase() == targetDay.toLowerCase(),
                orElse: () => AnimeScheduleDay(title: '', animeList: []),
              );
              items = dayData.animeList;
            }

            if (items.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                    child: Text(
                      "No schedule for this day",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = items[index];
                return _buildDetailedCard(
                  title: item.title,
                  infoPrefix: 'Today', // API doesn't give time, sadly
                  chapterInfo: 'New Episode',
                  imageUrl:
                      '', // API doesn't give image in schedule list usually, might need placeholders or fetch detail?
                  // Using empty triggers placeholder in widget
                  isAnime: true,
                  timeRel: 'Scheduled',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnimeDetailScreen(id: item.animeId),
                    ),
                  ),
                );
              }, childCount: items.length),
            );
          },
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 80)),
    ];
  }

  // --- MANGA SLIVERS ---
  List<Widget> _buildMangaSlivers() {
    return [
      // 1. Top Section (Ranking & Genres)
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Most Read
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Most Read This Week',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 240,
                child: FutureBuilder<List<dynamic>>(
                  future: _rankingMangaFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildMockRankingList(isManga: true);
                    }
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final m = snapshot.data![index];
                        final title = m['title'] ?? 'Unknown';
                        final chapter = m['chapter'] ?? 'Manga';
                        final thumb = m['thumb'] ?? '';
                        final endpoint = m['endpoint'] ?? '';
                        return _buildRankedCard(
                          index + 1,
                          title,
                          chapter,
                          thumb,
                          isManga: true,
                          onTap: endpoint.isNotEmpty
                              ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MangaDetailScreen(
                                      endpoint: endpoint,
                                      title: title,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Genres
              const Text(
                'Browse Genres',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FutureBuilder<List<dynamic>>(
                    future: _mangaGenresFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final list = snapshot.data!.take(14).toList();
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: list.map((g) {
                          final name = g is String
                              ? g
                              : (g['title'] ?? g['genre_name'] ?? 'Unknown');
                          return _buildGenreChip(name);
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // 2. Sticky Header (Latest Updates Title)
      SliverPersistentHeader(
        pinned: true,
        delegate: _SectionHeaderDelegate(
          height: 60,
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Latest Updates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons.access_time_filled_rounded,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),

      // 3. Manga List
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        sliver: FutureBuilder<List<dynamic>>(
          future: _mangaUpdatesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            if (!snapshot.hasData || snapshot.data!.isEmpty)
              return const SliverToBoxAdapter(child: SizedBox());

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final m = snapshot.data![index];
                final endpoint = m['endpoint'] ?? '';
                return _buildDetailedCard(
                  title: m['title'] ?? 'Unknown',
                  infoPrefix: m['type'] ?? 'Manga',
                  chapterInfo: m['chapter'] ?? 'New',
                  imageUrl: m['thumb'] ?? '',
                  isAnime: false,
                  timeRel: m['upload_on'] ?? 'Just now',
                  onTap: endpoint.isNotEmpty
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MangaDetailScreen(
                              endpoint: endpoint,
                              title: m['title'],
                            ),
                          ),
                        )
                      : null,
                );
              }, childCount: snapshot.data!.length),
            );
          },
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 80)),
    ];
  }

  // --- Widgets ---

  Widget _buildMockRankingList({required bool isManga}) {
    return ListView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      children: [
        _buildRankedCard(1, 'Loading...', '...', '', isManga: isManga),
        const SizedBox(width: 16),
        _buildRankedCard(2, 'Loading...', '...', '', isManga: isManga),
      ],
    );
  }

  // --- NEW: Detailed Card (Reference Style) ---
  Widget _buildDetailedCard({
    required String title,
    required String infoPrefix, // e.g. "Manhwa" or Time "20:30"
    required String chapterInfo, // e.g. "Chapter 101"
    required String imageUrl,
    required String timeRel, // e.g. "36 mins ago"
    required bool isAnime,
    VoidCallback? onTap,
  }) {
    return BouncingButton(
      scale: 0.98,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), // Gap between cards
        height: 120, // Clean fixed height
        color: Colors.transparent, // Hit test
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cover Image
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.card,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? ProxyImage(imageUrl: imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade800,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white24,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // 2. Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Metadata Row (Star, Type, Views..)
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '?.?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Type Flag/Icon
                      if (!isAnime) ...[
                        const Icon(
                          Icons.public,
                          color: Colors.grey,
                          size: 12,
                        ), // Placeholder for flag
                        const SizedBox(width: 4),
                        Text(
                          infoPrefix,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ] else ...[
                        Text(
                          infoPrefix,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.grey,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '--',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom Row (Status Badge + Chapter + Time)
                  Row(
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card, // Dark grey bg
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Ongoing',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Chapter/Ep
                      Expanded(
                        child: Text(
                          chapterInfo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Time
                      Text(
                        timeRel,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
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
    );
  }

  // --- VISUAL COMPONENTS (Unchanged Rank/Genre) ---
  Widget _buildRankedCard(
    int rank,
    String title,
    String badgeText,
    String imageUrl, {
    bool isManga = false,
    VoidCallback? onTap,
  }) {
    return BouncingButton(
      scale: 0.95,
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Card Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.card,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Placeholder/Proxy Image
                        imageUrl.isNotEmpty
                            ? ProxyImage(imageUrl: imageUrl, fit: BoxFit.cover)
                            : Container(color: Colors.grey.shade800),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Title & Date
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '27 Dec',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Space for the rank number overlap
              ],
            ),

            // Badge (Top Left)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Big Ranking Number (Bottom Right - Overlapping)
            Positioned(
              bottom: 0,
              right: -10,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  height: 1,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      color: Colors.black,
                      blurRadius: 0,
                    ), // Hard shadow
                    Shadow(
                      offset: const Offset(0, 0),
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 10,
                    ), // Soft glow
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreChip(String label) {
    return Chip(
      backgroundColor: AppColors.card,
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      side: const BorderSide(color: Colors.white10),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

// Sticky Header Delegate Class
class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SectionHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _SectionHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
