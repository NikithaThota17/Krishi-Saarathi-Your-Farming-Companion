import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/scheme_data.dart';

class SchemeService {
  static const String _baseUrl =
      'https://www.india.gov.in/my-government/schemes/search/dataservices';

  Future<List<SchemeRecord>> fetchSchemes({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _postJson('getschemes', {
        'categories': <String>[],
        'mustFilter': <dynamic>[],
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      });
      final data = response['schemesResponse'] as Map<String, dynamic>?;
      if (data != null) {
        final parsed = _parseResults(data['results'] as List<dynamic>? ?? const []);
        if (parsed.isNotEmpty) return parsed;
      }
    } catch (_) {}

    // Fallback endpoint used by the same portal frontend.
    try {
      final response = await _postJson('getSchemeByFilterFromApi', {
        'facetFilter': <dynamic>[],
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      });
      final data = response['schemesExternalResponse'] as Map<String, dynamic>?;
      if (data != null) {
        final parsed = _parseResults(data['results'] as List<dynamic>? ?? const []);
        if (parsed.isNotEmpty) return parsed;
      }
    } catch (_) {}

    return _fallbackSchemes();
  }

  Future<List<SchemeRecord>> searchSchemes(
    String query, {
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    if (query.trim().isEmpty) {
      return fetchSchemes(pageNumber: 1, pageSize: pageSize);
    }

    try {
      final response = await _postJson('getsuggestion_freesearch', {
        'query': query.trim(),
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      });
      final data = response['searchResponse'] as Map<String, dynamic>?;
      if (data != null) {
        return _parseResults(data['results'] as List<dynamic>? ?? const []);
      }
    } catch (_) {}

    // Fallback if search endpoint is unavailable.
    final all = await fetchSchemes(pageNumber: 1, pageSize: pageSize * 2);
    final q = query.toLowerCase();
    return all.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q) ||
          s.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  List<SchemeRecord> _parseResults(List<dynamic> rows) {
    return rows.map((raw) {
      final row = raw as Map<String, dynamic>;
      final categories = _asStringList(row['schemeCategory']);
      final tags = _asStringList(row['tags']);
      return SchemeRecord(
        title: row['title']?.toString() ?? 'Untitled Scheme',
        description: row['description']?.toString() ?? '',
        slug: row['slug']?.toString() ?? '',
        categories: categories,
        ministry: row['ministry']?.toString(),
        tags: tags,
      );
    }).toList();
  }

  Future<Map<String, dynamic>> _postJson(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Request failed: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return const [];
  }

  List<SchemeRecord> _fallbackSchemes() {
    return const [
      SchemeRecord(
        title: 'PM-KISAN',
        description: 'Income support scheme for eligible farmer families.',
        slug: 'pm-kisan-samman-nidhi',
        categories: ['Agriculture,Rural & Environment'],
        ministry: 'Ministry Of Agriculture and Farmers Welfare',
        tags: ['Farmer', 'Income Support'],
      ),
      SchemeRecord(
        title: 'Kisan Credit Card',
        description: 'Short-term formal credit support for farmers.',
        slug: 'kisan-credit-card',
        categories: ['Agriculture,Rural & Environment'],
        ministry: 'Ministry Of Finance',
        tags: ['Farmer', 'Credit'],
      ),
    ];
  }
}
