import '../../domain/models/article.dart';

abstract class ArticleLocalDataSource {
  Future<List<Article>> getArticles(ArticleFilter filter);
  Future<ArticleContent?> getArticleContent(String articleId);
}

class ArticleLocalDataSourceImpl implements ArticleLocalDataSource {
  static const List<Article> _bundledArticles = [
    Article(
      id: '1',
      title: 'Understanding Your Menstrual Cycle',
      summary: 'Learn the phases of your cycle, from menstruation to the luteal phase, and how hormones drive them.',
      contentPath: 'assets/content/understanding_cycle.md',
      category: ArticleCategory.menstruation,
      tags: ['Cycle', 'Hormones', 'Education'],
    ),
    Article(
      id: '2',
      title: 'What Your Cycle Length Can Tell You',
      summary: 'Is your cycle length regular or irregular? Discover what variation means for your reproductive health.',
      contentPath: 'assets/content/cycle_length.md',
      category: ArticleCategory.menstruation,
      tags: ['Cycle', 'Health', 'Insights'],
    ),
    Article(
      id: '3',
      title: 'Understanding Period Cramps',
      summary: 'Why cramps happen, the role of prostaglandins, and natural ways to soothe the pain.',
      contentPath: 'assets/content/cramps.md',
      category: ArticleCategory.menstruation,
      tags: ['Cramps', 'Pain Relief', 'Self-Care'],
    ),
    Article(
      id: '4',
      title: 'Understanding PMS',
      summary: 'Premenstrual syndrome is common but manageable. Learn about symptoms, causes, and supportive lifestyle shifts.',
      contentPath: 'assets/content/pms.md',
      category: ArticleCategory.mentalHealth,
      tags: ['PMS', 'Mental Health', 'Hormones'],
    ),
    Article(
      id: '5',
      title: 'How Stress Can Affect Your Cycle',
      summary: 'Stress affects cortisol, which can delay or disrupt your period. Here is how to manage stress-induced irregularities.',
      contentPath: 'assets/content/stress.md',
      category: ArticleCategory.mentalHealth,
      tags: ['Stress', 'Cortisol', 'Cycle Health'],
    ),
    Article(
      id: '6',
      title: 'Sleep and Your Menstrual Cycle',
      summary: 'Quality sleep is a pillar of hormonal health. Explore how cycle phases affect your sleep patterns.',
      contentPath: 'assets/content/sleep.md',
      category: ArticleCategory.general,
      tags: ['Sleep', 'Hormones', 'Wellness'],
    ),
  ];

