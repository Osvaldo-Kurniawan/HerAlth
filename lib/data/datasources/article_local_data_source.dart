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
    Article(
      id: '7',
      title: 'Eating for Your Cycle: A Phase-by-Phase Guide',
      summary: 'Your nutritional needs shift across your cycle. Learn what to eat during each phase to support energy and hormone balance.',
      contentPath: 'assets/content/cycle_syncing_nutrition.md',
      category: ArticleCategory.nutrition,
      tags: ['Nutrition', 'Cycle Syncing', 'Energy'],
    ),
    Article(
      id: '8',
      title: 'Iron and Your Period: Why It Matters',
      summary: 'Menstrual blood loss can lower iron stores. Discover the signs of low iron and the best food sources to replenish it.',
      contentPath: 'assets/content/iron_and_period.md',
      category: ArticleCategory.nutrition,
      tags: ['Iron', 'Nutrition', 'Energy'],
    ),
    Article(
      id: '9',
      title: 'Foods That Help Ease Bloating',
      summary: 'Cyclical bloating is common, especially before your period. Here is how food choices can reduce water retention and discomfort.',
      contentPath: 'assets/content/bloating_foods.md',
      category: ArticleCategory.nutrition,
      tags: ['Bloating', 'Nutrition', 'Digestion'],
    ),
    Article(
      id: '10',
      title: 'Hydration and Your Menstrual Health',
      summary: 'Water intake affects cramps, energy, and bloating. Learn how much to drink and how hydration changes across your cycle.',
      contentPath: 'assets/content/hydration.md',
      category: ArticleCategory.nutrition,
      tags: ['Hydration', 'Nutrition', 'Self-Care'],
    ),
    Article(
      id: '11',
      title: 'Caffeine, Sugar, and Your Cycle',
      summary: 'Cravings spike in the luteal phase for a reason. Understand how caffeine and sugar interact with your hormones.',
      contentPath: 'assets/content/caffeine_sugar_cycle.md',
      category: ArticleCategory.nutrition,
      tags: ['Caffeine', 'Sugar', 'Nutrition'],
    ),
    Article(
      id: '12',
      title: 'Building a Cycle-Friendly Plate',
      summary: 'A simple, practical framework for balanced meals that support steady energy and mood throughout your cycle.',
      contentPath: 'assets/content/cycle_friendly_plate.md',
      category: ArticleCategory.nutrition,
      tags: ['Meal Planning', 'Nutrition', 'Balance'],
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

      case '7':
        markdown = '''# Eating for Your Cycle: A Phase-by-Phase Guide

Your body's energy and nutrient needs are not static—they shift as hormones rise and fall across your cycle. Eating in tune with these phases can help smooth out energy dips and cravings.

## Menstrual Phase (Days 1–5)
Estrogen and progesterone are at their lowest. Focus on iron-rich foods like leafy greens, lentils, and lean meats to help replace what is lost, along with warming, easy-to-digest meals like soups and stews.

## Follicular Phase (Days 1–13)
Rising estrogen often brings more energy. This is a great window for lighter, fresh foods—salads, sprouted grains, and fermented foods—that support gut health and complement your increasing vitality.

## Ovulatory Phase (Around Day 14)
Energy and metabolism peak. Support this phase with fiber-rich vegetables and antioxidant-dense fruits like berries, which help your body clear the extra estrogen produced during ovulation.

## Luteal Phase (Days 15–28)
Progesterone rises, and cravings for carbohydrates and sugar are common as serotonin dips. Complex carbohydrates (sweet potatoes, oats, brown rice) paired with magnesium-rich foods like nuts and dark chocolate can help stabilize mood and blood sugar.
''';
        break;

      case '8':
        markdown = '''# Iron and Your Period: Why It Matters

Iron is one of the nutrients most affected by menstruation. Every cycle, blood loss carries iron out of the body, and for some people this can add up to a meaningful deficit over time.

## Why Periods Deplete Iron
Iron is a core component of hemoglobin, the protein that carries oxygen in your blood. Heavier or longer periods mean more iron lost, which is why people with heavy menstrual bleeding are at higher risk of iron-deficiency anemia.

## Signs Your Iron May Be Low
- Persistent fatigue, even after a full night's sleep
- Pale skin, brittle nails, or hair thinning
- Dizziness, shortness of breath, or difficulty concentrating

## Food Sources to Prioritize
- **Heme iron (easier to absorb):** red meat, poultry, fish
- **Non-heme iron:** lentils, beans, tofu, spinach, fortified cereals
- **Absorption boosters:** pair iron-rich meals with vitamin C sources like citrus, bell peppers, or tomatoes

If fatigue or heavy bleeding persists, it is worth discussing iron levels with a healthcare professional rather than self-treating with high-dose supplements.
''';
        break;

      case '9':
        markdown = '''# Foods That Help Ease Bloating

Bloating in the days before your period is extremely common, driven largely by hormonal shifts that affect how your body handles water and sodium. What you eat can meaningfully change how you feel.

## Why Bloating Happens
As progesterone rises in the luteal phase, digestion can slow down, and the body tends to retain more water and sodium. This combination often shows up as a feeling of fullness, puffiness, or tightness around the abdomen.

## Foods That Can Help
- **Potassium-rich foods:** bananas, avocados, and sweet potatoes help balance sodium levels
- **Cucumber and watermelon:** high water content supports natural fluid balance
- **Ginger and peppermint tea:** traditionally used to ease digestive discomfort and gas

## What to Minimize
Highly processed and salty foods can worsen water retention. Alcohol and carbonated drinks may also add to that bloated feeling right before your period. Simple swaps—like sparkling water for soda—can make a noticeable difference.
''';
        break;

      case '10':
        markdown = '''# Hydration and Your Menstrual Health

It is easy to overlook water as a factor in period symptoms, but hydration plays a real role in cramps, energy levels, and even bloating.

## Hydration and Cramps
Dehydration can make uterine muscles contract more intensely, which may worsen cramping. Staying consistently hydrated helps muscles function smoothly and can take some edge off period pain.

## Hydration and Energy
Even mild dehydration is linked to fatigue and difficulty concentrating—symptoms that can overlap with normal cycle-related tiredness, making it harder to tell what is causing low energy.

## A Simple Approach
- Aim for steady water intake throughout the day rather than large amounts at once
- Herbal teas (like ginger or chamomile) count toward your fluids and can be soothing
- Water-rich foods—cucumbers, oranges, soups—also contribute to daily hydration

Counterintuitively, drinking enough water can help reduce the water retention that causes bloating, since the body is less likely to hold onto extra fluid when it is consistently hydrated.
''';
        break;

      case '11':
        markdown = '''# Caffeine, Sugar, and Your Cycle

Cravings for coffee and sweets often intensify in the days leading up to your period. Understanding why can help you make choices that feel good rather than fighting the cravings entirely.

## Why Cravings Increase
In the luteal phase, serotonin—a mood-regulating neurotransmitter—naturally dips. Sugar can trigger a quick, temporary serotonin boost, which is part of why sweet cravings tend to cluster before your period.

## Caffeine's Double Edge
Caffeine can offer a short-term energy lift, but it may also heighten anxiety, disrupt sleep, and, for some people, intensify breast tenderness and cramps by constricting blood vessels.

## Finding a Middle Ground
- Pair sweet cravings with protein or fiber (like fruit with nut butter) to soften blood sugar spikes
- Consider swapping a late-day coffee for a lower-caffeine option like green tea
- Complex carbohydrates can satisfy a craving for something comforting while providing more stable energy than refined sugar
''';
        break;

      case '12':
        markdown = '''# Building a Cycle-Friendly Plate

Rather than following a strict diet, a simple, repeatable meal structure can help keep energy, mood, and digestion steadier across your whole cycle.

## The Basic Framework
1. **Protein:** a palm-sized portion (eggs, fish, tofu, legumes) to support satiety and stable blood sugar.
2. **Complex carbohydrates:** whole grains, sweet potatoes, or quinoa for sustained energy.
3. **Healthy fats:** avocado, olive oil, nuts, or seeds to support hormone production.
4. **Colorful vegetables:** at least half the plate, for fiber and micronutrients.

## Adjusting Through the Month
This framework does not need to change dramatically phase to phase—small tweaks are enough. Lean more on iron-rich proteins during your period, lighter proteins and fresh produce during the follicular phase, and a bit more complex carbohydrate during the luteal phase to meet rising energy needs.

## Keep It Realistic
Consistency matters more than perfection. A cycle-friendly plate is meant to be a flexible guide, not a rigid rulebook—the goal is steadier energy and fewer extreme cravings, not restriction.
''';
        break;

      default:
        markdown = '# Article\n\nContent not found.';
    }

    return ArticleContent(articleId: article.id, markdownBody: markdown);
  }
}
