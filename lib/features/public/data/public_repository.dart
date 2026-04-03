import '../../../core/result/app_result.dart';
import '../models/public_models.dart';

abstract class PublicRepository {
  Future<AppResult<List<NewsItem>>> fetchNews();

  Future<AppResult<NewsDetail>> fetchNewsDetail({required int id});

  Future<AppResult<List<VideoItem>>> fetchVideos();

  Future<AppResult<CatalogPage>> fetchCatalog({
    int page = 1,
    int limit = 20,
    String? marca,
    String? modelo,
    int? anio,
  });

  Future<AppResult<CatalogDetail>> fetchCatalogDetail({required int id});

  Future<AppResult<List<ForumTopic>>> fetchPublicForum({
    int page = 1,
    int limit = 20,
  });

  Future<AppResult<ForumDetail>> fetchPublicForumDetail({required int id});
}
