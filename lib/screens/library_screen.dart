import 'package:flutter/material.dart';

import '../engine/dua_state.dart';
import '../engine/learn_content.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';
import 'hadith_screen.dart';
import 'learn_screen.dart';
import 'namaz_screen.dart';
import 'surah_screen.dart';

/// Library: the four learning sections (Duas, Hadith, Surahs, Namaz).
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
    final s = KidsStrings(lang);
    final sections = [
      _Section(
        title: s.get('learnDuas'),
        count: '${content.duas.length}',
        icon: Icons.menu_book_rounded,
        gradient: const [Color(0xFF3ED6C4), HifzColors.tealDark],
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => LearnScreen(
                    state: state, duas: content.duas, lang: lang))),
      ),
      _Section(
        title: s.get('hadith'),
        count: '${content.hadiths.length}',
        icon: Icons.format_quote_rounded,
        gradient: const [Color(0xFFB388EB), HifzColors.purpleDark],
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => HadithScreen(
                    state: state, hadiths: content.hadiths, lang: lang))),
      ),
      _Section(
        title: s.get('surahs'),
        count: '${content.surahs.length}',
        icon: Icons.book_rounded,
        gradient: const [Color(0xFFFFD76A), HifzColors.goldDark],
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => SurahScreen(
                    state: state, surahs: content.surahs, lang: lang))),
      ),
      _Section(
        title: s.get('namaz'),
        count: '${content.wudu.length + content.salah.length}',
        icon: Icons.mosque_rounded,
        gradient: const [Color(0xFF7ED957), Color(0xFF2E9E4F)],
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => NamazScreen(
                    wudu: content.wudu, salah: content.salah, lang: lang))),
      ),
    ];

    return Scaffold(
      body: HifzBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back_ios_new,
                      size: 48,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BubbleText(s.get('library').toUpperCase(),
                          fontSize: 30, textAlign: TextAlign.left),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: sections.length,
                  itemBuilder: (_, i) {
                    final sec = sections[i];
                    return GlossyCard(
                      gradient: sec.gradient,
                      onTap: sec.onTap,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(sec.icon, color: Colors.white, size: 52),
                          const SizedBox(height: 12),
                          Text(
                            sec.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sec.count,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section {
  final String title;
  final String count;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _Section(
      {required this.title,
      required this.count,
      required this.icon,
      required this.gradient,
      required this.onTap});
}
