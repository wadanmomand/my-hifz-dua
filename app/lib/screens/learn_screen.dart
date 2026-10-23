import 'package:flutter/material.dart';

import '../engine/dua_models.dart';
import '../engine/dua_state.dart';
import '../engine/narration.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';

/// Learn mode — approved dark-teal 3D design (2026-10-13):
/// golden bubble title, white dua card with golden Arabic calligraphy,
/// teal arrow buttons, golden "I LEARNED THIS" button, Haathi.
/// Logic unchanged: PageView, TTS narrates meanings only (never Arabic).
class LearnScreen extends StatefulWidget {
  final DuaState state;
  final List<DuaItem> duas;
  final KidsLang lang;
  const LearnScreen(
      {super.key, required this.state, required this.duas, this.lang = KidsLang.en});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
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

  String _l(String en, String ur, String ar) => switch (widget.lang) {
        KidsLang.ur => ur.isNotEmpty ? ur : en,
        KidsLang.ar => ar.isNotEmpty ? ar : en,
        _ => en,
      };

  void _onPage(int i) {
    setState(() => _index = i);
    _narration.stop();
  }

  Future<void> _markLearned(DuaItem dua) async {
    final already = widget.state.learnedDuas.contains(dua.id);
    if (!already) {
      await widget.state.markLearned(dua.id);
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
    // TTS speaks the meaning + instruction only — never the Arabic dua.
    final s = KidsStrings(widget.lang);
    _narration.speak(
        '${dua.meaningFor(widget.lang.code)} ${s.get('tapToHearMeaning')}', widget.lang.code);
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back_ios_new,
                      size: 48,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BubbleText(s.get('learnDuas').toUpperCase(),
                          fontSize: 32, textAlign: TextAlign.left),
                    ),
                    HifzChip(
                      child: Text('${_index + 1} / ${widget.duas.length}'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  onPageChanged: _onPage,
                  itemCount: widget.duas.length,
                  itemBuilder: (_, i) => _duaCard(widget.duas[i], s),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
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
                    const Expanded(child: HaathiImage(height: 92)),
                    RoundIconButton(
                      icon: Icons.arrow_forward_ios,
                      onPressed: _index < widget.duas.length - 1
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

  Widget _duaCard(DuaItem dua, KidsStrings s) {
    final learned = widget.state.learnedDuas.contains(dua.id);
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
                _l(dua.titleEn, dua.titleUr, dua.titleAr),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF2B7DE9),
                    fontSize: 26,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              // Arabic dua — display only, never TTS.
              Directionality(
                textDirection: TextDirection.rtl,
                child: SelectableText(
                  dua.arabic,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: HifzColors.goldCalligraphy,
                      fontSize: 32,
                      height: 2.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(dua.transliteration,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                      fontSize: 16)),
              const SizedBox(height: 12),
              Text(dua.meaningFor(widget.lang.code),
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
                    Text(dua.source,
                        style: const TextStyle(
                            color: HifzColors.tealDark,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GoldButton(
                label: learned
                    ? s.get('learned').toUpperCase()
                    : s.get('markLearned').toUpperCase(),
                onPressed: () => _markLearned(dua),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
