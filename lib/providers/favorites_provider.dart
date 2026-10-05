import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/artwork.dart';

class FavoritesProvider extends ChangeNotifier {
  static const _key = 'favorites_v2';
  final List<Artwork> _items = [];

  List<Artwork> get items => List.unmodifiable(_items);

  bool isFavorite(int id) => _items.any((a) => a.id == id);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _items.clear();
    for (final s in raw) {
      try {
        _items.add(Artwork.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {
        // битую запись просто пропускаем
      }
    }
    notifyListeners();
  }

  Future<void> toggle(Artwork a) async {
    if (isFavorite(a.id)) {
      _items.removeWhere((x) => x.id == a.id);
    } else {
      _items.insert(0, a);
    }
    notifyListeners();
    await _save();
  }

  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _items.map((a) => jsonEncode(a.toJson())).toList(),
    );
  }
}
