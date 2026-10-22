import 'package:hive_flutter/hive_flutter.dart';

/// On-device persistence: XP, stars, streak, learned duas, match stats.
class DuaState {
  static const _boxName = 'hifz_duas';
  Box? _box;
  final bool _inMemory;
  final _mem = <String, dynamic>{};

  DuaState() : _inMemory = false;

  /// Test constructor: no Hive, in-memory values only.
  DuaState.test() : _inMemory = true;

  Future<void> init() async {
    if (_inMemory) return;
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
  }

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
  }
}
