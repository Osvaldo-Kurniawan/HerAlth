import 'package:flutter_test/flutter_test.dart';
import 'package:heralth/data/datasources/article_local_data_source.dart';
import 'package:heralth/domain/models/article.dart';

void main() {
  late ArticleLocalDataSourceImpl dataSource;

  setUp(() {
    dataSource = ArticleLocalDataSourceImpl();
  });

  test('Nutrition category returns multiple articles', () async {
    final articles = await dataSource.getArticles(
      const ArticleFilter(category: ArticleCategory.nutrition),
    );

    expect(articles.length, greaterThanOrEqualTo(4));
    expect(
      articles.every(
        (article) => article.category == ArticleCategory.nutrition,
      ),
      isTrue,
    );
  });

  test('all bundled articles have unique ids and non-empty content', () async {
    final all = await dataSource.getArticles(const ArticleFilter());
    final ids = all.map((a) => a.id).toList();

    expect(
      ids.toSet().length,
      ids.length,
      reason: 'article ids must be unique',
    );

    for (final article in all) {
      final content = await dataSource.getArticleContent(article.id);
      expect(content, isNotNull);
      expect(content!.markdownBody.trim(), isNotEmpty);
      expect(content.markdownBody, isNot(contains('Content not found.')));
    }
  });

  test('search filter still works across nutrition articles', () async {
    final results = await dataSource.getArticles(
      const ArticleFilter(searchQuery: 'iron'),
    );

    expect(results, isNotEmpty);
    expect(
      results.any((article) => article.category == ArticleCategory.nutrition),
      isTrue,
    );
  });
}
