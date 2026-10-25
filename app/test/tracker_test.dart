import 'package:flutter_test/flutter_test.dart';
import 'package:my_hifz_duas/engine/dua_state.dart';

/// Hifz Tracker logic: status transitions, legacy learnedDuas
/// compatibility, counts, and reset.
void main() {
  test('fresh state: everything is new', () {
    final state = DuaState.test();
    expect(state.statusOf('bismillah'), DuaState.statusNew);
    expect(state.memorizedCount(['a', 'b']), 0);
    expect(state.learningCount(['a', 'b']), 0);
  });

  test('learning then memorized transitions', () async {
    final state = DuaState.test();
    await state.markLearning('surah-112');
    expect(state.statusOf('surah-112'), DuaState.statusLearning);
    expect(state.learningCount(['surah-112']), 1);
    await state.markMemorized('surah-112');
    expect(state.statusOf('surah-112'), DuaState.statusMemorized);
    expect(state.memorizedCount(['surah-112']), 1);
    expect(state.learningCount(['surah-112']), 0);
    // Marking learning after memorized must not downgrade.
    await state.markLearning('surah-112');
    expect(state.statusOf('surah-112'), DuaState.statusMemorized);
  });

  test('legacy learnedDuas count as memorized', () async {
    final state = DuaState.test();
    await state.markLearned('bismillah');
    expect(state.statusOf('bismillah'), DuaState.statusMemorized);
    expect(state.memorizedCount(['bismillah', 'other']), 1);
  });

  test('unmark returns to learning and clears legacy list', () async {
    final state = DuaState.test();
    await state.markLearned('bismillah');
    await state.unmarkMemorized('bismillah');
    expect(state.statusOf('bismillah'), DuaState.statusLearning);
    expect(state.learnedDuas, isNot(contains('bismillah')));
  });

  test('reset clears tracker and legacy list', () async {
    final state = DuaState.test();
    await state.markLearned('bismillah');
    await state.markMemorized('surah-112');
    await state.reset();
    expect(state.statusOf('bismillah'), DuaState.statusNew);
    expect(state.statusOf('surah-112'), DuaState.statusNew);
    expect(state.learnedDuas, isEmpty);
  });
}
