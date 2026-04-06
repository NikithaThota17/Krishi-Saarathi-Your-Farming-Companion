import 'package:flutter/material.dart';

import '../models/market_data.dart';
import '../services/app_settings_service.dart';
import '../services/market_service.dart';
import '../utils/app_text.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  static const List<String> _majorStates = [
    'Andhra Pradesh',
    'Telangana',
    'Karnataka',
    'Tamil Nadu',
    'Kerala',
    'Maharashtra',
    'Gujarat',
    'Madhya Pradesh',
    'Uttar Pradesh',
    'Rajasthan',
    'Punjab',
    'Haryana',
    'Bihar',
    'West Bengal',
  ];

  final MarketService _service = MarketService();
  final TextEditingController _searchController = TextEditingController();

  MarketFilterData? _filters;
  List<MarketPriceRecord> _allRecords = [];
  bool _isLoading = true;
  String? _error;

  String _selectedState = 'All';
  String _selectedCommodity = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final toDate = DateTime.now();
      final fromDate = toDate.subtract(const Duration(days: 7));
      final result = await Future.wait([
        _service.fetchFilters(),
        _service.fetchRecentPrices(fromDate: fromDate, toDate: toDate, maxPages: 6),
      ]);

      if (!mounted) return;
      setState(() {
        _filters = result[0] as MarketFilterData;
        _allRecords = result[1] as List<MarketPriceRecord>;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords();
    final bestMarkets = _topMarkets(records);
    final isTelugu = AppSettingsService.instance.isTelugu;
    final priceSummary = _buildPriceSummary(records, isTelugu);
    final allLabel = AppText.get('all');
    final commodityOptions = <String>{
      'All',
      ...?_filters?.commodities.where((item) => item.trim().isNotEmpty),
    }.toList();
    final stateOptions = _buildStateOptions();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.get('market')),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: AppText.get('refresh'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/market2.jpeg'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Container(
          color: const Color(0xFFFFF1E3).withValues(alpha: 0.08),
          child: Theme(
            data: Theme.of(context).copyWith(
              cardTheme: CardThemeData(
                color: const Color(0xFFFFF1E3).withValues(alpha: 0.84),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF6C00), Color(0xFFFFB74D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText.get('price_insight'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              priceSummary,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: AppText.get('search_market_hint'),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _FilterDropdown(
                              label: AppText.get('filter_state'),
                              value: _selectedState,
                              values: stateOptions,
                              displayText: (value) => value == 'All' ? allLabel : value,
                              onChanged: (value) {
                                setState(() => _selectedState = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _FilterDropdown(
                              label: AppText.get('filter_commodity'),
                              value: _selectedCommodity,
                              values: commodityOptions,
                              displayText: (value) => value == 'All' ? allLabel : value,
                              onChanged: (value) {
                                setState(() => _selectedCommodity = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppText.get('best_markets'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      if (bestMarkets.isEmpty)
                        Text(AppText.get('no_market_opportunities')),
                      ...bestMarkets.map(
                        (entry) => Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0x14EF6C00),
                              child: const Icon(
                                Icons.storefront_outlined,
                                color: Color(0xFFEF6C00),
                              ),
                            ),
                            title: Text(entry.market),
                            subtitle: Text(
                              '${entry.district}, ${entry.state} | ${AppText.get('modal_price')}: Rs ${entry.modalPrice.toStringAsFixed(0)}',
                            ),
                            trailing: Text(
                              entry.commodity,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppText.get('live_price_records'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ...records.take(12).map(
                        (item) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.commodity,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      item.arrivalDate,
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('${item.market}, ${item.district}, ${item.state}'),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _PriceChip(
                                      label: AppText.get('min'),
                                      value: item.minPrice,
                                      unit: item.priceUnit,
                                    ),
                                    _PriceChip(
                                      label: AppText.get('modal'),
                                      value: item.modalPrice,
                                      unit: item.priceUnit,
                                    ),
                                    _PriceChip(
                                      label: AppText.get('max'),
                                      value: item.maxPrice,
                                      unit: item.priceUnit,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
            ),
        ),
      ),
    );
  }

  List<MarketPriceRecord> _filteredRecords() {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _allRecords.where((item) {
      if (_selectedState != 'All' &&
          _normalizeStateName(item.state) != _selectedState) {
        return false;
      }
      if (_selectedCommodity != 'All' && item.commodity != _selectedCommodity) {
        return false;
      }
      if (query.isEmpty) return true;
      return item.commodity.toLowerCase().contains(query) ||
          item.market.toLowerCase().contains(query) ||
          item.district.toLowerCase().contains(query) ||
          item.state.toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) => b.modalPrice.compareTo(a.modalPrice));
    return filtered;
  }

  List<String> _buildStateOptions() {
    final availableStates = <String>{
      ...?_filters?.states.map(_normalizeStateName),
      ..._allRecords.map((record) => _normalizeStateName(record.state)),
    };

    final options = <String>['All'];
    for (final state in _majorStates) {
      if (availableStates.contains(state) || state == 'Andhra Pradesh') {
        options.add(state);
      }
    }
    return options;
  }

  String _normalizeStateName(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'andhra pradesh':
      case 'andhra pradesh ':
      case 'andhra pradesh state':
      case 'ap':
        return 'Andhra Pradesh';
      case 'telangana':
      case 'tg':
        return 'Telangana';
      case 'tamil nadu':
        return 'Tamil Nadu';
      case 'madhya pradesh':
        return 'Madhya Pradesh';
      case 'uttar pradesh':
        return 'Uttar Pradesh';
      case 'west bengal':
        return 'West Bengal';
      default:
        if (value.trim().isEmpty) return value.trim();
        return value
            .trim()
            .split(' ')
            .map((part) {
              if (part.isEmpty) return part;
              return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
            })
            .join(' ');
    }
  }

  List<MarketPriceRecord> _topMarkets(List<MarketPriceRecord> records) {
    final seen = <String>{};
    final top = <MarketPriceRecord>[];
    for (final record in records) {
      final key = '${record.market}-${record.commodity}';
      if (seen.contains(key)) continue;
      seen.add(key);
      top.add(record);
      if (top.length == 4) break;
    }
    return top;
  }

  String _buildPriceSummary(List<MarketPriceRecord> records, bool isTelugu) {
    if (records.isEmpty) {
      return AppText.get('no_market_insight');
    }

    final top = records.first;
    if (isTelugu) {
      return '${top.commodity}కు ${top.market}, ${top.state}లో మెరుగైన ధర కనిపిస్తోంది. అమ్మకానికి ముందు రవాణా ఖర్చు మరియు పరిమాణం చూసుకోండి.';
    }
    return '${top.commodity} currently shows a stronger selling signal in ${top.market}, ${top.state}. Check transport cost and quantity before dispatch.';
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.displayText,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final String Function(String value) displayText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$value'),
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: values
          .map(
            (v) => DropdownMenuItem(
              value: v,
              child: Text(displayText(v)),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD8E7CC)),
      ),
      child: Text('$label: ${value.toStringAsFixed(0)} $unit'),
    );
  }
}
