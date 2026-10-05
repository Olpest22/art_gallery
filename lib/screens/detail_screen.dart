import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/artwork.dart';
import '../providers/favorites_provider.dart';
import '../widgets/art_image.dart';

class DetailScreen extends StatelessWidget {
  final Artwork artwork;
  final String heroTag;

  const DetailScreen({super.key, required this.artwork, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final isFav = context
        .select<FavoritesProvider, bool>((f) => f.isFavorite(artwork.id));

    final image = Hero(
      tag: heroTag,
      child: ArtImage(url: artwork.imageUrl, fit: BoxFit.contain),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(artwork.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: isFav ? 'Убрать из избранного' : 'В избранное',
            onPressed: () => context.read<FavoritesProvider>().toggle(artwork),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(isFav),
                color: isFav ? Colors.redAccent : null,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            // широкий экран (телефон в горизонтали, планшет): картинка слева, текст справа
            if (c.maxWidth > 700) {
              return Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: image,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                      child: _Info(artwork: artwork),
                    ),
                  ),
                ],
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: image,
                  ),
                  const SizedBox(height: 16),
                  _Info(artwork: artwork),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final Artwork artwork;
  const _Info({required this.artwork});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(artwork.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(artwork.artist, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        _Field(label: 'Дата', value: artwork.date),
        _Field(label: 'Отдел музея', value: artwork.department),
        _Field(label: 'Техника', value: artwork.medium),
        _Field(label: 'Откуда', value: artwork.origin),
        _Field(label: 'Размеры', value: artwork.dimensions),
        _Field(label: 'Описание', value: artwork.description),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String? value;
  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 2),
          Text(value!, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
