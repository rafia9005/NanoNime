import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/colors.dart';
import '../../../data/models/anime.dart';
import '../../../data/services/anime_service.dart';
import '../../../core/router/app_router.dart';

/// Modern Clean Episode Watch Screen
class EpisodeWatchScreen extends StatefulWidget {
  final String episodeId;
  const EpisodeWatchScreen({Key? key, required this.episodeId})
    : super(key: key);

  @override
  State<EpisodeWatchScreen> createState() => _EpisodeWatchScreenState();
}

class _EpisodeWatchScreenState extends State<EpisodeWatchScreen> {
  late Future<EpisodeDetail> _episodeFuture;
  final ApiService _api = ApiService();

  // WebView state
  WebViewController? _webViewController;
  bool _isLoadingVideo = false;
  String? _currentServerId;
  String _currentServerTitle = '';
  bool _hasLoadedVideo = false;

  @override
  void initState() {
    super.initState();
    _episodeFuture = _api.fetchEpisodeDetail(widget.episodeId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadWebViewUrl(String url, String serverTitle) async {
    if (url.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingVideo = true;
      _currentServerTitle = serverTitle;
    });

    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              setState(() {
                _isLoadingVideo = false;
                _hasLoadedVideo = true;
              });
            },
            onWebResourceError: (WebResourceError error) {
              // Silently handle webview errors
              if (mounted) {
                setState(() => _isLoadingVideo = false);
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(url));

      setState(() {
        _webViewController = controller;
      });
    } catch (e) {
      // Silently handle errors
      setState(() => _isLoadingVideo = false);
    }
  }

  Future<void> _loadFromServerId(
    String serverId,
    String serverTitle, {
    String? fallbackUrl,
  }) async {
    setState(() {
      _isLoadingVideo = true;
      _currentServerId = serverId;
      _currentServerTitle = serverTitle;
    });

    try {
      String? resolvedUrl;
      if (serverId.isNotEmpty) {
        resolvedUrl = await _api.resolveServerUrl(serverId);
      }

      final urlToUse = (resolvedUrl != null && resolvedUrl.isNotEmpty)
          ? resolvedUrl
          : fallbackUrl;

      if (urlToUse == null || urlToUse.isEmpty) {
        setState(() => _isLoadingVideo = false);
        return;
      }

      await _loadWebViewUrl(urlToUse, serverTitle);
    } catch (e) {
      // Silently handle errors
      setState(() => _isLoadingVideo = false);
    }
  }

