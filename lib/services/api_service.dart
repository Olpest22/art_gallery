import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/artwork.dart';

/// Ошибка с текстом, который не стыдно показать пользователю.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ArtPage {
  final List<Artwork> items;
  final bool hasMore;
  ArtPage(this.items, this.hasMore);
}

/// Cleveland Museum of Art Open Access API (без ключа).
/// Документация: https://openaccess-api.clevelandart.org/
class ApiService {
  static const _host = 'openaccess-api.clevelandart.org';
  static const _fields = 'id,title,creators,creation_date,technique,culture,'
      'measurements,department,description,images';

  Future<ArtPage> fetch({
    required int page,
    String query = '',
    int limit = 20,
  }) async {
    final q = query.trim();
    final skip = (page - 1) * limit;
    final params = <String, String>{
      'has_image': '1',
      'limit': '$limit',
      'skip': '$skip',
      'fields': _fields,
      if (q.isNotEmpty) 'q': q,
    };
    final uri = Uri.https(_host, '/api/artworks/', params);

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) {
        throw ApiException(
            'Сервер ответил ошибкой (${res.statusCode}). Попробуй позже.');
      }
      final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

      final data = (body['data'] as List).cast<Map<String, dynamic>>();
      final info = body['info'] as Map<String, dynamic>?;
      final total = (info?['total'] as num?)?.toInt() ?? 0;

      final items =
          data.map(Artwork.fromApi).where((a) => a.imageUrl != null).toList();
      return ArtPage(items, skip + limit < total);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Сервер слишком долго отвечает. Проверь интернет.');
    } on http.ClientException {
      throw ApiException('Нет соединения с интернетом.');
    } catch (_) {
      throw ApiException('Не получилось разобрать ответ сервера.');
    }
  }
}
