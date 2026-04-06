// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/app_settings_service.dart';
import '../services/farmer_ai_service.dart';
import '../services/weather_service.dart';
import '../utils/app_text.dart';
import '../widgets/feature_card.dart';
import 'assistant_chat_screen.dart';
import 'crop_screen.dart';
import 'market_screen.dart';
import 'schemes_screen.dart';
import 'weather_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    WeatherScreen(),
    CropScreen(),
    MarketScreen(),
    _ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: AppText.get('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.cloud_outlined),
            activeIcon: const Icon(Icons.cloud),
            label: AppText.get('weather'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.agriculture_outlined),
            activeIcon: const Icon(Icons.agriculture),
            label: AppText.get('crops'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.storefront_outlined),
            activeIcon: const Icon(Icons.store),
            label: AppText.get('market'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: AppText.get('profile'),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = screenWidth > 1100
        ? 220.0
        : screenWidth > 800
            ? 190.0
            : 170.0;
    final isTelugu = AppSettingsService.instance.isTelugu;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/farmer.png'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFD9EBC2).withValues(alpha: 0.08),
              const Color(0xFFA7C77C).withValues(alpha: 0.04),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: _GreetingCard()),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const _AboutPage()),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    tooltip: AppText.get('about'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _HomeSearchBar(isTelugu: isTelugu),
              const SizedBox(height: 18),
              Text(
                AppText.get('today_snapshot'),
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _InfoPanel(
                children: const [
                  _HomeWeatherSnapshot(),
                  _InfoLine(titleKey: 'market', descriptionKey: 'home_market_tip'),
                  _InfoLine(titleKey: 'schemes', descriptionKey: 'home_scheme_tip'),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                AppText.get('core_modules'),
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: cardHeight,
                ),
                children: [
                  FeatureCard(
                    icon: Icons.cloud,
                    title: AppText.get('weather'),
                    subtitle: isTelugu
                        ? '\u0c35\u0c3e\u0c24\u0c3e\u0c35\u0c30\u0c23 \u0c38\u0c42\u0c1a\u0c28\u0c32\u0c41 \u0c2e\u0c30\u0c3f\u0c2f\u0c41 \u0c35\u0c4d\u0c2f\u0c35\u0c38\u0c3e\u0c2f \u0c39\u0c46\u0c1a\u0c4d\u0c1a\u0c30\u0c3f\u0c15\u0c32\u0c41'
                        : 'Forecast and farm alerts',
                    gradient: const [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    imageAsset: 'assets/images/farmer.png',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WeatherScreen()),
                    ),
                  ),
                  FeatureCard(
                    icon: Icons.grass,
                    title: AppText.get('crops'),
                    subtitle: isTelugu
                        ? '\u0c2a\u0c02\u0c1f \u0c38\u0c32\u0c39\u0c3e \u0c2e\u0c30\u0c3f\u0c2f\u0c41 \u0c2a\u0c4d\u0c30\u0c23\u0c3e\u0c33\u0c3f\u0c15'
                        : 'Crop advice and planning',
                    gradient: const [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                    imageAsset: 'assets/images/farmer.png',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CropScreen()),
                    ),
                  ),
                  FeatureCard(
                    icon: Icons.currency_rupee,
                    title: AppText.get('market'),
                    subtitle: isTelugu
                        ? '\u0c2e\u0c3e\u0c30\u0c4d\u0c15\u0c46\u0c1f\u0c4d \u0c27\u0c30\u0c32\u0c24\u0c4b \u0c2e\u0c46\u0c30\u0c41\u0c17\u0c48\u0c28 \u0c05\u0c2e\u0c4d\u0c2e\u0c15\u0c02'
                        : 'Sell better with price help',
                    gradient: const [Color(0xFFEF6C00), Color(0xFFFFB74D)],
                    imageAsset: 'assets/images/farmer.png',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MarketScreen()),
                    ),
                  ),
                  FeatureCard(
                    icon: Icons.account_balance,
                    title: AppText.get('schemes'),
                    subtitle: isTelugu
                        ? '\u0c2a\u0c4d\u0c30\u0c2d\u0c41\u0c24\u0c4d\u0c35 \u0c2a\u0c25\u0c15\u0c3e\u0c32\u0c41 \u0c2e\u0c30\u0c3f\u0c2f\u0c41 \u0c32\u0c3e\u0c2d\u0c3e\u0c32\u0c41'
                        : 'Support programs and benefits',
                    gradient: const [Color(0xFF8E24AA), Color(0xFFAB47BC)],
                    imageAsset: 'assets/images/farmer.png',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SchemesScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                AppText.get('today_tasks'),
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              _InfoPanel(
                children: const [
                  _TaskRow(textKey: 'task_forecast'),
                  _TaskRow(textKey: 'task_field'),
                  _TaskRow(textKey: 'task_market'),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3E9D4A), Color(0xFF68C268)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0x22FFFFFF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Icon(
                Icons.account_circle,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.get('greeting_title'),
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppText.get('greeting_subtitle'),
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({required this.isTelugu});

  final bool isTelugu;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AssistantChatScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F7E8).withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF3E9D4A), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppText.get('search_home_hint'),
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmerAssistantDelegate extends SearchDelegate<void> {
  _FarmerAssistantDelegate({required this.isTelugu});

  final bool isTelugu;
  final FarmerAiService _aiService = FarmerAiService();

  final List<_AssistantAnswer> _answers = const [
    _AssistantAnswer(
      triggers: ['rice', 'paddy', 'soil', '\u0c35\u0c30\u0c3f', '\u0c2e\u0c1f\u0c4d\u0c1f\u0c3f'],
      titleEn: 'Soil for rice crop',
      titleTe: '\u0c35\u0c30\u0c3f \u0c2a\u0c02\u0c1f\u0c15\u0c41 \u0c38\u0c30\u0c48\u0c28 \u0c2e\u0c1f\u0c4d\u0c1f\u0c3f',
      bodyEn: 'Rice grows best in clayey or alluvial soil that can hold water well. Slightly acidic to neutral soil is usually suitable. A level field with water control helps rice perform better.',
      bodyTe: '\u0c35\u0c30\u0c3f \u0c2a\u0c02\u0c1f\u0c15\u0c41 \u0c28\u0c40\u0c1f\u0c3f\u0c28\u0c3f \u0c2c\u0c3e\u0c17\u0c3e \u0c28\u0c3f\u0c32\u0c4d\u0c35 \u0c09\u0c02\u0c1a\u0c17\u0c32 \u0c17\u0c21\u0c4d\u0c21\u0c3f \u0c2e\u0c1f\u0c4d\u0c1f\u0c3f \u0c32\u0c47\u0c26\u0c3e \u0c05\u0c32\u0c4d\u0c2f\u0c42\u0c35\u0c3f\u0c2f\u0c32\u0c4d \u0c2e\u0c1f\u0c4d\u0c1f\u0c3f \u0c2e\u0c02\u0c1a\u0c3f\u0c26\u0c3f. \u0c38\u0c4d\u0c35\u0c32\u0c4d\u0c2a \u0c06\u0c2e\u0c4d\u0c32\u0c24\u0c4d\u0c35\u0c02 \u0c28\u0c41\u0c02\u0c1a\u0c3f \u0c38\u0c3e\u0c27\u0c3e\u0c30\u0c23 \u0c2e\u0c1f\u0c4d\u0c1f\u0c3f\u0c35\u0c30\u0c15\u0c41 \u0c05\u0c28\u0c41\u0c15\u0c42\u0c32\u0c02\u0c17\u0c3e \u0c09\u0c02\u0c1f\u0c41\u0c02\u0c26\u0c3f.',
      icon: Icons.grass_outlined,
    ),
    _AssistantAnswer(
      triggers: ['soil', 'land', 'fertility', '\u0c2e\u0c1f\u0c4d\u0c1f\u0c3f', '\u0c28\u0c47\u0c32'],
      titleEn: 'Soil doubt',
      titleTe: '\u0c2e\u0c1f\u0c4d\u0c1f\u0c3f \u0c38\u0c02\u0c26\u0c47\u0c39\u0c02',
      bodyEn: 'Check soil type, drainage and moisture first. Loamy soil suits many crops, clay soil holds more water, and sandy soil dries faster. A soil test is the safest guide before fertilizer use.',
      bodyTe: '??????? ????? ???, ???? ?????, ??? ??????. ???? ????? ???? ?????? ??????, ????? ????? ?????? ???????? ????? ?????????, ???? ????? ?????? ???????????. ????? ????????? ????? ????? ?????? ???? ?????????????.',
      icon: Icons.landscape_outlined,
    ),
    _AssistantAnswer(
      triggers: ['crop', 'season', 'which crop', '\u0c2a\u0c02\u0c1f', '\u0c38\u0c40\u0c1c\u0c28\u0c4d'],
      titleEn: 'Crop selection doubt',
      titleTe: '\u0c2a\u0c02\u0c1f \u0c0e\u0c02\u0c2a\u0c3f\u0c15 \u0c38\u0c02\u0c26\u0c47\u0c39\u0c02',
      bodyEn: 'Choose crop based on season, water availability and soil type. If water is low, millets or pulses may be safer. If water is stable and soil is fertile, rice or maize may fit better.',
      bodyTe: '?????, ???? ?????, ????? ??? ??????? ??? ?????????. ???? ???????? ???? ?????? ???? ????????????? ??????. ???? ???????? ???? ????? ??????? ??? ???? ?????????? ??????????.',
      icon: Icons.agriculture_outlined,
    ),
    _AssistantAnswer(
      triggers: ['pest', 'disease', 'leaf', 'insect', '\u0c2a\u0c41\u0c30\u0c41\u0c17\u0c41', '\u0c35\u0c4d\u0c2f\u0c3e\u0c27\u0c3f', '\u0c06\u0c15\u0c41'],
      titleEn: 'Pest or disease doubt',
      titleTe: '\u0c2a\u0c41\u0c30\u0c41\u0c17\u0c41 \u0c32\u0c47\u0c26\u0c3e \u0c35\u0c4d\u0c2f\u0c3e\u0c27\u0c3f \u0c38\u0c02\u0c26\u0c47\u0c39\u0c02',
      bodyEn: 'Check leaves for spots, curling, holes or insects. Do not spray immediately without identifying the problem. Remove badly affected leaves and watch whether the issue spreads.',
      bodyTe: '?????? ??????, ??????, ???????? ???? ???????? ??????? ??????. ????? ????? ???????????? ?????? ?????? ????????. ???????? ?????????? ?????? ?????? ?????? ???????? ???????? ?????????.',
      icon: Icons.bug_report_outlined,
    ),
    _AssistantAnswer(
      triggers: ['water', 'irrigation', 'drip', '\u0c28\u0c40\u0c30\u0c41', '\u0c2a\u0c3e\u0c30\u0c41\u0c26\u0c32'],
      titleEn: 'Irrigation doubt',
      titleTe: '\u0c28\u0c40\u0c1f\u0c3f \u0c2a\u0c3e\u0c30\u0c41\u0c26\u0c32 \u0c38\u0c02\u0c26\u0c47\u0c39\u0c02',
      bodyEn: 'Irrigate in the morning or evening and avoid overwatering. Check soil moisture before the next watering cycle. Water need changes with crop stage, heat and soil type.',
      bodyTe: '???? ???? ???????? ???? ???????. ???????? ???? ????????. ?????? ???? ?????? ????? ??????? ??? ???? ??????. ??? ??, ????, ????? ??? ??????? ???? ????? ?????????.',
      icon: Icons.water_drop_outlined,
    ),
    _AssistantAnswer(
      triggers: ['fertilizer', 'urea', 'dap', 'nutrient', '\u0c0e\u0c30\u0c41\u0c35\u0c41', '\u0c2f\u0c42\u0c30\u0c3f\u0c2f\u0c3e'],
      titleEn: 'Fertilizer doubt',
      titleTe: '\u0c0e\u0c30\u0c41\u0c35\u0c41 \u0c38\u0c02\u0c26\u0c47\u0c39\u0c02',
      bodyEn: 'Fertilizer should match crop stage and soil need. Split nitrogen into stages instead of applying everything at once. Soil testing is the safest guide for fertilizer decisions.',
      bodyTe: '????? ??? ?? ????? ????? ????????? ?????????. ????????? ??????? ??????? ????????? ???????. ????? ??????????? ????? ?????? ????? ??????.',
      icon: Icons.spa_outlined,
    ),
    _AssistantAnswer(
      triggers: ['market', 'price', 'mandi', 'sell', '\u0c27\u0c30', '\u0c2e\u0c3e\u0c30\u0c4d\u0c15\u0c46\u0c1f\u0c4d', '\u0c05\u0c2e\u0c4d\u0c2e\u0c15\u0c02'],
      titleEn: 'Market doubt',
      titleTe: '\u0c2e\u0c3e\u0c30\u0c4d\u0c15\u0c46\u0c1f\u0c4d \u0c38\u0c02\u0c26\u0c47\u0c39\u0c02',
      bodyEn: 'Compare mandi price, transport cost and quantity before sale. A higher price market is not always better if travel cost is high or quantity is small.',
      bodyTe: '?????????? ????? ???????? ??, ????? ?????, ??????? ????????. ????? ?????? ?? ???? ???????? ??????? ?????? ????. ?????? ????? ????????? ???? ?????????.',
      icon: Icons.currency_rupee,
    ),
  ];

  @override
  String get searchFieldLabel => AppText.get('search_home_hint');

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildContent();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    final normalized = _normalize(query);
    if (normalized.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            AppText.get('search_empty'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return FutureBuilder<String?>(
      future: _aiService.answer(question: normalized, isTelugu: isTelugu),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final aiAnswer = snapshot.data?.trim();
        if (aiAnswer != null && aiAnswer.isNotEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AssistantResultCard(
                title: isTelugu ? '\u0c30\u0c48\u0c24\u0c41 AI \u0c38\u0c39\u0c3e\u0c2f\u0c02' : 'Farmer AI Assistant',
                body: aiAnswer,
                icon: Icons.smart_toy_outlined,
              ),
            ],
          );
        }

        final matches = _answers
            .map((answer) => MapEntry(answer, answer.score(normalized)))
            .where((entry) => entry.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (matches.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppText.get('search_no_results'),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length.clamp(0, 3),
          itemBuilder: (context, index) {
            final answer = matches[index].key;
            return _AssistantResultCard(
              title: answer.title(isTelugu),
              body: answer.body(isTelugu),
              icon: answer.icon,
            );
          },
        );
      },
    );
  }

  String _normalize(String value) => value.trim().toLowerCase();
}

