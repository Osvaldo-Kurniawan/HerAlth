import '../../domain/models/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_local_data_source.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleLocalDataSource _localDataSource;

  ArticleRepositoryImpl(this._localDataSource);

  @override
  Future<List<Article>> getArticles(ArticleFilter filter) {
    return _localDataSource.getArticles(filter);
  }

  @override
  Future<ArticleContent?> getArticleContent(String articleId) {
    return _localDataSource.getArticleContent(articleId);
  }
}
