import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/market_data.dart';

class MarketService {
  static const String _baseUrl = 'https://api.agmarknet.gov.in/v1';

  Future<MarketFilterData> fetchFilters() async {
    try {
      final uri = Uri.parse('$_baseUrl/daily-price-arrival/filters');
      final response = await http.get(
        uri,
        headers: const {'Accept-Language': 'en'},
      );
      if (response.statusCode != 200) {
        throw Exception('Unable to fetch market filters.');
      }

      final Map<String, dynamic> json = jsonDecode(response.body);
      final data = json['data'] as Map<String, dynamic>? ?? {};

      final states = _readFieldList(data['state_data'], 'state_name');
      final markets = _readFieldList(data['market_data'], 'mkt_name');
      final commodities = _readFieldList(data['cmdt_data'], 'cmdt_name');

      if (states.isEmpty && markets.isEmpty && commodities.isEmpty) {
        return _fallbackFilters();
      }
      return MarketFilterData(
        states: states,
        markets: markets,
        commodities: commodities,
      );
    } catch (_) {
      return _fallbackFilters();
    }
  }

  Future<List<MarketPriceRecord>> fetchRecentPrices({
    required DateTime fromDate,
    required DateTime toDate,
    int maxPages = 4,
  }) async {
    final records = <MarketPriceRecord>[];

    try {
      for (int page = 1; page <= maxPages; page++) {
        final uri = Uri.parse('$_baseUrl/daily-price-arrival/report').replace(
          queryParameters: {
            'from_date': _formatDate(fromDate),
            'to_date': _formatDate(toDate),
            'page': '$page',
          },
        );

        final response =
            await http.get(uri, headers: const {'Accept-Language': 'en'});
        if (response.statusCode != 200) {
          throw Exception('Unable to fetch market report.');
        }

        final Map<String, dynamic> json = jsonDecode(response.body);
        final data = json['data'] as Map<String, dynamic>? ?? {};
        final blocks = data['records'] as List<dynamic>? ?? const [];
        if (blocks.isEmpty) break;

        final block = blocks.first as Map<String, dynamic>? ?? {};
        final pageRows = block['data'] as List<dynamic>? ?? const [];
        for (final raw in pageRows) {
          final row = raw as Map<String, dynamic>? ?? {};
          records.add(
            MarketPriceRecord(
              commodity: row['cmdt_name']?.toString() ?? 'Unknown',
              state: row['state_name']?.toString() ?? 'Unknown',
              district: row['district_name']?.toString() ?? 'Unknown',
              market: row['market_name']?.toString() ?? 'Unknown',
              variety: row['variety_name']?.toString() ?? 'N/A',
              grade: row['grade_name']?.toString() ?? 'N/A',
              arrivalDate: row['arrival_date']?.toString() ?? '-',
              minPrice: _parseNum(row['min_price']),
              modalPrice: _parseNum(row['model_price']),
              maxPrice: _parseNum(row['max_price']),
              priceUnit: row['unit_name_price']?.toString() ?? '',
              arrivalQty: _parseNum(row['arrival_qty']),
              arrivalUnit: row['unit_name_arrival']?.toString() ?? '',
            ),
          );
        }

        if (pageRows.isEmpty) break;
      }
    } catch (_) {
      if (records.isEmpty) return _fallbackRecords();
    }

    return records.isEmpty ? _fallbackRecords() : records;
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static double _parseNum(dynamic value) {
    if (value == null) return 0;
    final cleaned = value.toString().replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0;
  }

  static List<String> _readFieldList(dynamic source, String key) {
    final rows = source as List<dynamic>? ?? const [];
    final values = rows
        .map((e) => (e as Map<String, dynamic>? ?? {})[key]?.toString() ?? '')
        .where((e) => e.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return values;
  }

  static MarketFilterData _fallbackFilters() {
    return const MarketFilterData(
      states: ['Maharashtra', 'Karnataka', 'Telangana', 'Punjab', 'Uttar Pradesh'],
      markets: ['Pune APMC', 'Azadpur', 'Lucknow', 'Bengaluru', 'Hyderabad'],
      commodities: ['Wheat', 'Rice', 'Maize', 'Chickpea', 'Groundnut'],
    );
  }

  static List<MarketPriceRecord> _fallbackRecords() {
    return const [
      MarketPriceRecord(
        commodity: 'Wheat',
        state: 'Uttar Pradesh',
        district: 'Lucknow',
        market: 'Lucknow',
        variety: 'FAQ',
        grade: 'A',
        arrivalDate: 'N/A',
        minPrice: 2200,
        modalPrice: 2350,
        maxPrice: 2480,
        priceUnit: 'Rs./Quintal',
        arrivalQty: 12.3,
        arrivalUnit: 'Metric Tonnes',
      ),
      MarketPriceRecord(
        commodity: 'Rice',
        state: 'Punjab',
        district: 'Ludhiana',
        market: 'Ludhiana',
        variety: 'Common',
        grade: 'A',
        arrivalDate: 'N/A',
        minPrice: 1950,
        modalPrice: 2080,
        maxPrice: 2200,
        priceUnit: 'Rs./Quintal',
        arrivalQty: 15.8,
        arrivalUnit: 'Metric Tonnes',
      ),
    ];
  }
}
