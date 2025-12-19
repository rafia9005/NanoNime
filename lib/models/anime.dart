// Models for Nanonime app
// - Provides Anime, AnimeDetail and related models
// - AnimeDetail.fromJson is resilient to API nesting under 'details' and
//   performs safe mapping for lists and maps.

class Anime {
  final String title;
  final String poster;
  final String episodes;
  final String animeId;
  final String latestReleaseDate;

  Anime({
    required this.title,
    required this.poster,
    required this.episodes,
    required this.animeId,
    required this.latestReleaseDate,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      title: json['title']?.toString() ?? '',
      poster: json['poster']?.toString() ?? '',
      episodes: json['episodes']?.toString() ?? '',
      animeId: json['animeId']?.toString() ?? '',
      latestReleaseDate: json['latestReleaseDate']?.toString() ?? '',
    );
  }
}

class AnimeDetail {
  final String title;
  final String japanese;
  final String poster;
  final String type;
  final String status;
  final String episodes;
  final String aired;
  final String duration;
  final String studios;
  final String producers;
  final List<String> synopsis;
  final List<Genre> genres;
  final List<EpisodeInfo> episodesList;
  final List<RecommendedAnime> recommendedAnimeList;

  AnimeDetail({
    required this.title,
    required this.japanese,
    required this.poster,
    required this.type,
    required this.status,
    required this.episodes,
    required this.aired,
    required this.duration,
    required this.studios,
    required this.producers,
    required this.synopsis,
    required this.genres,
    required this.episodesList,
    required this.recommendedAnimeList,
  });

