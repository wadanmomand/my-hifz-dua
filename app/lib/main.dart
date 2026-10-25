import 'package:flutter/material.dart';

import 'ads/ads_service.dart';
import 'engine/dua_state.dart';
import 'engine/learn_content.dart';
import 'l10n/strings.dart';
import 'screens/dua_home.dart';
import 'theme/app_theme.dart';

/// My Hifz Duas entry point — zero backend, on-device everything.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KidsAds.initialize();
  final duaState = DuaState();
  await duaState.init();
  await duaState.touchDay();
  final content = await AppContent.load();
  runApp(MyHifzDuasApp(state: duaState, content: content));
}

class MyHifzDuasApp extends StatefulWidget {
  final DuaState state;
  final AppContent content;
  const MyHifzDuasApp({super.key, required this.state, required this.content});

  @override
  State<MyHifzDuasApp> createState() => _MyHifzDuasAppState();
}

class _MyHifzDuasAppState extends State<MyHifzDuasApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: KidsStrings(KidsLang.en).get('appName'),
      theme: KidsTheme.light,
      debugShowCheckedModeBanner: false,
      home: DuaHomeScreen(
          state: widget.state,
          duas: widget.content.duas,
          content: widget.content),
    );
  }
}
