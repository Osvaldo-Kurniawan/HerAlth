import '../models/article.dart';

abstract class ArticleRepository {
  Future<List<Article>> getArticles(ArticleFilter filter);
  Future<ArticleContent?> getArticleContent(String articleId);
}
