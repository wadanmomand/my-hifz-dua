import 'package:flutter_test/flutter_test.dart';
import 'package:my_hifz_duas/engine/dua_state.dart';
import 'package:my_hifz_duas/engine/dua_models.dart';
import 'package:my_hifz_duas/main.dart';

/// Smoke test: the app shell builds without crashing.
/// (Does not call main(), so AdMob/Hive are never initialized in tests.)
void main() {
  testWidgets('dua home renders app title', (tester) async {
    final duas = <DuaItem>[];
    final state = DuaState.test();
    await tester.pumpWidget(MyHifzDuasApp(state: state, duas: duas));
    await tester.pump();
    // Title is now the golden 3D bubble text (approved design).
    expect(find.text('MY HIFZ DUAS'), findsWidgets);
  });
}
