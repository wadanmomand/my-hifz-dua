import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dua_models.dart';

/// Loads and validates the bundled dua list.
class DuaLoader {
  static const assetPath = 'assets/duas/duas.json';

  static List<DuaItem> loadFromJsonString(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map || decoded['duas'] is! List) {
      throw const FormatException('duas.json must contain a "duas" list');
    }
    final items = (decoded['duas'] as List)
        .map((e) => DuaItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    validate(items);
    return items;
  }

  static void validate(List<DuaItem> items) {
    if (items.length < 6) {
      throw StateError('Need at least 6 duas, found ${items.length}');
    }
    final ids = <String>{};
    for (final d in items) {
      if (d.id.isEmpty) throw StateError('Dua with empty id');
      if (!ids.add(d.id)) throw StateError('Duplicate dua id: ${d.id}');
      if (d.arabic.trim().isEmpty) {
        throw StateError('Dua ${d.id} has empty Arabic text');
      }
      if (d.source.trim().isEmpty) {
        throw StateError('Dua ${d.id} has no source citation');
      }
      if (d.meaningEn.trim().isEmpty) {
        throw StateError('Dua ${d.id} has empty English meaning');
      }
    }
  }

  static Future<List<DuaItem>> load() async {
    final raw = await rootBundle.loadString(assetPath);
    return loadFromJsonString(raw);
  }
}
