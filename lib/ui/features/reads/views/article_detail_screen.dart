import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../domain/models/article.dart';
import '../view_models/reads_view_model.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  final ReadsViewModel viewModel;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    required this.viewModel,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  List<Article> _recommendedArticles = [];

  @override
  void initState() {
    super.initState();
    _loadContentAndRecommendations();
  }

  @override
  void didUpdateWidget(covariant ArticleDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.article.id != widget.article.id) {
      _loadContentAndRecommendations();
    }
  }

  Future<void> _loadContentAndRecommendations() async {
    await widget.viewModel.loadArticleContent(widget.article.id);

    // Load recommendations (other articles in the same category, or just different ones)
    final di = ServiceLocator.instance;
    final all = await di.articleRepository.getArticles(const ArticleFilter());

    setState(() {
      _recommendedArticles = all
          .where((element) => element.id != widget.article.id)
          .take(2)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final content = widget.viewModel.currentArticleContent;

        return Scaffold(
          backgroundColor: const Color(0xFFFCF5F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFCF5F5),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF2C2C2C),
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.ios_share_rounded,
                  color: Color(0xFF2C2C2C),
                  size: 22,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Article link copied to clipboard'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.bookmark_border_rounded,
                  color: Color(0xFF2C2C2C),
                  size: 24,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to bookmarks')),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body:
              widget.viewModel.isLoading &&
                  content?.articleId != widget.article.id
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF9E385A)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Category Tag
                      Text(
                        widget.article.category.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Color(0xFF9E385A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Title
                      Text(
                        widget.article.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Meta info
                      Text(
                        '${_getReadingTime(widget.article)} min read  ·  Apr 12, 2026',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E8E),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFF2ECEC), height: 1),
                      const SizedBox(height: 24),
                      // Body text rendered nicely
                      if (content != null)
                        _buildRenderedMarkdown(content.markdownBody)
                      else
                        Text(
                          widget.article.summary,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                      const SizedBox(height: 48),

                      // Editorial Reviewed footer
                      Center(
                        child: Text(
                          'Reviewed by HerAlth editorial',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF2C2C2C).withOpacity(0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      const Divider(color: Color(0xFFF2ECEC), height: 1),
                      const SizedBox(height: 32),

                      // Recommended Section
                      if (_recommendedArticles.isNotEmpty) ...[
                        const Text(
                          'READ NEXT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Color(0xFF8E8E8E),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._recommendedArticles.map(_buildRecommendedCard),
                      ],
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildRenderedMarkdown(String body) {
    // Simple custom markdown line-by-line renderer
    final lines = body.split('\n');
    final children = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        children.add(const SizedBox(height: 14));
        continue;
      }

      if (line.startsWith('# ')) {
        // We skip rendering the title again if it matches the first line
        if (i == 0) continue;
        children.add(
          Text(
            line.substring(2),
            style: const TextStyle(
              fontSize: 22,
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        children.add(
          Text(
            line.substring(3),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
        );
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        children.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6.0, right: 8.0, left: 4.0),
                child: Icon(Icons.circle, size: 6, color: Color(0xFF9E385A)),
              ),
              Expanded(
                child: Text(
                  line.substring(2),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2C2C2C),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (line.startsWith('1. ') ||
          line.startsWith('2. ') ||
          line.startsWith('3. ') ||
          line.startsWith('4. ')) {
        children.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.substring(0, 3),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9E385A),
                ),
              ),
              Expanded(
                child: Text(
                  line.substring(3),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2C2C2C),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        children.add(
          Text(
            line,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF2C2C2C),
              height: 1.55,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildRecommendedCard(Article article) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              article: article,
              viewModel: widget.viewModel,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.category.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Color(0xFF9E385A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_getReadingTime(article)} min read',
              style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E8E)),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF2ECEC), height: 1),
          ],
        ),
      ),
    );
  }

  int _getReadingTime(Article article) {
    switch (article.id) {
      case '1':
      case '2':
      case '6':
        return 6;
      case '3':
        return 4;
      case '4':
      case '5':
        return 5;
      default:
        return 5;
    }
  }
}
