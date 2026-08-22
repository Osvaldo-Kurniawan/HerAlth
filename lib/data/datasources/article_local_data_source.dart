import '../../domain/models/article.dart';

abstract class ArticleLocalDataSource {
  Future<List<Article>> getArticles(ArticleFilter filter);
  Future<ArticleContent?> getArticleContent(String articleId);
}

class ArticleLocalDataSourceImpl implements ArticleLocalDataSource {
  // Static mock articles to represent bundled offline content
  static const List<Article> _bundledArticles = [
    Article(
      id: '1',
      title: 'Understanding Your Cycle',
      summary: 'Learn the basics of the 4 menstrual cycle phases.',
      contentPath: 'assets/content/cycle_basics.md',
      category: ArticleCategory.menstruation,
      tags: ['cycle', 'ovulation', 'menstruation'],
    ),
    Article(
      id: '2',
      title: 'Nutrition & Hormones',
      summary: 'What to eat during different phases of your cycle.',
      contentPath: 'assets/content/nutrition.md',
      category: ArticleCategory.nutrition,
      tags: ['nutrition', 'food', 'hormones'],
    ),
  ];

  @override
  Future<List<Article>> getArticles(ArticleFilter filter) async {
    // Filter logic on the bundled articles
    var results = _bundledArticles;
    if (filter.category != null) {
      results = results
          .where((element) => element.category == filter.category)
          .toList();
    }
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      results = results
          .where(
            (element) =>
                element.title.toLowerCase().contains(query) ||
                element.summary.toLowerCase().contains(query),
          )
          .toList();
    }
    return results;
  }

  @override
  Future<ArticleContent?> getArticleContent(String articleId) async {
    final article = _bundledArticles.firstWhere(
      (element) => element.id == articleId,
    );
    // In future, this will read the actual markdown body from Flutter rootBundle using the article's contentPath.
    return ArticleContent(
      articleId: article.id,
      markdownBody:
          '# ${article.title}\n\nThis is the offline bundled content body loaded from ${article.contentPath}.',
    );
  }
}
