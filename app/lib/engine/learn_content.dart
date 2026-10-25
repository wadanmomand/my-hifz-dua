import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dua_models.dart';

/// Hadith for kids: short authentic hadith with translation + source.
/// Arabic is display-only (never TTS), like duas.
class HadithItem {
  final String id;
  final String topicEn;
  final String topicUr;
  final String topicAr;
  final String arabic;
  final String transliteration;
  final String meaningEn;
  final String meaningUr;
  final String meaningAr;
  final String source;

  const HadithItem({
    required this.id,
    required this.topicEn,
    required this.topicUr,
    required this.topicAr,
    required this.arabic,
    required this.transliteration,
    required this.meaningEn,
    required this.meaningUr,
    required this.meaningAr,
    required this.source,
  });

  factory HadithItem.fromJson(Map<String, dynamic> json) {
    final topic = (json['topic'] as Map).cast<String, dynamic>();
    final meaning = (json['meaning'] as Map).cast<String, dynamic>();
    return HadithItem(
      id: (json['id'] ?? '').toString(),
      topicEn: (topic['en'] ?? '').toString(),
      topicUr: (topic['ur'] ?? '').toString(),
      topicAr: (topic['ar'] ?? '').toString(),
      arabic: (json['arabic'] ?? '').toString(),
      transliteration: (json['transliteration'] ?? '').toString(),
      meaningEn: (meaning['en'] ?? '').toString(),
      meaningUr: (meaning['ur'] ?? '').toString(),
      meaningAr: (meaning['ar'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
    );
  }

  String topicFor(String lang) {
    switch (lang) {
      case 'ur':
        return topicUr.isNotEmpty ? topicUr : topicEn;
      case 'ar':
        return topicAr.isNotEmpty ? topicAr : topicEn;
      default:
        return topicEn;
    }
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

/// Short surah (last 10 of Juz Amma). Arabic is the Uthmani text
/// (api.alquran.cloud, edition quran-uthmani), display-only, never TTS.
class SurahItem {
  final String id;
  final int number;
  final String nameEn;
  final String nameUr;
  final String nameAr;
  final String arabicName;
  final List<String> ayahs;
  final String meaningEn;
  final String meaningUr;
  final String source;

  const SurahItem({
    required this.id,
    required this.number,
    required this.nameEn,
    required this.nameUr,
    required this.nameAr,
    required this.arabicName,
    required this.ayahs,
    required this.meaningEn,
    required this.meaningUr,
    required this.source,
  });

  factory SurahItem.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as Map).cast<String, dynamic>();
    final meaning = (json['meaning'] as Map).cast<String, dynamic>();
    return SurahItem(
      id: (json['id'] ?? '').toString(),
      number: (json['number'] as num?)?.toInt() ?? 0,
      nameEn: (name['en'] ?? '').toString(),
      nameUr: (name['ur'] ?? '').toString(),
      nameAr: (name['ar'] ?? '').toString(),
      arabicName: (json['arabicName'] ?? '').toString(),
      ayahs: ((json['ayahs'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      meaningEn: (meaning['en'] ?? '').toString(),
      meaningUr: (meaning['ur'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
    );
  }

  String nameFor(String lang) {
    switch (lang) {
      case 'ur':
        return nameUr.isNotEmpty ? nameUr : nameEn;
      case 'ar':
        return nameAr.isNotEmpty ? nameAr : nameEn;
      default:
        return nameEn;
    }
  }

  String meaningFor(String lang) {
    switch (lang) {
      case 'ur':
        return meaningUr.isNotEmpty ? meaningUr : meaningEn;
      default:
        return meaningEn;
    }
  }
}

/// One step of Wudu or Salah. Arabic is present only when the step
/// includes something to say; pure-action steps have empty Arabic.
class NamazStep {
  final String id;
  final String titleEn;
  final String titleUr;
  final String arabic;
  final String transliteration;
  final String meaningEn;
  final String meaningUr;

  const NamazStep({
    required this.id,
    required this.titleEn,
    required this.titleUr,
    required this.arabic,
    required this.transliteration,
    required this.meaningEn,
    required this.meaningUr,
  });

  factory NamazStep.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] as Map).cast<String, dynamic>();
    final meaning = (json['meaning'] as Map).cast<String, dynamic>();
    return NamazStep(
      id: (json['id'] ?? '').toString(),
      titleEn: (title['en'] ?? '').toString(),
      titleUr: (title['ur'] ?? '').toString(),
      arabic: (json['arabic'] ?? '').toString(),
      transliteration: (json['transliteration'] ?? '').toString(),
      meaningEn: (meaning['en'] ?? '').toString(),
      meaningUr: (meaning['ur'] ?? '').toString(),
    );
  }

  String titleFor(String lang) =>
      lang == 'ur' && titleUr.isNotEmpty ? titleUr : titleEn;

  String meaningFor(String lang) =>
      lang == 'ur' && meaningUr.isNotEmpty ? meaningUr : meaningEn;
}

/// Everything the app teaches, bundled for navigation.
class AppContent {
  final List<DuaItem> duas;
  final List<HadithItem> hadiths;
  final List<SurahItem> surahs;
  final List<NamazStep> wudu;
  final List<NamazStep> salah;

  const AppContent({
    required this.duas,
    required this.hadiths,
    required this.surahs,
    required this.wudu,
    required this.salah,
  });

  const AppContent.test()
      : duas = const [],
        hadiths = const [],
        surahs = const [],
        wudu = const [],
        salah = const [];

  /// All memorizable item ids, in tracker order: duas, hadith, surahs.
  List<String> get trackableIds => [
        for (final d in duas) d.id,
        for (final h in hadiths) h.id,
        for (final s in surahs) s.id,
      ];

  static Future<AppContent> load() async {
    final duasRaw = await rootBundle.loadString('assets/duas/duas.json');
    final duas = _parseDuas(duasRaw);
    final hadithRaw =
        await rootBundle.loadString('assets/hadith/hadith.json');
    final hadiths = _parseHadith(hadithRaw);
    final surahRaw =
        await rootBundle.loadString('assets/surahs/surahs.json');
    final surahs = _parseSurahs(surahRaw);
    final namazRaw =
        await rootBundle.loadString('assets/namaz/namaz.json');
    final (wudu, salah) = _parseNamaz(namazRaw);
    return AppContent(
        duas: duas, hadiths: hadiths, surahs: surahs, wudu: wudu, salah: salah);
  }

  static List<DuaItem> _parseDuas(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map || decoded['duas'] is! List) {
      throw const FormatException('duas.json must contain a "duas" list');
    }
    return (decoded['duas'] as List)
        .map((e) => DuaItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  static List<HadithItem> _parseHadith(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map || decoded['hadith'] is! List) {
      throw const FormatException('hadith.json must contain a "hadith" list');
    }
    final items = (decoded['hadith'] as List)
        .map((e) => HadithItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    final ids = <String>{};
    for (final h in items) {
      if (h.id.isEmpty) throw StateError('Hadith with empty id');
      if (!ids.add(h.id)) throw StateError('Duplicate hadith id: ${h.id}');
      if (h.arabic.trim().isEmpty) {
        throw StateError('Hadith ${h.id} has empty Arabic text');
      }
      if (h.source.trim().isEmpty) {
        throw StateError('Hadith ${h.id} has no source citation');
      }
      if (h.meaningEn.trim().isEmpty) {
        throw StateError('Hadith ${h.id} has empty English meaning');
      }
    }
    return items;
  }

  static List<SurahItem> _parseSurahs(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map || decoded['surahs'] is! List) {
      throw const FormatException('surahs.json must contain a "surahs" list');
    }
    final items = (decoded['surahs'] as List)
        .map((e) => SurahItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    final ids = <String>{};
    for (final s in items) {
      if (s.id.isEmpty) throw StateError('Surah with empty id');
      if (!ids.add(s.id)) throw StateError('Duplicate surah id: ${s.id}');
      if (s.ayahs.isEmpty) {
        throw StateError('Surah ${s.id} has no ayahs');
      }
      for (final a in s.ayahs) {
        if (a.trim().isEmpty) {
          throw StateError('Surah ${s.id} has an empty ayah');
        }
      }
    }
    return items;
  }

  static (List<NamazStep>, List<NamazStep>) _parseNamaz(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map ||
        decoded['wudu'] is! List ||
        decoded['salah'] is! List) {
      throw const FormatException(
          'namaz.json must contain "wudu" and "salah" lists');
    }
    List<NamazStep> parseList(String key) {
      final steps = (decoded[key] as List)
          .map((e) => NamazStep.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      final ids = <String>{};
      for (final st in steps) {
        if (st.id.isEmpty) throw StateError('Namaz step with empty id');
        if (!ids.add(st.id)) {
          throw StateError('Duplicate namaz step id: ${st.id}');
        }
        if (st.titleEn.trim().isEmpty) {
          throw StateError('Namaz step ${st.id} has empty title');
        }
        if (st.meaningEn.trim().isEmpty) {
          throw StateError('Namaz step ${st.id} has empty meaning');
        }
      }
      return steps;
    }

    return (parseList('wudu'), parseList('salah'));
  }

  /// Test helper: parse bundled JSON files from disk (flutter_test).
  static AppContent parseAll(
      String duasRaw, String hadithRaw, String surahRaw, String namazRaw) {
    final (wudu, salah) = _parseNamaz(namazRaw);
    return AppContent(
      duas: _parseDuas(duasRaw),
      hadiths: _parseHadith(hadithRaw),
      surahs: _parseSurahs(surahRaw),
      wudu: wudu,
      salah: salah,
    );
  }
}
