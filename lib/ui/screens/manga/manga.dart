import 'package:flutter/material.dart';
import 'package:nanonime/core/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:nanonime/data/models/manga.dart';
import 'package:nanonime/providers/manga_provider.dart';
import 'package:nanonime/ui/screens/manga/manga_detail.dart';

class MangaScreen extends StatelessWidget {
  const MangaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MangaProvider()..fetchMangaList(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.card,
          elevation: 0,
          title: const Text(
            'Popular Manga',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        body: Consumer<MangaProvider>(
          builder: (context, provider, _) {
            if (provider.state == MangaState.loading &&
                provider.mangaList.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.state == MangaState.error &&
                provider.mangaList.isEmpty) {
              return Center(child: Text(provider.errorMessage ?? 'Error'));
            }

            final crossAxisCount = MediaQuery.of(context).size.width > 600
                ? 4
                : 2;

            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200 &&
                    !provider.isLoadingMore &&
                    provider.hasMore) {
                  provider.fetchNextPage();
                }
                return true;
              },
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3 / 5.4,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final Manga manga = provider.mangaList[index];
                        return _buildMangaItem(context, manga);
                      }, childCount: provider.mangaList.length),
                    ),
                  ),

                  if (provider.isLoadingMore)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMangaItem(BuildContext context, Manga manga) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MangaDetailScreen(
                endpoint: manga.endpoint,
                title: manga.title,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      manga.thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        manga.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildTextSection(manga.title, 13, FontWeight.w600, 38, 8),
            _buildTextSection(
              manga.sortDesc,
              11,
              FontWeight.normal,
              34,
              0,
              color: Colors.grey.shade600,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      manga.uploadOn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
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

  Widget _buildTextSection(
    String text,
    double size,
    FontWeight weight,
    double height,
    double topPad, {
    Color? color,
  }) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, topPad, 10, 0),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: size,
            fontWeight: weight,
            height: 1.2,
            color: color,
          ),
        ),
      ),
    );
  }
}
