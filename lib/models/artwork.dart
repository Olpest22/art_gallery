class Artwork {
  final int id;
  final String title;
  final String artist;
  final String? date;
  final String? imageUrl;
  final String? medium;
  final String? origin;
  final String? dimensions;
  final String? department;
  final String? description;

  const Artwork({
    required this.id,
    required this.title,
    required this.artist,
    this.date,
    this.imageUrl,
    this.medium,
    this.origin,
    this.dimensions,
    this.department,
    this.description,
  });

  /// Для карточки: первая строка автора.
  String get artistName => artist.split('\n').first;

  /// Разбор ответа Cleveland Museum of Art Open Access API.
  factory Artwork.fromApi(Map<String, dynamic> json) {
    // creators: [{description: "Song Xu (Chinese, 1525-c. 1606)", ...}]
    String? artist;
    final creators = json['creators'];
    if (creators is List) {
      final names = creators
          .whereType<Map>()
          .map((c) => _clean(c['description']))
          .whereType<String>()
          .toList();
      if (names.isNotEmpty) artist = names.join('; ');
    }

    // culture: ["China, Jiaxing, 16th century"]
    String? origin;
    final culture = json['culture'];
    if (culture is List) {
      origin = _clean(culture.whereType<String>().join('; '));
    }

    // images: {web: {url: "https://openaccess-cdn.clevelandart.org/..._web.jpg"}}
    String? imageUrl;
    final images = json['images'];
    if (images is Map && images['web'] is Map) {
      final u = (images['web'] as Map)['url'];
      if (u is String && u.isNotEmpty) imageUrl = u;
    }

    return Artwork(
      id: (json['id'] as num).toInt(),
      title: _clean(json['title']) ?? 'Без названия',
      artist: artist ?? 'Автор неизвестен',
      date: _clean(json['creation_date']),
      imageUrl: imageUrl,
      medium: _clean(json['technique']),
      origin: origin,
      dimensions: _clean(json['measurements']),
      department: _clean(json['department']),
      description: _clean(json['description']),
    );
  }

  /// Формат хранения в SharedPreferences (избранное).
  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? 'Без названия',
      artist: json['artist'] as String? ?? 'Автор неизвестен',
      date: json['date'] as String?,
      imageUrl: json['image_url'] as String?,
      medium: json['medium'] as String?,
      origin: json['origin'] as String?,
      dimensions: json['dimensions'] as String?,
      department: json['department'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'date': date,
        'image_url': imageUrl,
        'medium': medium,
        'origin': origin,
        'dimensions': dimensions,
        'department': department,
        'description': description,
      };

  /// Выкидывает HTML-теги и самые частые html-сущности.
  static String? _clean(dynamic v) {
    if (v is! String) return null;
    final s = v
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
    return s.isEmpty ? null : s;
  }
}
