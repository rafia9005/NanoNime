import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nanonime/data/models/manga.dart';
import 'package:nanonime/providers/manga_provider.dart';
import 'package:nanonime/ui/screens/manga/manga_detail.dart';
import 'package:nanonime/ui/widgets/proxy_image.dart';

class MangaScreen extends StatelessWidget {
  const MangaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MangaProvider()..fetchMangaList(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Popular Manga')),
        body: Consumer<MangaProvider>(
          builder: (context, provider, _) {
            final scrollController = ScrollController();

            scrollController.addListener(() {
              if (scrollController.position.pixels >=
                      scrollController.position.maxScrollExtent - 200 &&
                  !provider.isLoadingMore &&
                  provider.hasMore) {
                provider.fetchNextPage();
              }
            });

            if (provider.state == MangaState.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.state == MangaState.error) {
              return Center(child: Text(provider.errorMessage ?? 'Error'));
            }

            final crossAxisCount = MediaQuery.of(context).size.width > 600
                ? 4
                : 2;

            return Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      itemCount: provider.mangaList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3 / 5.4,
                      ),
                      itemBuilder: (context, index) {
                        final Manga manga = provider.mangaList[index];

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
                                        child: ProxyImage(
                                          imageUrl: manga.thumb,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
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
                                            color: Colors.black.withOpacity(
                                              0.7,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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

                                SizedBox(
                                  height: 38,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      10,
                                      8,
                                      10,
                                      0,
                                    ),
                                    child: Text(
                                      manga.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 34,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      manga.sortDesc,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    4,
                                    10,
                                    8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 12,
                                        color: Colors.grey.shade500,
                                      ),
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
                      },
                    ),
                  ),
                  if (provider.isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
