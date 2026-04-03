class NewsItem {
  const NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    this.imageUrl,
    this.date,
    this.source,
    this.link,
  });

  final int id;
  final String title;
  final String summary;
  final String? imageUrl;
  final String? date;
  final String? source;
  final String? link;

  factory NewsItem.fromMap(Map<String, dynamic> map) {
    return NewsItem(
      id: _toInt(map['id']),
      title: map['titulo']?.toString() ?? 'Sin titulo',
      summary: map['resumen']?.toString() ?? '',
      imageUrl: map['imagenUrl']?.toString(),
      date: map['fecha']?.toString(),
      source: map['fuente']?.toString(),
      link: map['link']?.toString(),
    );
  }
}

class NewsDetail {
  const NewsDetail({required this.item, required this.htmlContent});

  final NewsItem item;
  final String htmlContent;

  factory NewsDetail.fromMap(Map<String, dynamic> map) {
    return NewsDetail(
      item: NewsItem.fromMap(map),
      htmlContent: map['contenido']?.toString() ?? '',
    );
  }
}

class VideoItem {
  const VideoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    this.category,
    this.youtubeId,
    this.thumbnail,
  });

  final int id;
  final String title;
  final String description;
  final String url;
  final String? category;
  final String? youtubeId;
  final String? thumbnail;

  factory VideoItem.fromMap(Map<String, dynamic> map) {
    return VideoItem(
      id: _toInt(map['id']),
      title: map['titulo']?.toString() ?? 'Video',
      description: map['descripcion']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
      category: map['categoria']?.toString(),
      youtubeId: map['youtubeId']?.toString(),
      thumbnail: map['thumbnail']?.toString(),
    );
  }
}

class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.shortDescription,
    this.imageUrl,
  });

  final int id;
  final String brand;
  final String model;
  final int year;
  final double price;
  final String shortDescription;
  final String? imageUrl;

  factory CatalogItem.fromMap(Map<String, dynamic> map) {
    return CatalogItem(
      id: _toInt(map['id']),
      brand: map['marca']?.toString() ?? '-',
      model: map['modelo']?.toString() ?? '-',
      year: _toInt(map['anio']),
      price: _toDouble(map['precio']),
      shortDescription: map['descripcionCorta']?.toString() ?? '',
      imageUrl: map['imagenUrl']?.toString(),
    );
  }
}

class CatalogPage {
  const CatalogPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<CatalogItem> items;
  final int page;
  final int limit;
  final int total;
}

class CatalogDetail {
  const CatalogDetail({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.description,
    required this.images,
    required this.specifications,
  });

  final int id;
  final String brand;
  final String model;
  final int year;
  final double price;
  final String description;
  final List<String> images;
  final Map<String, dynamic> specifications;

  factory CatalogDetail.fromMap(Map<String, dynamic> map) {
    final imagesRaw = map['imagenes'];
    final images = imagesRaw is List
        ? imagesRaw.map((e) => e.toString()).toList()
        : <String>[];

    final specsRaw = map['especificaciones'];
    final specs = specsRaw is Map
        ? specsRaw.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    return CatalogDetail(
      id: _toInt(map['id']),
      brand: map['marca']?.toString() ?? '-',
      model: map['modelo']?.toString() ?? '-',
      year: _toInt(map['anio']),
      price: _toDouble(map['precio']),
      description: map['descripcion']?.toString() ?? '',
      images: images,
      specifications: specs,
    );
  }
}

class ForumTopic {
  const ForumTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.vehicle,
    required this.answersCount,
    this.date,
    this.vehicleImage,
  });

  final int id;
  final String title;
  final String description;
  final String author;
  final String vehicle;
  final int answersCount;
  final String? date;
  final String? vehicleImage;

  factory ForumTopic.fromMap(Map<String, dynamic> map) {
    return ForumTopic(
      id: _toInt(map['id']),
      title: map['titulo']?.toString() ?? 'Tema',
      description: map['descripcion']?.toString() ?? '',
      author: map['autor']?.toString() ?? '-',
      vehicle: map['vehiculo']?.toString() ?? '-',
      answersCount: _toInt(map['totalRespuestas']),
      date: map['fecha']?.toString(),
      vehicleImage: map['vehiculoFoto']?.toString(),
    );
  }
}

class ForumReply {
  const ForumReply({
    required this.id,
    required this.author,
    required this.content,
    this.date,
    this.authorPhoto,
  });

  final int id;
  final String author;
  final String content;
  final String? date;
  final String? authorPhoto;

  factory ForumReply.fromMap(Map<String, dynamic> map) {
    return ForumReply(
      id: _toInt(map['id']),
      author: map['autor']?.toString() ?? '-',
      content: map['contenido']?.toString() ?? '',
      date: map['fecha']?.toString(),
      authorPhoto: map['autorFotoUrl']?.toString(),
    );
  }
}

class ForumDetail {
  const ForumDetail({required this.topic, required this.replies});

  final ForumTopic topic;
  final List<ForumReply> replies;

  factory ForumDetail.fromMap(Map<String, dynamic> map) {
    final repliesRaw = map['respuestas'];
    final replies = repliesRaw is List
        ? repliesRaw
              .whereType<Map>()
              .map(
                (e) => ForumReply.fromMap(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList()
        : <ForumReply>[];

    return ForumDetail(topic: ForumTopic.fromMap(map), replies: replies);
  }
}

class TeamMember {
  const TeamMember({
    required this.name,
    required this.matricula,
    required this.photoAsset,
    required this.phone,
    required this.telegram,
    required this.email,
  });

  final String name;
  final String matricula;
  final String photoAsset;
  final String phone;
  final String telegram;
  final String email;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
