import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../reads/view_models/reads_view_model.dart';
import '../../../../domain/models/article.dart';
import '../../profile/view_models/profile_view_model.dart';
import '../../profile/views/profile_screen.dart';
import '../../history/view_models/history_view_model.dart';
import '../../history/views/history_screen.dart';
import 'article_detail_screen.dart';

class ReadsScreen extends StatefulWidget {
  final ReadsViewModel viewModel;

  const ReadsScreen({super.key, required this.viewModel});

  @override
  State<ReadsScreen> createState() => _ReadsScreenState();
}

class _ReadsScreenState extends State<ReadsScreen> {
  String _selectedCategoryLabel = 'All';

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'value': null},
    {'label': 'Cycle', 'value': ArticleCategory.menstruation},
    {
      'label': 'Hormones',
      'value': ArticleCategory.menstruation,
    }, // Will match menstruation category
    {'label': 'Nutrition', 'value': ArticleCategory.nutrition},
    {'label': 'Mind', 'value': ArticleCategory.mentalHealth},
  ];

  @override
  Widget build(BuildContext context) {
    final di = ServiceLocator.instance;
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final articles = widget.viewModel.articles;

        // Find the hero/featured article (e.g. the first menstruation article or just first article in the list)
        Article? heroArticle;
        List<Article> feedArticles = articles;
        if (articles.isNotEmpty) {
          heroArticle = articles.first;
          feedArticles = articles.skip(1).toList();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFCF5F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFCF5F5),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'HerAlth',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF9E385A),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFF2C2C2C),
                  size: 26,
                ),
                onPressed: () {
                  final historyVM = HistoryViewModel(
                    di.cycleRepository,
                    di.checkUpRepository,
                    di.reportRepository,
                    userProfileRepository: di.userProfileRepository,
                    cycleEngine: di.cycleEngine,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(viewModel: historyVM),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: Color(0xFF2C2C2C),
                  size: 26,
                ),
                onPressed: () {
                  final profileVM = ProfileViewModel(
                    di.userProfileRepository,
                    di.backupRepository,
                    checkUpRepository: di.checkUpRepository,
                  );
                  profileVM.loadProfileData();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(viewModel: profileVM),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            color: const Color(0xFF9E385A),
            onRefresh: () => widget.viewModel.loadArticles(
              category:
                  _categories.firstWhere(
                        (c) => c['label'] == _selectedCategoryLabel,
                      )['value']
                      as ArticleCategory?,
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Article Card
                  if (heroArticle != null) ...[
                    _buildHeroArticleCard(heroArticle),
                    const SizedBox(height: 24),
                  ],

                  // Category Filter Chips
                  _buildFilterChipsRow(),
                  const SizedBox(height: 24),

                  // "Latest" header
                  if (feedArticles.isNotEmpty) ...[
                    const Text(
                      'LATEST',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Color(0xFF8E8E8E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Feed articles list
                    ...feedArticles.map(
                      (article) => _buildArticleFeedItem(article),
                    ),
                  ] else if (heroArticle == null) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48.0),
                        child: Text(
                          'No articles found in this category.',
                          style: TextStyle(color: Color(0xFF8E8E8E)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroArticleCard(Article article) {
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
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFCF0F0),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFE88A8A).withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.category.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFF9E385A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 24,
                fontFamily: 'serif',
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C2C2C),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${_getReadingTime(article)} min read  ·  Apr 12',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6E6E6E),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF9E385A),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChipsRow() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final label = cat['label'] as String;
          final value = cat['value'] as ArticleCategory?;
          final isSelected = _selectedCategoryLabel == label;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategoryLabel = label;
                });
                widget.viewModel.loadArticles(category: value);
              },
              selectedColor: const Color(0xFF9E385A),
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF2C2C2C),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : const Color(0xFFE88A8A).withOpacity(0.2),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticleFeedItem(Article article) {
    IconData iconData;
    switch (article.category) {
      case ArticleCategory.menstruation:
        iconData = Icons.water_drop_outlined;
        break;
      case ArticleCategory.nutrition:
        iconData = Icons.spa_outlined;
        break;
      case ArticleCategory.mentalHealth:
        iconData = Icons.favorite_border_rounded;
        break;
      default:
        iconData = Icons.insert_emoticon_outlined;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
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
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCF0F0),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE88A8A).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(iconData, color: const Color(0xFF9E385A), size: 20),
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getReadingTime(article)} min read',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E8E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
