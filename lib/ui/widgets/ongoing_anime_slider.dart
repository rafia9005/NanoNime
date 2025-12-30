import 'package:flutter/material.dart';
import 'package:nanonime/ui/widgets/proxy_image.dart';
import 'package:nanonime/data/services/anime_service.dart';
import '../../data/models/anime.dart';
import '../../core/router/app_router.dart';
import 'dart:async';

class OngoingAnimeSlider extends StatefulWidget {
  const OngoingAnimeSlider({super.key});

  @override
  State<OngoingAnimeSlider> createState() => _OngoingAnimeSliderState();
}

class _OngoingAnimeSliderState extends State<OngoingAnimeSlider> {
  final ApiService _apiService = ApiService();
  List<Anime> _ongoing = [];
  int _current = 0;
  Timer? _timer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOngoing();
  }

  Future<void> _fetchOngoing() async {
    setState(() => _loading = true);
    try {
      final list = await _apiService.fetchOngoingAnimeSlider();
      setState(() {
        _ongoing = list;
        _loading = false;
      });
      _startAutoSlide();
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _startAutoSlide() {
    _timer?.cancel();
    if (_ongoing.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() {
        _current = (_current + 1) % _ongoing.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_ongoing.isEmpty) return const SizedBox.shrink();

    final anime = _ongoing[_current];
    return GestureDetector(
      onTap: () {
        AppRouter.toAnimeDetail(context, animeId: anime.animeId);
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: ProxyImage.provider(anime.poster),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anime.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'EP ${anime.episodes} • ${anime.latestReleaseDate}',
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