class _AssistantResultCard extends StatelessWidget {
  const _AssistantResultCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: const Color(0x142E7D32),
              child: Icon(icon, color: const Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantAnswer {
  const _AssistantAnswer({
    required this.triggers,
    required this.titleEn,
    required this.titleTe,
    required this.bodyEn,
    required this.bodyTe,
    required this.icon,
  });

  final List<String> triggers;
  final String titleEn;
  final String titleTe;
  final String bodyEn;
  final String bodyTe;
  final IconData icon;

  String title(bool isTelugu) => isTelugu ? titleTe : titleEn;
  String body(bool isTelugu) => isTelugu ? bodyTe : bodyEn;

  int score(String query) {
    var score = 0;
    final words = query.split(RegExp(r'\s+'));
    for (final trigger in triggers) {
      final key = trigger.toLowerCase();
      if (query.contains(key)) {
        score += key.length > 4 ? 3 : 2;
      } else if (words.any((word) => key.contains(word) || word.contains(key))) {
        score += 1;
      }
    }
    return score;
  }
}

class _HomeWeatherSnapshot extends StatelessWidget {
  const _HomeWeatherSnapshot();

  Future<_WeatherSummaryState> _loadSummary() async {
    final service = WeatherService();
    final location = WeatherService.starterLocations.first;
    final weather = await service.fetchWeather(location);

    if (weather.currentRainMm > 0.2 || weather.currentWeatherCode >= 51) {
      return const _WeatherSummaryState(
        behaviorKey: 'weather_rainy',
        advisoryKey: 'advisory_rainy',
      );
    }
    if (weather.currentTempC >= 34) {
      return const _WeatherSummaryState(
        behaviorKey: 'weather_hot',
        advisoryKey: 'advisory_hot',
      );
    }
    if (weather.currentWeatherCode <= 3) {
      return const _WeatherSummaryState(
        behaviorKey: 'weather_mild',
        advisoryKey: 'advisory_normal',
      );
    }
    return const _WeatherSummaryState(
      behaviorKey: 'weather_normal',
      advisoryKey: 'advisory_normal',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_WeatherSummaryState>(
      future: _loadSummary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _InfoLine(
            titleKey: 'weather',
            descriptionText: AppText.get('home_weather_loading'),
          );
        }

        if (!snapshot.hasData) {
          return _InfoLine(
            titleKey: 'weather',
            descriptionText: AppText.get('home_weather_unavailable'),
          );
        }

        final data = snapshot.data!;
        return _InfoLine(
          titleKey: 'weather',
          descriptionText: '${AppText.get(data.behaviorKey)} ${AppText.get(data.advisoryKey)}',
        );
      },
    );
  }
}

class _WeatherSummaryState {
  const _WeatherSummaryState({
    required this.behaviorKey,
    required this.advisoryKey,
  });

