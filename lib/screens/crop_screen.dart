import 'package:flutter/material.dart';

import '../services/app_settings_service.dart';
import '../utils/app_text.dart';

class CropScreen extends StatefulWidget {
  const CropScreen({super.key});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  String _season = 'Kharif';
  String _soil = 'Loamy';
  String _water = 'Medium';
  String _goal = 'Profit';

  @override
  Widget build(BuildContext context) {
    final results = _recommendCrops();
    final best = results.first;
    final isTelugu = AppSettingsService.instance.isTelugu;

    return Scaffold(
      appBar: AppBar(title: Text(AppText.get('crops'))),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/crops.jpeg'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Container(
          color: const Color(0xFFE4F1DB).withValues(alpha: 0.08),
          child: Theme(
            data: Theme.of(context).copyWith(
              cardTheme: CardThemeData(
                color: const Color(0xFFE2F2D8).withValues(alpha: 0.86),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFEDF7E7).withValues(alpha: 0.88),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFBCD7AF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFBCD7AF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF5E9B61), width: 1.4),
                ),
              ),
            ),
            child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.get('farmer_need'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isTelugu
                      ? 'మీ భూమి పరిస్థితులకు సరిపోయే పంట, నీటి అవసరం, కోత సమయం, మరియు ప్రమాద సూచనలు ఒకేచోట.'
                      : 'Get crop suggestions, water need, duration, and risk guidance in one place.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.get('farm_inputs'),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    label: AppText.get('season'),
                    value: _season,
                    items: const ['Kharif', 'Rabi', 'Zaid'],
                    onChanged: (value) => setState(() => _season = value),
                  ),
                  const SizedBox(height: 10),
                  _buildDropdown(
                    label: AppText.get('soil_type'),
                    value: _soil,
                    items: const ['Loamy', 'Clay', 'Sandy', 'Black', 'Alluvial'],
                    onChanged: (value) => setState(() => _soil = value),
                  ),
                  const SizedBox(height: 10),
                  _buildDropdown(
                    label: AppText.get('water_availability'),
                    value: _water,
                    items: const ['Low', 'Medium', 'High'],
                    onChanged: (value) => setState(() => _water = value),
                  ),
                  const SizedBox(height: 10),
                  _buildDropdown(
                    label: AppText.get('main_goal'),
                    value: _goal,
                    items: const ['Profit', 'Low Risk', 'Fast Harvest'],
                    onChanged: (value) => setState(() => _goal = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.get('best_fit_farm'),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isTelugu ? '${best.teluguName} (${best.name})' : best.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(best.reason(isTelugu)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _AdviceChip(
                        label: AppText.get('duration'),
                        value:
                            '${best.durationDays} ${AppText.get('days')}',
                      ),
                      _AdviceChip(
                        label: AppText.get('water'),
                        value: _translateOption(best.water),
                      ),
                      _AdviceChip(
                        label: AppText.get('sowing'),
                        value: best.sowingWindow(isTelugu),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionLine(
                    title: AppText.get('fertilizer_tip'),
                    value: best.fertilizerTip(isTelugu),
                  ),
                  _SectionLine(
                    title: AppText.get('risk_watch'),
                    value: best.riskTip(isTelugu),
                  ),
                  _SectionLine(
                    title: AppText.get('market_outlook'),
                    value: best.marketTip(isTelugu),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppText.get('recommended_crops'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...results.map(
            (item) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _scoreColor(item.score).withValues(alpha: 0.18),
                  child: Icon(Icons.grass, color: _scoreColor(item.score)),
                ),
                title: Text(
                  isTelugu ? '${item.teluguName} (${item.name})' : item.name,
                ),
                subtitle: Text(item.reason(isTelugu)),
                trailing: Text(
                  '${item.score}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _scoreColor(item.score),
                  ),
                ),
              ),
            ),
          ),
        ],
          ),
            ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(_translateOption(item)),
            ),
          )
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) onChanged(newValue);
      },
    );
  }

  String _translateOption(String value) {
    switch (value) {
      case 'Kharif':
        return AppText.get('kharif');
      case 'Rabi':
        return AppText.get('rabi');
      case 'Zaid':
        return AppText.get('zaid');
      case 'Loamy':
        return AppText.get('loamy');
      case 'Clay':
        return AppText.get('clay');
      case 'Sandy':
        return AppText.get('sandy');
      case 'Black':
        return AppText.get('black');
      case 'Alluvial':
        return AppText.get('alluvial');
      case 'Low':
        return AppText.get('low');
      case 'Medium':
        return AppText.get('medium');
      case 'High':
        return AppText.get('high');
      case 'Profit':
        return AppText.get('profit');
      case 'Low Risk':
        return AppText.get('low_risk');
      case 'Fast Harvest':
        return AppText.get('fast_harvest');
      default:
        return value;
    }
  }

  List<_CropPlan> _recommendCrops() {
    final crops = [
      _CropPlan(
        name: 'Rice',
        teluguName: 'వరి',
        seasons: {'Kharif'},
        soils: {'Clay', 'Alluvial'},
        water: 'High',
        durationDays: 140,
        fastHarvest: false,
      ),
      _CropPlan(
        name: 'Wheat',
        teluguName: 'గోధుమ',
        seasons: {'Rabi'},
        soils: {'Loamy', 'Alluvial'},
        water: 'Medium',
        durationDays: 125,
        fastHarvest: false,
      ),
      _CropPlan(
        name: 'Maize',
        teluguName: 'మొక్కజొన్న',
        seasons: {'Kharif', 'Rabi'},
        soils: {'Loamy', 'Alluvial', 'Black'},
        water: 'Medium',
        durationDays: 110,
        fastHarvest: true,
      ),
      _CropPlan(
        name: 'Millets',
        teluguName: 'సజ్జలు',
        seasons: {'Kharif', 'Zaid'},
        soils: {'Sandy', 'Loamy', 'Black'},
        water: 'Low',
        durationDays: 90,
        fastHarvest: true,
      ),
      _CropPlan(
        name: 'Chickpea',
        teluguName: 'సెనగ',
        seasons: {'Rabi'},
        soils: {'Loamy', 'Black'},
        water: 'Low',
        durationDays: 105,
        fastHarvest: true,
      ),
      _CropPlan(
        name: 'Groundnut',
        teluguName: 'వేరుశెనగ',
        seasons: {'Kharif', 'Zaid'},
        soils: {'Sandy', 'Loamy'},
        water: 'Medium',
        durationDays: 105,
        fastHarvest: true,
      ),
    ];

    final suggestions = crops.map((crop) {
      int score = 30;
      if (crop.seasons.contains(_season)) score += 25;
      if (crop.soils.contains(_soil)) score += 20;
      if (crop.water == _water) score += 15;
      if (_goal == 'Fast Harvest' && crop.fastHarvest) score += 10;
      if (_goal == 'Low Risk' && crop.water == 'Low') score += 10;
      if (_goal == 'Profit' && crop.water != 'Low') score += 8;
      return crop.copyWith(score: score.clamp(0, 100));
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return suggestions.take(4).toList();
  }

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF2E7D32);
    if (score >= 65) return const Color(0xFFEF6C00);
    return const Color(0xFFC62828);
  }
}