  /// Create AnimeDetail from an API response map.
  ///
  /// The API sometimes returns the detail object nested under the key 'details'
  /// so this factory first normalizes the input to a detail map, then safely
  /// extracts lists/maps with robust null/type checking.
  factory AnimeDetail.fromJson(Map<String, dynamic> json) {
    // Normalize: if json contains 'details' and it's a Map, use it.
    final Map<String, dynamic> detailMap = () {
      final dynamic maybeDetails = json['details'];
      if (maybeDetails is Map) {
        return Map<String, dynamic>.from(maybeDetails);
      }
      // Sometimes the incoming json is already the 'details' object or has fields directly.
      return Map<String, dynamic>.from(json);
    }();

    // synopsis can be either { 'paragraphList': [...] } or a plain list or missing.
    List<String> synList = <String>[];
    final synObj = detailMap['synopsis'];
    if (synObj is Map) {
      final para = synObj['paragraphList'];
      if (para is List) {
        synList = para
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
    } else if (synObj is List) {
      synList = synObj
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (synObj != null) {
      // fallback: convert to single string entry
      final s = synObj.toString();
      if (s.isNotEmpty) synList = [s];
    }

    // genres
    List<Genre> genList = <Genre>[];
    final genObj = detailMap['genreList'];
    if (genObj is List) {
      genList = genObj.where((e) => e != null).map<Genre>((e) {
        if (e is Map<String, dynamic>) {
          return Genre.fromJson(e);
        } else if (e is Map) {
          return Genre.fromJson(Map<String, dynamic>.from(e));
        } else {
          return Genre(title: e?.toString() ?? '');
        }
      }).toList();
    }

    // episodeList
    List<EpisodeInfo> epList = <EpisodeInfo>[];
    final epObj = detailMap['episodeList'];
    if (epObj is List) {
      epList = epObj
          .where((e) => e != null)
          .map<EpisodeInfo>((e) {
            if (e is EpisodeInfo) return e;
            if (e is Map<String, dynamic>) {
              return EpisodeInfo.fromJson(e);
            } else if (e is Map) {
              return EpisodeInfo.fromJson(Map<String, dynamic>.from(e));
            } else {
              // When item is a primitive or unexpected shape, try to interpret as title
              return EpisodeInfo(
                title: e?.toString() ?? '',
                episodeId: '',
                otakudesuUrl: '',
              );
            }
          })
          .where(
            (epi) =>
                epi.title.isNotEmpty ||
                epi.episodeId.isNotEmpty ||
                epi.otakudesuUrl.isNotEmpty,
          )
          .toList();
    }

    // recommendationList
    List<RecommendedAnime> recList = <RecommendedAnime>[];
    final recObj =
        detailMap['recommendationList'] ?? detailMap['recommendations'];
    if (recObj is List) {
      recList = recObj.where((e) => e != null).map<RecommendedAnime>((e) {
        if (e is RecommendedAnime) return e;
        if (e is Map<String, dynamic>) {
          return RecommendedAnime.fromJson(e);
        } else if (e is Map) {
          return RecommendedAnime.fromJson(Map<String, dynamic>.from(e));
        } else {
          return RecommendedAnime(
            title: e?.toString() ?? '',
            poster: '',
            animeId: '',
          );
        }
      }).toList();
    }

    return AnimeDetail(
      title: detailMap['title']?.toString() ?? 'No Title',
      japanese: detailMap['japanese']?.toString() ?? '',
      poster: detailMap['poster']?.toString() ?? '',
      type: detailMap['type']?.toString() ?? '-',
      status: detailMap['status']?.toString() ?? '-',
      episodes: detailMap['episodes']?.toString() ?? '?',
      aired: detailMap['aired']?.toString() ?? '-',
      duration: detailMap['duration']?.toString() ?? '-',
      studios: detailMap['studios']?.toString() ?? '-',
      producers: detailMap['producers']?.toString() ?? '-',
      synopsis: synList,
      genres: genList,
      episodesList: epList,
      recommendedAnimeList: recList,
    );
  }
}

class Genre {
  final String title;
  Genre({required this.title});
  factory Genre.fromJson(Map<String, dynamic> json) =>
      Genre(title: json['title']?.toString() ?? '');
}

class EpisodeInfo {
  final String title;
  final String episodeId;
  final String otakudesuUrl;

  EpisodeInfo({
    required this.title,
    required this.episodeId,
    required this.otakudesuUrl,
  });

  factory EpisodeInfo.fromJson(Map<String, dynamic> json) {
    return EpisodeInfo(
      title: json['title']?.toString() ?? '',
      episodeId: json['episodeId']?.toString() ?? '',
      otakudesuUrl: json['otakudesuUrl']?.toString() ?? '',
    );
  }
}

class RecommendedAnime {
  final String title;
  final String poster;
  final String animeId;
  RecommendedAnime({
    required this.title,
    required this.poster,
    required this.animeId,
  });
  factory RecommendedAnime.fromJson(Map<String, dynamic> json) =>
      RecommendedAnime(
        title: json['title']?.toString() ?? '',
        poster: json['poster']?.toString() ?? '',
        animeId: json['animeId']?.toString() ?? '',
      );
}

// ---------------- Episode detail models ----------------

class EpisodeDetail {
  final String title;
  final String animeId;
  final String releaseTime;
  final String defaultStreamingUrl;
  final bool hasPrevEpisode;
  final PrevNext? prevEpisode;
  final bool hasNextEpisode;
  final PrevNext? nextEpisode;
  final List<ServerQuality> serverQualities;
  final List<DownloadQuality> downloadList;
  final Map<String, dynamic> info; // generic info map

  EpisodeDetail({
    required this.title,
    required this.animeId,
    required this.releaseTime,
    required this.defaultStreamingUrl,
    required this.hasPrevEpisode,
    this.prevEpisode,
    required this.hasNextEpisode,
    this.nextEpisode,
    required this.serverQualities,
    required this.downloadList,
    required this.info,
  });

  factory EpisodeDetail.fromJson(Map<String, dynamic> json) {
    // `json` expected to be the `data` object from the API (contains 'details' and 'info')
    final details = json['details'];
    final Map<String, dynamic> detailMap = (details is Map)
        ? Map<String, dynamic>.from(details)
        : Map<String, dynamic>.from(json);

    final download = detailMap['download'] is Map
        ? Map<String, dynamic>.from(detailMap['download'])
        : <String, dynamic>{};
    final server = detailMap['server'] is Map
        ? Map<String, dynamic>.from(detailMap['server'])
        : <String, dynamic>{};

    List<ServerQuality> parseServerQualities(dynamic q) {
      if (q is List) {
        return q.where((e) => e != null).map((e) {
          if (e is Map<String, dynamic>) return ServerQuality.fromJson(e);
          if (e is Map)
            return ServerQuality.fromJson(Map<String, dynamic>.from(e));
          return ServerQuality(title: e?.toString() ?? '', serverList: []);
        }).toList();
      }
      return [];
    }

    List<DownloadQuality> parseDownloadQualities(dynamic q) {
      if (q is List) {
        return q.where((e) => e != null).map((e) {
          if (e is Map<String, dynamic>) return DownloadQuality.fromJson(e);
          if (e is Map)
            return DownloadQuality.fromJson(Map<String, dynamic>.from(e));
          return DownloadQuality(
            title: e?.toString() ?? '',
            size: null,
            urlList: [],
          );
        }).toList();
      }
      return [];
    }

    return EpisodeDetail(
      title: detailMap['title']?.toString() ?? '',
      animeId: detailMap['animeId']?.toString() ?? '',
      releaseTime: detailMap['releaseTime']?.toString() ?? '',
      defaultStreamingUrl: detailMap['defaultStreamingUrl']?.toString() ?? '',
      hasPrevEpisode: detailMap['hasPrevEpisode'] ?? false,
      prevEpisode: detailMap['prevEpisode'] is Map
          ? PrevNext.fromJson(
              Map<String, dynamic>.from(detailMap['prevEpisode']),
            )
          : null,
      hasNextEpisode: detailMap['hasNextEpisode'] ?? false,
      nextEpisode: detailMap['nextEpisode'] is Map
          ? PrevNext.fromJson(
              Map<String, dynamic>.from(detailMap['nextEpisode']),
            )
          : null,
      serverQualities: parseServerQualities(server['qualityList']),
      downloadList: parseDownloadQualities(download['qualityList']),
      info: json['info'] is Map
          ? Map<String, dynamic>.from(json['info'])
          : <String, dynamic>{},
    );
  }

  /// Helper: extract episode list from either `info['episodeList']` or from
  /// other nested places in the detail map. Returns a List<EpisodeInfo>.
  List<EpisodeInfo> episodesFromInfo() {
    final dynamic raw = info['episodeList'] ?? info['episodes'] ?? null;
    if (raw == null || raw is! List) {
      return [];
    }

    final List<EpisodeInfo> result = [];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        result.add(EpisodeInfo.fromJson(item));
      } else if (item is Map) {
        result.add(EpisodeInfo.fromJson(Map<String, dynamic>.from(item)));
      } else {
        // fallback: when item is an unexpected primitive, use as title
        result.add(
          EpisodeInfo(
            title: item?.toString() ?? '',
            episodeId: '',
            otakudesuUrl: '',
          ),
        );
      }
    }
    return result
        .where((e) => e.episodeId.isNotEmpty || e.otakudesuUrl.isNotEmpty)
        .toList();
  }
}

