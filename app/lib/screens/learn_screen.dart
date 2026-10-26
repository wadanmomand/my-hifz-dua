import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/dua_models.dart';
import '../engine/dua_state.dart';
import '../engine/narration.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';

/// Learn mode built on the APPROVED design image (2026-10-13,
/// screenshot-02, 1008x2128) as a full-bleed background.
/// The baked title + Haathi stay visible; the live white card sits
/// exactly over the baked card (slightly larger, fully opaque) and the
/// live teal arrows sit over the baked arrows. Logic unchanged:
/// PageView, TTS narrates meanings only (never Arabic).
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
    // Viewing a dua starts "learning" it in the Hifz Tracker.
    widget.state.markLearning(widget.duas[i].id);
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

  void _prev() {
    if (_index > 0) {
      _page.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _next() {
    if (_index < widget.duas.length - 1) {
      _page.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(widget.lang);
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    Widget arrow(double x1, double y1, double x2, double y2, IconData icon,
        VoidCallback onTap) {
      return Positioned(
        left: w * x1,
        top: h * y1,
        width: w * (x2 - x1),
        height: h * (y2 - y1),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3FD8C8), Color(0xFF1FA89A)],
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E4A4F),
        body: Stack(
          children: [
            // Approved design image, full-bleed.
            Positioned.fill(
              child: Image.asset(
                'assets/screens/learn_bg.jpg',
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF0E4A4F)),
              ),
            ),
            // Live card over the baked card (true baked card ends ~.71;
            // the old .786 rect left a cream slab over the dark bg).
            Positioned(
              left: w * .055,
              top: h * .185,
              width: w * (.945 - .055),
              height: h * (.715 - .185),
              child: PageView.builder(
                controller: _page,
                onPageChanged: _onPage,
                itemCount: widget.duas.length,
                itemBuilder: (_, i) => _duaCard(widget.duas[i], s),
              ),
            ),
            // Live arrows over the baked arrows (true baked arrows
            // ~.50-.57; the old .582-.678 rect sat below them).
            arrow(.040, .495, .220, .575, Icons.chevron_left, _prev),
            arrow(.775, .495, .960, .575, Icons.chevron_right, _next),
            // Bottom-center: back button + counter (empty teal area).
            Positioned(
              left: w * .28,
              top: h * .82,
              width: w * .44,
              height: h * .08,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back,
                    size: 48,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  HifzChip(
                    child: Text('${_index + 1} / ${widget.duas.length}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _duaCard(DuaItem dua, KidsStrings s) {
    final learned = widget.state.learnedDuas.contains(dua.id);
    return Container(
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
    );
  }
}
