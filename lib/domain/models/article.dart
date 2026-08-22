enum ArticleCategory { menstruation, nutrition, fitness, mentalHealth, general }

class Article {
  final String id;
  final String title;
  final String summary;
  final String contentPath; // Offline markdown or asset file path
  final ArticleCategory category;
  final List<String> tags;

  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.contentPath,
    required this.category,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'contentPath': contentPath,
      'category': category.name,
      'tags': tags.join(','),
    };
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      contentPath: json['contentPath'] as String,
      category: ArticleCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ArticleCategory.general,
      ),
      tags:
          (json['tags'] as String?)
              ?.split(',')
              .where((t) => t.isNotEmpty)
              .toList() ??
          [],
    );
  }
}

class ArticleContent {
  final String articleId;
  final String markdownBody;

  const ArticleContent({required this.articleId, required this.markdownBody});
}

class ArticleFilter {
  final ArticleCategory? category;
  final String? searchQuery;

  const ArticleFilter({this.category, this.searchQuery});
}
