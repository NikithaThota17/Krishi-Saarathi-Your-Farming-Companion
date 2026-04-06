import 'dart:async';

import 'package:flutter/material.dart';

import '../models/scheme_data.dart';
import '../services/scheme_service.dart';
import '../utils/app_text.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  final SchemeService _service = SchemeService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<SchemeRecord> _schemes = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchSchemes(pageNumber: 1, pageSize: 30);
      if (!mounted) return;
      setState(() => _schemes = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () async {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      try {
        final data = value.trim().isEmpty
            ? await _service.fetchSchemes(pageNumber: 1, pageSize: 30)
            : await _service.searchSchemes(value, pageNumber: 1, pageSize: 30);
        if (!mounted) return;
        setState(() {
          _schemes = data;
          if (_selectedCategory != 'All' &&
              !_allCategories(data).contains(_selectedCategory)) {
            _selectedCategory = 'All';
          }
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allLabel = AppText.get('all');
    final categories = ['All', ..._allCategories(_schemes)];
    final visible = _schemes.where((scheme) {
      if (_selectedCategory == 'All') return true;
      return scheme.categories.contains(_selectedCategory);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.get('schemes_screen_title')),
        actions: [
          IconButton(
            onPressed: _loadInitial,
            icon: const Icon(Icons.refresh),
            tooltip: AppText.get('refresh'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/schemes.jpeg'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Container(
          color: const Color(0xFFF7EAFE).withValues(alpha: 0.08),
          child: Theme(
            data: Theme.of(context).copyWith(
              cardTheme: CardThemeData(
                color: const Color(0xFFF7EAFE).withValues(alpha: 0.84),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              chipTheme: Theme.of(context).chipTheme.copyWith(
                backgroundColor: const Color(0xFFF3DBFF),
                selectedColor: const Color(0xFFD8B2F2),
              ),
            ),
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E24AA), Color(0xFFAB47BC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.get('schemes'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppText.get('source_india'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: AppText.get('search_scheme_hint'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories
                    .map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat == 'All' ? allLabel : cat),
                          selected: _selectedCategory == cat,
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${visible.length} ${AppText.get('live_schemes_count')}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  AppText.get('source_india'),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
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
                      : visible.isEmpty
                          ? Center(child: Text(AppText.get('no_schemes_found')))
                          : ListView.builder(
                              itemCount: visible.length,
                              itemBuilder: (context, index) {
                                final scheme = visible[index];
                                final categoriesText = scheme.categories.isEmpty
                                    ? AppText.get('general')
                                    : scheme.categories.join(' | ');
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          scheme.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          categoriesText,
                                          style: const TextStyle(
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if ((scheme.ministry ?? '').trim().isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            '${AppText.get('ministry')}: ${scheme.ministry}',
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Text(
                                          scheme.description.trim().isEmpty
                                              ? AppText.get('description_unavailable')
                                              : scheme.description.trim(),
                                        ),
                                        if (scheme.tags.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: scheme.tags
                                                .take(5)
                                                .map(
                                                  (tag) => Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color(0x142E7D32),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        999,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      tag,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xFF2E7D32),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ],
                                        if (scheme.slug.trim().isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          SelectableText(
                                            'https://www.india.gov.in/my-government/schemes/${scheme.slug}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
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

  List<String> _allCategories(List<SchemeRecord> schemes) {
    final set = <String>{};
    for (final scheme in schemes) {
      for (final category in scheme.categories) {
        if (category.trim().isNotEmpty) {
          set.add(category.trim());
        }
      }
    }
    final list = set.toList()..sort();
    return list;
  }
}
