import 'package:flutter/material.dart';

/// Картинка с крутилкой при загрузке и заглушкой при ошибке.
class ArtImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final int? cacheWidth;

  const ArtImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null) return _placeholder(context, Icons.image_not_supported);

    return Image.network(
      url!,
      fit: fit,
      cacheWidth: cacheWidth,
      // только для web: если скачать байты не вышло (CORS/403), показать через <img>
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        final total = progress.expectedTotalBytes;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: total != null ? progress.cumulativeBytesLoaded / total : null,
          ),
        );
      },
      errorBuilder: (context, error, stack) =>
          _placeholder(context, Icons.broken_image_outlined),
    );
  }

  Widget _placeholder(BuildContext context, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Center(child: Icon(icon, color: scheme.outline)),
    );
  }
}
