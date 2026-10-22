import 'package:flutter/material.dart';

import 'ads/ads_service.dart';
import 'engine/dua_loader.dart';
import 'engine/dua_models.dart';
import 'engine/dua_state.dart';
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
  final duas = await DuaLoader.load();
  runApp(MyHifzDuasApp(state: duaState, duas: duas));
}

class MyHifzDuasApp extends StatefulWidget {
  final DuaState state;
  final List<DuaItem> duas;
  const MyHifzDuasApp({super.key, required this.state, required this.duas});

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
      home: DuaHomeScreen(state: widget.state, duas: widget.duas),
    );
  }
}