  Future<void> _autoLoadFirstServer(EpisodeDetail detail) async {
    if (_hasLoadedVideo) return;

    if (detail.defaultStreamingUrl.isNotEmpty) {
      await _loadWebViewUrl(detail.defaultStreamingUrl, 'Default');
      return;
    }

    if (detail.serverQualities.isNotEmpty &&
        detail.serverQualities[0].serverList.isNotEmpty) {
      final firstServer = detail.serverQualities[0].serverList[0];
      await _loadFromServerId(
        firstServer.serverId,
        firstServer.title,
        fallbackUrl: detail.defaultStreamingUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<EpisodeDetail>(
        future: _episodeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final detail = snapshot.data!;
          return CustomScrollView(
            slivers: [
              // App Bar
              _buildAppBar(detail),
              // Video Player
              SliverToBoxAdapter(child: _buildPlayer(detail)),
              // Episode Info
              SliverToBoxAdapter(child: _buildEpisodeInfo(detail)),
              // Server Selection
              if (detail.serverQualities.isNotEmpty)
                SliverToBoxAdapter(child: _buildServers(detail)),
              // Episode List
              SliverToBoxAdapter(child: _buildEpisodeList(detail)),
              // Downloads
              if (detail.downloadList.isNotEmpty)
                SliverToBoxAdapter(child: _buildDownloads(detail)),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(EpisodeDetail detail) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      floating: true,
      pinned: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => AppRouter.back(context),
      ),
      title: Text(
        detail.title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPlayer(EpisodeDetail detail) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Player
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildWebViewPlayer(detail),
            ),
            // Active Server Info
            if (_currentServerTitle.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black87,
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: AppColors.primary, size: 8),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentServerTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildWebViewPlayer(EpisodeDetail detail) {
    if (_isLoadingVideo) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    if (_webViewController != null) {
      return WebViewWidget(controller: _webViewController!);
    }

    return Material(
      color: Colors.black,
      child: InkWell(
        onTap: () => _autoLoadFirstServer(detail),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tap to play',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Episode Info Section
  Widget _buildEpisodeInfo(EpisodeDetail detail) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Episode Title
          Text(
            detail.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),

          // Anime ID/Link
          if (detail.animeId.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.movie_outlined,
              label: 'Anime',
              value: detail.animeId,
            ),
            const SizedBox(height: 8),
          ],

          // Release Time
          if (detail.releaseTime.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Released',
              value: detail.releaseTime,
            ),
            const SizedBox(height: 8),
          ],

          // Server Count
          if (detail.serverQualities.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.video_library,
              label: 'Servers',
              value: '${detail.serverQualities.length} quality options',
            ),
            const SizedBox(height: 8),
          ],

          // Download Options
          if (detail.downloadList.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.download,
              label: 'Downloads',
              value: '${detail.downloadList.length} quality options',
            ),
            const SizedBox(height: 8),
          ],

          // Navigation Buttons
          if (detail.hasPrevEpisode || detail.hasNextEpisode) ...[
            const SizedBox(height: 4),
            const Divider(color: AppColors.border, height: 24),
            const Text(
              'Episode Navigation',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              if (detail.hasPrevEpisode) ...[
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        AppRouter.toEpisodeWatch(
                          context,
                          episodeId: detail.prevEpisode!.episodeId,
                          replace: true,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Previous',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.mutedForeground,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (detail.hasNextEpisode) ...[
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        AppRouter.toEpisodeWatch(
                          context,
                          episodeId: detail.nextEpisode!.episodeId,
                          replace: true,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.15),
                              AppColors.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Build Info Row Helper
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.mutedForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.foreground),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildServers(EpisodeDetail detail) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Servers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          ...detail.serverQualities.map((quality) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(5),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                title: Text(
                  quality.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white54,
                ),
                children: quality.serverList.map((server) {
                  final isActive = _currentServerId == server.serverId;
                  return Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: isActive
                          ? Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _loadFromServerId(
                          server.serverId,
                          '${quality.title} - ${server.title}',
                          fallbackUrl: detail.defaultStreamingUrl,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                isActive
                                    ? Icons.check_circle
                                    : Icons.play_circle_outline,
                                size: 18,
                                color: isActive
                                    ? AppColors.primary
                                    : Colors.white54,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  server.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isActive
                                        ? AppColors.primary
                                        : Colors.white70,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (_isLoadingVideo &&
                                  _currentServerId == server.serverId)
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEpisodeList(EpisodeDetail detail) {
    final rawList = detail.info['episodeList'];
    if (rawList == null || rawList is! List) return const SizedBox.shrink();

    List<EpisodeInfo> episodes = [];
    try {
      episodes = rawList
          .map<EpisodeInfo>((rawItem) {
            final map = rawItem is Map<String, dynamic>
                ? rawItem
                : (rawItem is Map ? Map<String, dynamic>.from(rawItem) : {});
            return EpisodeInfo(
              title: map['title']?.toString() ?? '',
              episodeId: map['episodeId']?.toString() ?? '',
              otakudesuUrl: map['otakudesuUrl']?.toString() ?? '',
            );
          })
          .where((ep) => ep.episodeId.isNotEmpty || ep.otakudesuUrl.isNotEmpty)
          .toList();
    } catch (_) {
      episodes = [];
    }

    if (episodes.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Episodes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: episodes.map((e) {
              final isCurrent = e.episodeId == widget.episodeId;
              return _buildEpisodeChip(e, isCurrent);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeChip(EpisodeInfo episode, bool isCurrent) {
    return Material(
      color: isCurrent ? AppColors.primary : AppColors.card,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: isCurrent
            ? null
            : () {
                String? epId;
                if (episode.episodeId.isNotEmpty) {
                  epId = episode.episodeId;
                } else if (episode.otakudesuUrl.isNotEmpty) {
                  final uri = Uri.tryParse(episode.otakudesuUrl);
                  if (uri != null && uri.pathSegments.isNotEmpty) {
                    epId = uri.pathSegments.last;
                  }
                }
                if (epId != null && epId != widget.episodeId) {
                  AppRouter.toEpisodeWatch(
                    context,
                    episodeId: epId,
                    replace: true,
                  );
                }
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            episode.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              color: isCurrent ? Colors.white : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDownloads(EpisodeDetail detail) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Download',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          ...detail.downloadList.map((dq) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(5),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                title: Row(
                  children: [
                    Text(
                      dq.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (dq.size != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        dq.size!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white54,
                ),
                children: dq.urlList.map((u) {
                  return Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: u.url));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${u.title} link copied'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.link,
                                size: 16,
                                color: Colors.white54,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  u.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.content_copy,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            const Text(
              'Failed to load episode',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(fontSize: 12, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => AppRouter.back(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
