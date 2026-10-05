import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/artwork.dart';
import '../providers/favorites_provider.dart';
import '../screens/detail_screen.dart';
import '../utils/routes.dart';
import 'art_image.dart';

class ArtworkCard extends StatelessWidget {
  final Artwork artwork;

  /// Префикс для Hero-тега: на вкладках "Галерея" и "Избранное" одна и та же
  /// картина может жить одновременно, теги не должны совпадать.
  final String heroPrefix;

  const ArtworkCard({
    super.key,
    required this.artwork,
    required this.heroPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tag = '$heroPrefix-${artwork.id}';
    final isFav = context
        .select<FavoritesProvider, bool>((f) => f.isFavorite(artwork.id));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(fadeRoute(DetailScreen(artwork: artwork, heroTag: tag))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: tag,
                    child: ArtImage(url: artwork.imageUrl, cacheWidth: 500),
                  ),
                  if (isFav)
                    const Positioned(
                      top: 6,
                      right: 6,
                      child: Icon(Icons.favorite, color: Colors.redAccent),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artwork.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
