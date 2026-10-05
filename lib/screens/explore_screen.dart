import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/artworks_provider.dart';
import '../widgets/artwork_card.dart';
import '../widgets/message_view.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _scroll = ScrollController();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      context.read<ArtworksProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ArtworksProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cleveland Museum of Art')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: p.search,
              decoration: InputDecoration(
                hintText: 'Поиск: monet, sword, cat...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Сбросить',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _search.clear();
                    p.search('');
                  },
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          Expanded(child: _buildBody(p)),
        ],
      ),
    );
  }

  Widget _buildBody(ArtworksProvider p) {
    switch (p.state) {
      case LoadState.loading:
        return const Center(child: CircularProgressIndicator());

      case LoadState.error:
        return MessageView(
          icon: Icons.wifi_off,
          message: p.errorMessage ?? 'Что-то пошло не так.',
          onRetry: p.loadFirst,
        );

      case LoadState.loaded:
        if (p.items.isEmpty) {
          return MessageView(
            icon: Icons.search_off,
            message: p.query.isEmpty
                ? 'Пока ничего нет.'
                : 'По запросу «${p.query}» ничего не нашлось. '
                    'Запросы лучше писать по-английски.',
            onRetry: p.query.isEmpty ? p.loadFirst : null,
          );
        }
        return CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  childAspectRatio: 0.72,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) =>
                      ArtworkCard(artwork: p.items[i], heroPrefix: 'explore'),
                  childCount: p.items.length,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _footer(p)),
          ],
        );
    }
  }

  Widget _footer(ArtworksProvider p) {
    if (p.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (p.moreError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(p.moreError!, textAlign: TextAlign.center),
            TextButton(onPressed: p.loadMore, child: const Text('Повторить')),
          ],
        ),
      );
    }
    if (p.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: TextButton(
            onPressed: p.loadMore,
            child: const Text('Загрузить ещё'),
          ),
        ),
      );
    }
    return const SizedBox(height: 16);
  }
}
