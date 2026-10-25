import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// On-device persistence: XP, stars, streak, learned duas, match stats,
/// and the Hifz Tracker (per-item status for duas, hadith and surahs).
class DuaState {
  /// Tracker statuses: 0 = new, 1 = learning, 2 = memorized.
  static const int statusNew = 0;
  static const int statusLearning = 1;
  static const int statusMemorized = 2;

  static const _boxName = 'hifz_duas';
  Box? _box;
  final bool _inMemory;
  final _mem = <String, dynamic>{};

  DuaState() : _inMemory = false;

  /// Test constructor: no Hive, in-memory values only.
  DuaState.test() : _inMemory = true;

  Future<void> init() async {
    if (_inMemory) return;
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  T _get<T>(String key, T fallback) {
    if (_inMemory) return _mem[key] as T? ?? fallback;
    return _box!.get(key, defaultValue: fallback) as T;
  }

  Future<void> _put(String key, dynamic v) async {
    if (_inMemory) {
      _mem[key] = v;
      return;
    }
    await _box!.put(key, v);
  }

  int get xp => _get('xp', 0);
  int get stars => _get('stars', 0);
  int get streakDays => _get('streakDays', 0);
  int get bestEasy => _get('bestEasy', 0);
  int get bestHard => _get('bestHard', 0);
  List<String> get learnedDuas =>
      _get('learnedDuas', <String>[]);
  String get lang => _get('lang', 'en');
  bool get narration => _get('narration', true);

  Future<void> addXp(int amount) => _put('xp', xp + amount);
  Future<void> addStars(int amount) => _put('stars', stars + amount);
  Future<void> setBest(bool hard, int newStars) async {
    final key = hard ? 'bestHard' : 'bestEasy';
    final cur = _get(key, 0);
    if (newStars > cur) await _put(key, newStars);
  }

  Future<void> markLearned(String duaId) async {
    final list = learnedDuas;
    if (!list.contains(duaId)) {
      list.add(duaId);
      await _put('learnedDuas', list);
    }
    await markMemorized(duaId);
  }

  /// Tracker: itemId -> status, stored as a JSON string (Hive maps
  /// do not round-trip typed keys reliably).
  Map<String, int> get itemStatus {
    final raw = _get('itemStatusJson', '');
    if (raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  /// Effective status: legacy learnedDuas entries count as memorized,
  /// so users who memorized duas before the tracker keep their progress.
  int statusOf(String id) {
    if (learnedDuas.contains(id)) return statusMemorized;
    return itemStatus[id] ?? statusNew;
  }

  Future<void> markLearning(String id) async {
    if (statusOf(id) != statusMemorized) {
      final m = itemStatus;
      m[id] = statusLearning;
      await _put('itemStatusJson', jsonEncode(m));
    }
  }

  Future<void> markMemorized(String id) async {
    final m = itemStatus;
    m[id] = statusMemorized;
    await _put('itemStatusJson', jsonEncode(m));
  }

  Future<void> unmarkMemorized(String id) async {
    final m = itemStatus;
    m[id] = statusLearning;
    await _put('itemStatusJson', jsonEncode(m));
    final list = learnedDuas;
    if (list.remove(id)) await _put('learnedDuas', list);
  }

  int memorizedCount(List<String> ids) =>
      ids.where((id) => statusOf(id) == statusMemorized).length;

  int learningCount(List<String> ids) =>
      ids.where((id) => statusOf(id) == statusLearning).length;

  Future<void> touchDay() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final last = _get('lastDay', '');
    if (last == today) return;
    final yest = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);
    final streak = (last == yest) ? streakDays + 1 : 1;
    await _put('lastDay', today);
    await _put('streakDays', streak);
  }

  Future<void> setLang(String v) => _put('lang', v);
  Future<void> setNarration(bool v) => _put('narration', v);

  Future<void> reset() async {
    await _put('xp', 0);
    await _put('stars', 0);
    await _put('streakDays', 0);
    await _put('bestEasy', 0);
    await _put('bestHard', 0);
    await _put('learnedDuas', <String>[]);
    await _put('itemStatusJson', '');
  }
}
