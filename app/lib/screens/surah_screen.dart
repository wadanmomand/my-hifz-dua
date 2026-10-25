import 'package:flutter/material.dart';

import '../engine/dua_state.dart';
import '../engine/learn_content.dart';
import '../engine/narration.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';
import '../widgets/mockup_screen.dart';

/// Surah section — mockup-faithful (v1.1.0+6, 100%-fidelity rule).
/// Baked: title, Haathi, star field. Live: top chips, cream card content,
/// arrows, gold button. Logic unchanged: last 10 surahs of Juz Amma in
/// Uthmani text, ayahs numbered RTL display-only. The speaker reads the
/// surah MEANING only — never the Arabic (no TTS recitation of Quran).
/// Gold button marks memorized (+10 XP, +1 star).
class SurahScreen extends StatefulWidget {
  final DuaState state;
  final List<SurahItem> surahs;
  final KidsLang lang;
  const SurahScreen(
      {super.key,
      required this.state,
      required this.surahs,
      this.lang = KidsLang.en});

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  final _page = PageController();
  final _narration = Narration();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _narration.init();
  }

  @override
  void dispose() {
    _narration.stop();
    super.dispose();
  }

  void _onPage(int i) {
    setState(() => _index = i);
    _narration.stop();
    widget.state.markLearning(widget.surahs[i].id);
  }

  Future<void> _markMemorized(SurahItem s) async {
    final already = widget.state.statusOf(s.id) == DuaState.statusMemorized;
    if (!already) {
      await widget.state.markMemorized(s.id);
      await widget.state.addXp(10);
      await widget.state.addStars(1);
      Sfx.star();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(KidsStrings(widget.lang).get('wellDone'))),
        );
        setState(() {});
      }
    }
  }

  void _prev() {
    if (_index > 0) {
      _page.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _next() {
    if (_index < widget.surahs.length - 1) {
      _page.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(widget.lang);
    final current = widget.surahs[_index];
    final memorized =
        widget.state.statusOf(current.id) == DuaState.statusMemorized;
    return MockupScaffold(
      bgAsset: 'assets/screens/surah_bg.jpg',
      builder: (c) => [
        // Top bar: back + live chips over the baked chips.
        c.zone(.066, .044, .201, .104, () => Navigator.pop(context)),
        c.pos(.398, .042, .601, .105,
            mockupLangChip(widget.lang.code.toUpperCase())),
        c.pos(.748, .029, .927, .119, mockupXpChip(widget.state.xp)),
        // Live cream card over the baked card.
        c.pos(
          .073,
          .338,
          .930,
          .763,
          mockupCreamCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
              child: PageView.builder(
                controller: _page,
                onPageChanged: _onPage,
                itemCount: widget.surahs.length,
                itemBuilder: (_, i) => _cardContent(widget.surahs[i], s, i),
              ),
            ),
          ),
        ),
        // Live arrows + gold button over the baked ones.
        c.pos(.369, .791, .478, .858,
            mockupGoldArrow(icon: Icons.arrow_back, onPressed: _index > 0 ? _prev : null)),
        c.pos(.522, .791, .634, .858,
            mockupGoldArrow(
                icon: Icons.arrow_forward,
                onPressed:
                    _index < widget.surahs.length - 1 ? _next : null)),
        c.pos(
          .088,
          .868,
          .914,
          .972,
          mockupGoldButton(
            label: memorized ? s.get('learned') : s.get('markLearned'),
            onPressed: () => _markMemorized(current),
          ),
        ),
      ],
    );
  }

  Widget _cardContent(SurahItem surah, KidsStrings s, int i) {
    return SingleChildScrollView(
      child: Column(
        children: [
          mockupGoldPill(
              'Surah ${surah.number}, ${surah.ayahs.length} Ayahs'),
          const SizedBox(height: 12),
          Text(
            surah.nameFor(widget.lang.code),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: HifzColors.tealDark,
                fontSize: 26,
                fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              surah.arabicName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: HifzColors.goldCalligraphy,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          // Ayahs, numbered, RTL, display-only.
          Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                for (var j = 0; j < surah.ayahs.length; j++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            surah.ayahs[j],
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: HifzColors.ink,
                                fontSize: 22,
                                height: 1.9,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: HifzColors.tealPale,
                          ),
                          child: Text(
                            '${j + 1}',
                            style: const TextStyle(
                                color: HifzColors.tealDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(surah.meaningFor(widget.lang.code),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: HifzColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: mockupSpeakerButton(
              // Speaker reads the meaning only — never the Arabic ayahs.
              onPressed: () => _narration.speak(
                  surah.meaningFor(widget.lang.code), widget.lang.code),
            ),
          ),
        ],
      ),
    );
  }
}
