/// Dua data model. Arabic text is real, verified, and display-only.
class DuaItem {
  final String id;
  final String titleEn;
  final String titleUr;
  final String titleAr;
  final String arabic;
  final String transliteration;
  final String meaningEn;
  final String meaningUr;
  final String meaningAr;
  final String source;
  final String category;

  const DuaItem({
    required this.id,
    required this.titleEn,
    required this.titleUr,
    required this.titleAr,
    required this.arabic,
    required this.transliteration,
    required this.meaningEn,
    required this.meaningUr,
    required this.meaningAr,
    required this.source,
    required this.category,
  });

  factory DuaItem.fromJson(Map<String, dynamic> json) {
    String tri(Map m) => (m['en'] ?? '').toString();
    final title = (json['title'] as Map).cast<String, dynamic>();
    final meaning = (json['meaning'] as Map).cast<String, dynamic>();
    return DuaItem(
      id: (json['id'] ?? '').toString(),
      titleEn: tri(title),
      titleUr: (title['ur'] ?? '').toString(),
      titleAr: (title['ar'] ?? '').toString(),
      arabic: (json['arabic'] ?? '').toString(),
      transliteration: (json['transliteration'] ?? '').toString(),
      meaningEn: tri(meaning),
      meaningUr: (meaning['ur'] ?? '').toString(),
      meaningAr: (meaning['ar'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
    );
  }

  String meaningFor(String lang) {
    switch (lang) {
      case 'ur':
        return meaningUr.isNotEmpty ? meaningUr : meaningEn;
      case 'ar':
        return meaningAr.isNotEmpty ? meaningAr : meaningEn;
      default:
        return meaningEn;
    }
  }
}
