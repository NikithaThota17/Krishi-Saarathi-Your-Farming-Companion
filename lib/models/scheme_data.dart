class SchemeRecord {
  const SchemeRecord({
    required this.title,
    required this.description,
    required this.slug,
    required this.categories,
    this.ministry,
    required this.tags,
  });

  final String title;
  final String description;
  final String slug;
  final List<String> categories;
  final String? ministry;
  final List<String> tags;
}
