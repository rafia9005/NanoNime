import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A widget that transparently displays a NetworkImage while proxying the URL
/// if running on Web to avoid CORS issues.
///
/// If running on mobile/desktop, it loads directly.
/// If running on web, it prefixes the URL with a CORS proxy.
class ProxyImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const ProxyImage({
    Key? key,
    required this.imageUrl,
    this.fit,
    this.errorBuilder,
  }) : super(key: key);

  /// Helper to get the proxied URL as a String provider (for DecorationImage etc)
  static ImageProvider provider(String url) {
    if (kIsWeb && url.isNotEmpty) {
      // Using local Go backend proxy to bypass WAF/CORS issues securely.
      const baseUrl = 'http://localhost:7777/api/v1/manga/image'; 
      return NetworkImage('$baseUrl?url=${Uri.encodeComponent(url)}');
    }
    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: provider(imageUrl),
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}
