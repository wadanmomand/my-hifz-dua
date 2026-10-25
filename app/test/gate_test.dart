import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_hifz_duas/engine/dua_state.dart';
import 'package:my_hifz_duas/l10n/strings.dart';
import 'package:my_hifz_duas/screens/parent_dashboard.dart';

/// Regression test for the 2026-10-24 parent-gate report
/// (options once showed 1,1,1,1 with the answer missing):
/// every generated question must offer 4 distinct options
/// including the correct answer.
void main() {
  testWidgets('gate always offers the correct answer', (tester) async {
    final state = DuaState.test();
    for (var i = 0; i < 20; i++) {
      await tester.pumpWidget(MaterialApp(
        home: ParentGateScreen(state: state, lang: KidsLang.en),
      ));
      await tester.pump();
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .toList();
      final q = texts.firstWhere((t) => t.contains('= ?'));
      final m = RegExp(r'(\d+) \+ (\d+)').firstMatch(q)!;
      final correct = int.parse(m.group(1)!) + int.parse(m.group(2)!);
      final options =
          texts.where((t) => RegExp(r'^\d+$').hasMatch(t)).toList();
      expect(options.length, 4);
      expect(options.toSet().length, 4);
      expect(options, contains('$correct'));
    }
  });

  testWidgets('gate option labels are wrapped against clipping',
      (tester) async {
    // Regression test for the 2026-10-25 emulator finding: option
    // buttons showed only "1" because a fixed 96px width + fontSize 28
    // clipped the second digit. Every option label must sit inside a
    // scale-down FittedBox so the full number always renders.
    final state = DuaState.test();
    await tester.pumpWidget(MaterialApp(
      home: ParentGateScreen(state: state, lang: KidsLang.en),
    ));
    await tester.pump();
    final fitted = tester.widgetList<FittedBox>(find.byType(FittedBox));
    expect(fitted.length, 4);
    expect(fitted.every((f) => f.fit == BoxFit.scaleDown), isTrue);
  });
}
