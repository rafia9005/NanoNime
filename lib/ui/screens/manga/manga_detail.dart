import 'package:flutter/material.dart';
import 'package:nanonime/ui/screens/manga/manga_read.dart';
import 'package:nanonime/utils/fetch.dart';
import 'package:nanonime/core/theme/colors.dart';
import 'dart:convert';

class MangaDetailScreen extends StatefulWidget {
  final String endpoint;
  final String? title;
  const MangaDetailScreen({Key? key, required this.endpoint, this.title})
    : super(key: key);

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  Map<String, dynamic>? manga;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchMangaDetail();
  }

  Future<void> fetchMangaDetail() async {
    try {
      final response = await Fetch.get('/manga/detail/${widget.endpoint}');
      if (response.statusCode == 200) {
        setState(() {
          manga = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed (${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null || manga == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: Center(
          child: Text(
            error ?? 'No data',
            style: const TextStyle(color: AppColors.foreground),
          ),
        ),
      );
    }

    final genres = manga!['genre_list'] ?? [];
    final chapters = manga!['chapter'] ?? [];
    final String displayTitle = widget.title ?? manga!['title'] ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          displayTitle,
          style: const TextStyle(color: AppColors.foreground),
        ),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      manga!['thumb'],
                      width: 120,
                      height: 170,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 170,
                        color: AppColors.muted,
                        child: const Icon(
                          Icons.broken_image,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            displayTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.foreground,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),

                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _chip(
                              "Author : ${manga!['status']}",
                              AppColors.secondary,
                              AppColors.secondaryForeground,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: genres
                              .map<Widget>(
                                (g) => _chip(
                                  g['genre_name'],
                                  AppColors.primary,
                                  AppColors.primaryForeground,
                                  subtle: true,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if ((manga!['synopsis'] ?? '').isNotEmpty)
              _section(
                'Synopsis',
                Text(
                  manga!['synopsis'],
                  style: const TextStyle(
                    color: AppColors.foreground,
                    height: 1.5,
                  ),
                ),
              ),

            _section(
              'Chapters',
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: chapters.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      chapter['chapter_title'],
                      style: const TextStyle(
                        color: AppColors.foreground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.mutedForeground,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MangaReadScreen(
                            chapterEndpoint: chapter['chapter_endpoint'],
                            title: manga!['title'] ?? '',
                          ),
                        ),
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

  Widget _section(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.foreground,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _chip(String? text, Color bg, Color fg, {bool subtle = false}) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: subtle ? bg.withOpacity(0.15) : bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
