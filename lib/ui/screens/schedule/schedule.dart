import 'package:flutter/material.dart';
import 'package:nanonime/core/theme/colors.dart';
import 'package:nanonime/core/router/app_router.dart';
import 'package:nanonime/data/models/anime.dart';
import 'package:nanonime/data/repositories/anime_repository.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  Future<List<AnimeScheduleDay>>? _scheduleFuture;
  final AnimeRepository _repository = AnimeRepository();

  @override
  void initState() {
    super.initState();
    _scheduleFuture = _repository.getSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        title: const Text(
          'Anime Schedule',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: FutureBuilder<List<AnimeScheduleDay>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load schedule',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            );
          }
          final days = snapshot.data ?? [];
          if (days.isEmpty) {
            return Center(
              child: Text(
                'No schedule available',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: days.length,
            itemBuilder: (context, dayIdx) {
              final day = days[dayIdx];
              return Card(
                color: AppColors.card,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.title,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...day.animeList.map(
                        (anime) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            anime.title,
                            style: const TextStyle(
                              color: AppColors.foreground,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.primary,
                          ),
                          onTap: () {
                            AppRouter.toAnimeDetail(
                              context,
                              animeId: anime.animeId,
                            );
                          },
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
    );
  }
}
