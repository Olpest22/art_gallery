import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../widgets/artwork_card.dart';
import '../widgets/message_view.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<FavoritesProvider>().items;

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: items.isEmpty
          ? const MessageView(
              icon: Icons.favorite_border,
              message: 'Пока пусто. Открой любую картину и жми на сердечко.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.72,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) =>
                  ArtworkCard(artwork: items[i], heroPrefix: 'fav'),
            ),
    );
  }
}
