import 'package:flutter/material.dart';
import 'package:nanonime/utils/fetch.dart';
import 'dart:convert';

class MangaReadScreen extends StatefulWidget {
  final String chapterEndpoint;
  final String title;
  const MangaReadScreen({
    Key? key,
    required this.chapterEndpoint,
    required this.title,
  }) : super(key: key);

  @override
  State<MangaReadScreen> createState() => _MangaReadScreenState();
}

class _MangaReadScreenState extends State<MangaReadScreen> {
  Map<String, dynamic>? chapter;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchChapter();
  }

  Future<void> fetchChapter() async {
    try {
      final response = await Fetch.get('/chapter/${widget.chapterEndpoint}');
      if (response.statusCode == 200) {
        setState(() {
          chapter = jsonDecode(response.body);
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null || chapter == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(error ?? 'No data')),
      );
    }
    final images = chapter!['chapter_image'] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title.isNotEmpty
              ? widget.title
              : chapter!['chapter_name'] ?? '',
        ),
      ),
      body: ListView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          final img = images[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Image.network(
              img['chapter_image_link'],
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 48),
              ),
            ),
          );
        },
      ),
    );
  }
}