class PrevNext {
  final String title;
  final String episodeId;
  final String otakudesuUrl;

  PrevNext({
    required this.title,
    required this.episodeId,
    required this.otakudesuUrl,
  });

  factory PrevNext.fromJson(Map<String, dynamic> json) {
    return PrevNext(
      title: json['title']?.toString() ?? '',
      episodeId: json['episodeId']?.toString() ?? '',
      otakudesuUrl: json['otakudesuUrl']?.toString() ?? '',
    );
  }
}

class ServerQuality {
  final String title; // e.g. "Mirror 360p"
  final List<ServerItem> serverList;

  ServerQuality({required this.title, required this.serverList});

  factory ServerQuality.fromJson(Map<String, dynamic> json) {
    List<ServerItem> parseServerList(dynamic sList) {
      if (sList is List) {
        return sList.where((e) => e != null).map((s) {
          if (s is Map<String, dynamic>) return ServerItem.fromJson(s);
          if (s is Map)
            return ServerItem.fromJson(Map<String, dynamic>.from(s));
          return ServerItem(title: s?.toString() ?? '', serverId: '');
        }).toList();
      }
      return [];
    }

    return ServerQuality(
      title: json['title']?.toString() ?? '',
      serverList: parseServerList(json['serverList']),
    );
  }
}

class ServerItem {
  final String title; // server title e.g. vidhide
  final String serverId; // encoded server id

  ServerItem({required this.title, required this.serverId});

  factory ServerItem.fromJson(Map<String, dynamic> json) {
    return ServerItem(
      title: json['title']?.toString() ?? '',
      serverId: json['serverId']?.toString() ?? '',
    );
  }

  /// Returns the relative server endpoint path that can be called to resolve
  /// a streaming url for this server item.
  ///
  /// Example: "/otakudesu/server/<serverId>"
  String serverEndpoint() {
    // encode the serverId portion to make it safe in a URL
    return '/otakudesu/server/${Uri.encodeComponent(serverId)}';
  }

  /// Convenience: attempt to build a full absolute URL if a baseUrl is provided.
  /// This method doesn't make network calls; it just composes the URL.
  String absoluteServerUrl({String? baseUrl}) {
    if (baseUrl == null || baseUrl.isEmpty) {
      return serverEndpoint();
    }
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$normalized${serverEndpoint()}';
  }
}

class DownloadQuality {
  final String title;
  final String? size;
  final List<DownloadUrl> urlList;

  DownloadQuality({required this.title, this.size, required this.urlList});

  factory DownloadQuality.fromJson(Map<String, dynamic> json) {
    List<DownloadUrl> parseUrlList(dynamic uList) {
      if (uList is List) {
        return uList.where((e) => e != null).map((u) {
          if (u is Map<String, dynamic>) return DownloadUrl.fromJson(u);
          if (u is Map)
            return DownloadUrl.fromJson(Map<String, dynamic>.from(u));
          return DownloadUrl(title: u?.toString() ?? '', url: '');
        }).toList();
      }
      return [];
    }

    return DownloadQuality(
      title: json['title']?.toString() ?? '',
      size: json['size']?.toString(),
      urlList: parseUrlList(json['urlList']),
    );
  }
}

class DownloadUrl {
  final String title;
  final String url;

  DownloadUrl({required this.title, required this.url});

  factory DownloadUrl.fromJson(Map<String, dynamic> json) {
    return DownloadUrl(
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}
