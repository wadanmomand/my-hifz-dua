import 'package:flutter/material.dart';

import '../engine/dua_state.dart';
import '../engine/learn_content.dart';
import '../l10n/strings.dart';
import '../widgets/mockup_screen.dart';
import 'hadith_screen.dart';
import 'learn_screen.dart';
import 'namaz_screen.dart';
import 'surah_screen.dart';

/// Library — mockup-faithful (v1.1.0+6, 100%-fidelity rule).
/// The four baked cards (icon + label) stay exactly as approved; invisible
/// tap zones over them do the navigation. Same destinations as before.
/// (Like Round-2 Home, baked labels are English in every language mode.)
class LibraryScreen extends StatelessWidget {
  final DuaState state;
  final AppContent content;
  final KidsLang lang;
  const LibraryScreen(
      {super.key,
      required this.state,
      required this.content,
      this.lang = KidsLang.en});

  @override
  Widget build(BuildContext context) {
    return MockupScaffold(
      bgAsset: 'assets/screens/library_bg.jpg',
      builder: (c) => [
        // Top bar: back + live chips over the baked chips.
        c.zone(.060, .056, .248, .120, () => Navigator.pop(context)),
        c.pos(.366, .054, .639, .121,
            mockupLangChip(lang.code.toUpperCase())),
        c.pos(.744, .038, .946, .129, mockupXpChip(state.xp)),
        // Four baked cards → same destinations as before.
        c.zone(
            .061,
            .378,
            .483,
            .612,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => LearnScreen(
                        state: state, duas: content.duas, lang: lang)))),
        c.zone(
            .527,
            .378,
            .950,
            .612,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => HadithScreen(
                        state: state,
                        hadiths: content.hadiths,
                        lang: lang)))),
        c.zone(
            .061,
            .631,
            .483,
            .881,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SurahScreen(
                        state: state,
                        surahs: content.surahs,
                        lang: lang)))),
        c.zone(
            .527,
            .631,
            .950,
            .881,
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => NamazScreen(
                        state: state,
                        wudu: content.wudu,
                        salah: content.salah,
                        lang: lang)))),
      ],
    );
  }
}
