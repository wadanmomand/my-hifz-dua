import 'package:flutter_test/flutter_test.dart';
import 'package:my_hifz_duas/engine/dua_state.dart';
import 'package:my_hifz_duas/engine/learn_content.dart';
import 'package:my_hifz_duas/main.dart';

/// Smoke test: the app shell builds without crashing.
/// (Does not call main(), so AdMob/Hive are never initialized in tests.)
void main() {
  testWidgets('dua home renders app title', (tester) async {
    final state = DuaState.test();
    await tester.pumpWidget(
        MyHifzDuasApp(state: state, content: const AppContent.test()));
    await tester.pump();
    // Home title is now baked into the approved design image;
    // the live XP tile proves the home rendered.
    expect(find.text('XP 0'), findsOneWidget);
  });
}
