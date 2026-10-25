import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_hifz_duas/engine/learn_content.dart';

/// Validates the real bundled content files: counts, unique ids,
/// required fields, and the exact ayah counts of the last 10 surahs.
void main() {
  late AppContent content;

  setUpAll(() {
    content = AppContent.parseAll(
      File('assets/duas/duas.json').readAsStringSync(),
      File('assets/hadith/hadith.json').readAsStringSync(),
      File('assets/surahs/surahs.json').readAsStringSync(),
      File('assets/namaz/namaz.json').readAsStringSync(),
    );
  });

  test('duas: 30 entries, unique ids, all fields present', () {
    expect(content.duas.length, 30);
    final ids = content.duas.map((d) => d.id).toSet();
    expect(ids.length, 30);
    for (final d in content.duas) {
      expect(d.arabic.trim().isNotEmpty, isTrue, reason: d.id);
      expect(d.source.trim().isNotEmpty, isTrue, reason: d.id);
      expect(d.meaningEn.trim().isNotEmpty, isTrue, reason: d.id);
      expect(d.titleEn.trim().isNotEmpty, isTrue, reason: d.id);
    }
  });

  test('hadith: 20 entries, unique ids, all fields present', () {
    expect(content.hadiths.length, 20);
    final ids = content.hadiths.map((h) => h.id).toSet();
    expect(ids.length, 20);
    for (final h in content.hadiths) {
      expect(h.arabic.trim().isNotEmpty, isTrue, reason: h.id);
      expect(h.source.trim().isNotEmpty, isTrue, reason: h.id);
      expect(h.meaningEn.trim().isNotEmpty, isTrue, reason: h.id);
      expect(h.topicEn.trim().isNotEmpty, isTrue, reason: h.id);
    }
  });

  test('surahs: last 10 surahs, 48 ayahs total, exact counts', () {
    expect(content.surahs.length, 10);
    final numbers = content.surahs.map((s) => s.number).toList();
    expect(numbers, [105, 106, 107, 108, 109, 110, 111, 112, 113, 114]);
    final counts = content.surahs.map((s) => s.ayahs.length).toList();
    expect(counts, [5, 4, 7, 3, 6, 3, 5, 4, 5, 6]);
    expect(counts.reduce((a, b) => a + b), 48);
    for (final s in content.surahs) {
      expect(s.source.contains('Quran'), isTrue, reason: s.id);
    }
  });

  test('namaz: wudu 10 steps, salah 17 steps, all titled', () {
    expect(content.wudu.length, 10);
    expect(content.salah.length, 17);
    final ids = [
      ...content.wudu.map((s) => s.id),
      ...content.salah.map((s) => s.id),
    ].toSet();
    expect(ids.length, 27);
    for (final st in [...content.wudu, ...content.salah]) {
      expect(st.titleEn.trim().isNotEmpty, isTrue, reason: st.id);
      expect(st.meaningEn.trim().isNotEmpty, isTrue, reason: st.id);
    }
  });

  test('tracker ids: 60 memorizable items', () {
    expect(content.trackableIds.length, 60);
    expect(content.trackableIds.toSet().length, 60);
  });
}
