import 'package:flutter/material.dart';

import '../engine/dua_state.dart';
import '../engine/learn_content.dart';
import '../engine/narration.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';
import '../widgets/mockup_screen.dart';

/// Hadith section — mockup-faithful (v1.1.0+6, 100%-fidelity rule).
/// Baked: title, Haathi, star field. Live: top chips, cream card content,
/// arrows, gold button. Logic unchanged: swipe through short authentic
/// hadith, Arabic display-only, TTS reads the meaning only, gold button
/// marks memorized (+10 XP, +1 star).
class HadithScreen extends StatefulWidget {
  final DuaState state;
  final List<HadithItem> hadiths;
  final KidsLang lang;
  const HadithScreen(
      {super.key,
      required this.state,
      required this.hadiths,
      this.lang = KidsLang.en});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
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
    widget.state.markLearning(widget.hadiths[i].id);
  }

  Future<void> _markMemorized(HadithItem h) async {
    final already = widget.state.statusOf(h.id) == DuaState.statusMemorized;
    if (!already) {
      await widget.state.markMemorized(h.id);
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
    // TTS speaks the meaning only — never the Arabic hadith.
    _narration.speak(h.meaningFor(widget.lang.code), widget.lang.code);
  }

  void _prev() {
    if (_index > 0) {
      _page.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _next() {
    if (_index < widget.hadiths.length - 1) {
      _page.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(widget.lang);
    final current = widget.hadiths[_index];
    final memorized =
        widget.state.statusOf(current.id) == DuaState.statusMemorized;
    return MockupScaffold(
      bgAsset: 'assets/screens/hadith_bg.jpg',
      builder: (c) => [
        // Top bar: back + live chips over the baked chips.
        c.zone(.054, .056, .166, .112, () => Navigator.pop(context)),
        c.pos(.553, .057, .736, .114,
            mockupLangChip(widget.lang.code.toUpperCase())),
        c.pos(.788, .041, .962, .119, mockupXpChip(widget.state.xp)),
        // Live cream card over the baked card.
        c.pos(
          .085,
          .358,
          .948,
          .772,
          mockupCreamCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
              child: PageView.builder(
                controller: _page,
                onPageChanged: _onPage,
                itemCount: widget.hadiths.length,
                itemBuilder: (_, i) => _cardContent(widget.hadiths[i], s, i),
              ),
            ),
          ),
        ),
        // Live arrows + gold button over the baked ones.
        c.pos(.312, .797, .444, .863,
            mockupGoldArrow(icon: Icons.arrow_back, onPressed: _index > 0 ? _prev : null)),
        c.pos(.556, .797, .688, .863,
            mockupGoldArrow(
                icon: Icons.arrow_forward,
                onPressed:
                    _index < widget.hadiths.length - 1 ? _next : null)),
        c.pos(
          .082,
          .875,
          .945,
          .942,
          mockupGoldButton(
            label: memorized ? s.get('learned') : s.get('markLearned'),
            onPressed: () => _markMemorized(current),
          ),
        ),
      ],
    );
  }

  Widget _cardContent(HadithItem h, KidsStrings s, int i) {
    return SingleChildScrollView(
      child: Column(
        children: [
          mockupGoldPill('${i + 1} of ${widget.hadiths.length}'),
          const SizedBox(height: 12),
          Text(
            h.topicFor(widget.lang.code),
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: HifzColors.tealDark,
                fontSize: 26,
                fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Directionality(
            textDirection: TextDirection.rtl,
            child: SelectableText(
              h.arabic,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: HifzColors.goldCalligraphy,
                  fontSize: 28,
                  height: 2.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Text(h.transliteration,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                  fontSize: 16)),
          const SizedBox(height: 10),
          Text(h.meaningFor(widget.lang.code),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: HifzColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: HifzColors.tealPale,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified,
                    color: HifzColors.tealDark, size: 18),
                const SizedBox(width: 6),
                Text(h.source,
                    style: const TextStyle(
                        color: HifzColors.tealDark,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: mockupSpeakerButton(
              // Speaker reads the meaning only — never the Arabic.
              onPressed: () => _narration.speak(
                  h.meaningFor(widget.lang.code), widget.lang.code),
            ),
          ),
        ],
      ),
    );
  }
}