  final String behaviorKey;
  final String advisoryKey;
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6E8).withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4E0AD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.titleKey,
    this.descriptionKey,
    this.descriptionText,
  });

  final String titleKey;
  final String? descriptionKey;
  final String? descriptionText;

  @override
  Widget build(BuildContext context) {
    final description = descriptionText ?? AppText.get(descriptionKey!);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '${AppText.get(titleKey)}: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: description),
          ],
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.textKey});

  final String textKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Expanded(child: Text(AppText.get(textKey))),
        ],
      ),
    );
  }
}
class _ProfilePage extends StatefulWidget {
  const _ProfilePage();

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _cropsController = TextEditingController();
  String _phone = 'Not set';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _villageController.dispose();
    _cropsController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _phone = prefs.getString('farmer_phone') ?? 'Not set';
      _nameController.text = prefs.getString('farmer_name') ?? 'Farmer';
      _villageController.text = prefs.getString('farmer_village') ?? '';
      _cropsController.text = prefs.getString('farmer_preferred_crops') ?? 'Wheat, Rice, Maize';
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('farmer_name', _nameController.text.trim());
    await prefs.setString('farmer_village', _villageController.text.trim());
    await prefs.setString('farmer_preferred_crops', _cropsController.text.trim());
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppText.get('profile_saved'))));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF6FBF1), Color(0xFFE3F3D5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Color(0xFF2E7D32), child: Icon(Icons.person, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_nameController.text.isEmpty ? AppText.get('farmer_profile') : _nameController.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(_villageController.text.isEmpty ? AppText.get('village_preferences') : _villageController.text),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ProfileTile(icon: Icons.phone_outlined, title: AppText.get('phone_number'), value: _phone == 'Not set' ? AppText.get('guest_mode') : '+91 $_phone'),
            _EditableProfileField(icon: Icons.person_outline, label: AppText.get('farmer_name'), controller: _nameController),
            _EditableProfileField(icon: Icons.place_outlined, label: AppText.get('village_location'), controller: _villageController),
            _EditableProfileField(icon: Icons.grass_outlined, label: AppText.get('preferred_crops'), controller: _cropsController),
            Card(
              child: ListTile(
                leading: const Icon(Icons.language_outlined, color: Color(0xFF2E7D32)),
                title: Text(AppText.get('language')),
                subtitle: Text(AppSettingsService.instance.isTelugu ? '\u0c24\u0c46\u0c32\u0c41\u0c17\u0c41' : 'English'),
                trailing: DropdownButton<String>(
                  value: AppSettingsService.instance.languageCode,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'te', child: Text('\u0c24\u0c46\u0c32\u0c41\u0c17\u0c41')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (value) async {
                    if (value == null) return;
                    await AppSettingsService.instance.setLanguage(value);
                    if (!mounted) return;
                    setState(() {});
                  },
                ),
              ),
            ),
            _ProfileTile(icon: Icons.bookmark_border, title: AppText.get('saved_schemes'), value: AppText.get('saved_schemes_hint')),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
                title: Text(AppText.get('about')),
                subtitle: Text(AppText.get('about_title')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const _AboutPage()));
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveProfile,
                icon: const Icon(Icons.save_outlined),
                label: Text(_isSaving ? '...' : AppText.get('save_profile')),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: Text(AppText.get('logout')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}

class _EditableProfileField extends StatelessWidget {
  const _EditableProfileField({required this.icon, required this.label, required this.controller});

  final IconData icon;
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Icon(icon, color: const Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppText.get('about'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppText.get('about_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(AppText.get('about_desc')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite_outline, color: Color(0xFF2E7D32)),
              title: Text(AppText.get('who_is_this_for')),
              subtitle: Text(AppText.get('who_is_this_for_desc')),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.handshake_outlined, color: Color(0xFF2E7D32)),
              title: Text(AppText.get('main_purpose')),
              subtitle: Text(AppText.get('main_purpose_desc')),
            ),
          ),
        ],
      ),
    );
  }
}
