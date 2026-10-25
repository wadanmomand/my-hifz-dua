import 'package:flutter/material.dart';

import '../engine/dua_state.dart';
import '../engine/learn_content.dart';
import '../engine/narration.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';

/// Hadith section — same card pattern as Learn: swipe through short
/// authentic hadith, Arabic display-only, TTS reads the meaning only,
/// gold button marks memorized (+10 XP, +1 star).
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

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(widget.lang);
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
                      child: BubbleText(s.get('hadith').toUpperCase(),
                          fontSize: 32, textAlign: TextAlign.left),
                    ),
                    HifzChip(
                      child: Text('${_index + 1} / ${widget.hadiths.length}'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  onPageChanged: _onPage,
                  itemCount: widget.hadiths.length,
                  itemBuilder: (_, i) => _card(widget.hadiths[i], s),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back_ios_new,
                      onPressed: _index > 0
                          ? () => _page.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut)
                          : null,
                    ),
                    const Spacer(),
                    RoundIconButton(
                      icon: Icons.arrow_forward_ios,
                      onPressed: _index < widget.hadiths.length - 1
                          ? () => _page.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(HadithItem h, KidsStrings s) {
    final memorized =
        widget.state.statusOf(h.id) == DuaState.statusMemorized;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, blurRadius: 14, offset: Offset(0, 8)),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                h.topicFor(widget.lang.code),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF2B7DE9),
                    fontSize: 26,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Directionality(
                textDirection: TextDirection.rtl,
                child: SelectableText(
                  h.arabic,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: HifzColors.goldCalligraphy,
                      fontSize: 30,
                      height: 2.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(h.transliteration,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                      fontSize: 16)),
              const SizedBox(height: 12),
              Text(h.meaningFor(widget.lang.code),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: HifzColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
              const SizedBox(height: 20),
              GoldButton(
                label: memorized
                    ? s.get('learned').toUpperCase()
                    : s.get('markLearned').toUpperCase(),
                onPressed: () => _markMemorized(h),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