class _CropPlan {
  const _CropPlan({
    required this.name,
    required this.teluguName,
    required this.seasons,
    required this.soils,
    required this.water,
    required this.durationDays,
    required this.fastHarvest,
    this.score = 0,
  });

  final String name;
  final String teluguName;
  final Set<String> seasons;
  final Set<String> soils;
  final String water;
  final int durationDays;
  final bool fastHarvest;
  final int score;

  _CropPlan copyWith({int? score}) {
    return _CropPlan(
      name: name,
      teluguName: teluguName,
      seasons: seasons,
      soils: soils,
      water: water,
      durationDays: durationDays,
      fastHarvest: fastHarvest,
      score: score ?? this.score,
    );
  }

  String reason(bool isTelugu) {
    final seasonLabel = seasons.first;
    if (isTelugu) {
      return 'ఈ పంట ${_translateSeason(seasonLabel)} సీజన్, ${_translateWater(water)} నీటి లభ్యత, మరియు మీ మట్టి పరిస్థితికి సరిపోతుంది.';
    }
    return 'This crop suits the $seasonLabel season, $water water access, and your soil condition.';
  }

  String sowingWindow(bool isTelugu) {
    if (isTelugu) {
      if (seasons.contains('Kharif')) return 'జూన్ - జూలై';
      if (seasons.contains('Rabi')) return 'అక్టోబర్ - నవంబర్';
      return 'ఫిబ్రవరి - మార్చి';
    }
    if (seasons.contains('Kharif')) return 'Jun - Jul';
    if (seasons.contains('Rabi')) return 'Oct - Nov';
    return 'Feb - Mar';
  }

  String fertilizerTip(bool isTelugu) {
    if (isTelugu) {
      return 'మట్టి పరీక్ష తర్వాత బేసల్ ఎరువులు వేయండి. నత్రజనిని దశలవారీగా ఇవ్వండి.';
    }
    return 'Apply basal fertilizer after soil testing and split nitrogen into stages.';
  }

  String riskTip(bool isTelugu) {
    if (isTelugu) {
      return 'అధిక వర్షం, ఎండ దెబ్బ, మరియు ప్రారంభ పురుగు దాడులపై గమనించండి.';
    }
    return 'Watch for excess rain, heat stress, and early pest attack.';
  }

  String marketTip(bool isTelugu) {
    if (isTelugu) {
      return 'కోతకు ముందు స్థానిక మార్కెట్ ధరలు మరియు నిల్వ అవకాశాలు చూడండి.';
    }
    return 'Review local mandi rates and storage options before harvest.';
  }

  static String _translateSeason(String season) {
    switch (season) {
      case 'Kharif':
        return AppText.get('kharif');
      case 'Rabi':
        return AppText.get('rabi');
      case 'Zaid':
        return AppText.get('zaid');
      default:
        return season;
    }
  }

  static String _translateWater(String water) {
    switch (water) {
      case 'Low':
        return AppText.get('low');
      case 'Medium':
        return AppText.get('medium');
      case 'High':
        return AppText.get('high');
      default:
        return water;
    }
  }
}

class _AdviceChip extends StatelessWidget {
  const _AdviceChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEED0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFAFCCA1)),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _SectionLine extends StatelessWidget {
  const _SectionLine({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
