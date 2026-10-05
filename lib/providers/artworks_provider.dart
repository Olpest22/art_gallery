import 'package:flutter/foundation.dart';

import '../models/artwork.dart';
import '../services/api_service.dart';

enum LoadState { loading, loaded, error }

class ArtworksProvider extends ChangeNotifier {
  final ApiService _api;

  ArtworksProvider({ApiService? api}) : _api = api ?? ApiService() {
    loadFirst();
  }

  LoadState state = LoadState.loading;
  List<Artwork> items = [];
  String query = '';
  String? errorMessage;
  String? moreError;
  bool isLoadingMore = false;
  bool hasMore = true;

  int _page = 1;
  int _requestId = 0; // чтобы старый ответ не перетёр новый поиск

  Future<void> loadFirst() async {
    final id = ++_requestId;
    state = LoadState.loading;
    errorMessage = null;
    moreError = null;
    isLoadingMore = false;
    hasMore = true;
    _page = 1;
    items = [];
    notifyListeners();

    try {
      final p = await _api.fetch(page: 1, query: query);
      if (id != _requestId) return;
      items = p.items;
      hasMore = p.hasMore;
      state = LoadState.loaded;
    } on ApiException catch (e) {
      if (id != _requestId) return;
      errorMessage = e.message;
      state = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> search(String q) {
    query = q.trim();
    return loadFirst();
  }

  Future<void> loadMore() async {
    if (state != LoadState.loaded || isLoadingMore || !hasMore) return;
    final id = _requestId;
    isLoadingMore = true;
    moreError = null;
    notifyListeners();

    try {
      final p = await _api.fetch(page: _page + 1, query: query);
      if (id != _requestId) return;
      _page++;
      final known = items.map((a) => a.id).toSet();
      items = [...items, ...p.items.where((a) => !known.contains(a.id))];
      hasMore = p.hasMore;
    } on ApiException catch (e) {
      if (id != _requestId) return;
      moreError = e.message;
    }
    isLoadingMore = false;
    notifyListeners();
  }
}