  @override
  Future<List<Article>> getArticles(ArticleFilter filter) async {
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

    String markdown;
    switch (articleId) {
      case '1':
        markdown = '''# Understanding Your Menstrual Cycle

The menstrual cycle is more than just your period. It is a complex monthly sequence of hormonal events that prepares your body for pregnancy. On average, a cycle lasts between 24 and 38 days, consisting of four distinct phases.

## 1. The Menstrual Phase (Days 1–5)
Your cycle starts on the first day of your period. This phase is characterized by the shedding of the uterine lining (endometrium) through the vagina, caused by low levels of estrogen and progesterone. 

## 2. The Follicular Phase (Days 1–13)
Overlapping with your period, this phase starts on Day 1 and ends with ovulation. The pituitary gland releases Follicle-Stimulating Hormone (FSH), stimulating the ovaries to produce 5 to 20 small follicles. Only one follicle matures into an egg. As it grows, it secretes estrogen, which thickens the uterine lining to prepare for a fertilized egg.

## 3. The Ovulatory Phase (Around Day 14)
Luteinizing Hormone (LH) surges, causing the mature follicle to rupture and release the egg into the fallopian tube. The egg survives for up to 24 hours. Estrogen levels peak right before ovulation, leading to a rise in social energy and physical stamina.

## 4. The Luteal Phase (Days 15–28)
The ruptured follicle transforms into the corpus luteum, which secretes progesterone and some estrogen. Progesterone keeps the uterine lining thick. If pregnancy doesn't occur, the corpus luteum decays, hormone levels drop, and the cycle begins anew.
''';
        break;

      case '2':
        markdown = '''# What Your Cycle Length Can Tell You

Your cycle length—measured from the first day of one period to the first day of the next—is a vital sign of your overall health. While 28 days is the textbook average, cycles ranging from 21 to 35 days are considered completely normal for adults.

## Normal Variations
It is normal for your cycle length to vary by a few days from month to month. Stress, travel, illness, and changes in weight or exercise intensity can temporarily alter your hormone levels, delaying or accelerating ovulation.

## What Short Cycles Mean
Cycles shorter than 21 days (polymenorrhea) can indicate that ovulation is occurring earlier than usual, or not at all. This might be due to a shortened luteal phase, where progesterone is insufficient to maintain the uterine lining.

## What Long or Missed Cycles Mean
Cycles longer than 35 days (oligomenorrhea) or missed periods (amenorrhea) suggest delayed ovulation. Common culprits include:
- **Polycystic Ovary Syndrome (PCOS):** A hormonal imbalance preventing egg maturation.
- **Thyroid Disorders:** Hypo- or hyperthyroidism affecting metabolic controls.
- **High Stress:** Cortisol suppressing reproductive hormones.
''';
        break;

      case '3':
        markdown = '''# Understanding Period Cramps

Dysmenorrhea, the medical term for menstrual cramps, affects the majority of menstruating individuals at some point. While common, severe pain that disrupts your daily life is not normal and should be evaluated.

## Why Cramps Occur
During menstruation, your uterus contracts to help expel its lining. Hormone-like substances called prostaglandins trigger these muscle contractions. Higher levels of prostaglandins are associated with more severe, painful cramps.

## Primary vs. Secondary Dysmenorrhea
- **Primary:** Common menstrual cramps caused by natural contractions. They usually start 1–2 days before or at the onset of bleeding and fade after a few days.
- **Secondary:** Cramps caused by an underlying medical condition, such as endometriosis, uterine fibroids, or pelvic inflammatory disease. This pain often lasts longer and may get worse over time.

## Natural Support and Management
1. **Heat Therapy:** Applying a heating pad or hot water bottle to the lower abdomen relaxes uterine muscles.
2. **Magnesium and Omega-3s:** Anti-inflammatory nutrients can reduce prostaglandin production.
3. **Gentle Movement:** Light walking or yoga releases endorphins, which act as natural pain relievers.
''';
        break;

      case '4':
        markdown = '''# Understanding PMS

Premenstrual Syndrome (PMS) refers to a combination of physical, emotional, and behavioral symptoms that start in the week or two before your period. These symptoms typically disappear within a few days after your bleeding begins.

## Common Symptoms
- **Physical:** Bloating, breast tenderness, headaches, muscle aches, and fatigue.
- **Emotional:** Irritability, mood swings, anxiety, crying spells, and food cravings.

## What Causes PMS?
While the exact cause is unknown, PMS is believed to be triggered by changes in estrogen and progesterone levels during the luteal phase. These hormonal shifts also affect neurotransmitters in the brain, particularly serotonin, which regulates mood and sleep.

## Lifestyle Adjustments for Relief
- **Balanced Meals:** Eating complex carbohydrates and reducing salt, sugar, and caffeine helps manage bloating and blood sugar swings.
- **Stress Reducers:** Meditation, journaling, and breathing exercises can stabilize mood fluctuations.
- **Supplements:** Calcium, Vitamin B6, and Vitamin E have been shown to help reduce physical and emotional PMS symptoms.
''';
        break;

      case '5':
        markdown = '''# How Stress Can Affect Your Cycle

Your reproductive system is highly sensitive to external influences, and stress is one of the most common disrupters of a regular menstrual cycle.

## The Cortisol Connection
When you are stressed, your body releases cortisol and adrenaline. Under chronic stress, the brain enters survival mode. The hypothalamus—the area of the brain that regulates hormone production—stops releasing GnRH (gonadotropin-releasing hormone).

## Delayed or Missed Periods
Without GnRH, the pituitary gland cannot signal the ovaries to mature and release an egg. This halts ovulation, leading to a delayed period or causing you to skip it entirely (hypothalamic amenorrhea).

## Restoring Balance
If stress is affecting your cycle, consider integrating these habits:
- **Consistent Sleep:** Go to bed at the same time to regulate circadian rhythm.
- **Mindful Activity:** Swap intense workouts for walks, yoga, or swimming.
- **Nutritious Eating:** Ensure you are consuming enough calories to prevent the body from entering a starvation alarm state.
''';
        break;

      case '6':
        markdown = '''# Sleep and Your Menstrual Cycle

Have you ever noticed that you sleep beautifully in some weeks, but struggle to fall asleep in others? Your menstrual cycle and sleep architecture are closely linked.

## Phase-by-Phase Sleep Shifts
- **Menstruation:** Low hormone levels and physical discomfort (cramps, bloating) might make finding a comfortable position difficult.
- **Follicular Phase:** Rising estrogen levels promote higher levels of deep sleep and overall sleep quality.
- **Ovulation:** Peak estrogen and LH can cause a temporary spike in energy, occasionally leading to mild restlessness.
- **Luteal Phase:** Progesterone rises and then falls sharply right before your period. Progesterone has sedative properties, so its drop can cause insomnia, vivid dreams, and night sweats.

## Sleep Hygiene Tips for Your Cycle
1. **Cool Temperature:** Keep your bedroom cool, especially during the luteal phase when core body temperature rises.
2. **Limit Evening Screens:** Blue light suppresses melatonin, which is already affected by hormonal shifts.
3. **Calming Bedtime Routine:** Warm baths, herbal tea, and reading help ease transition into sleep.
''';
        break;

      default:
        markdown = '# Article\n\nContent not found.';
    }

    return ArticleContent(articleId: article.id, markdownBody: markdown);
  }
}
