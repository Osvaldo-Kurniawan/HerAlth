import 'package:flutter/material.dart';

import '../../../../domain/models/article.dart';
import '../../../../domain/repositories/article_repository.dart';

class ReadsViewModel extends ChangeNotifier {
  final ArticleRepository _articleRepository;

  ReadsViewModel(this._articleRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Article> _articles = [];
  List<Article> get articles => _articles;

  ArticleContent? _currentArticleContent;
  ArticleContent? get currentArticleContent => _currentArticleContent;

  Future<void> loadArticles({ArticleCategory? category, String? query}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final filter = ArticleFilter(category: category, searchQuery: query);
      _articles = await _articleRepository.getArticles(filter);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadArticleContent(String articleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentArticleContent = await _articleRepository.getArticleContent(
        articleId,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
