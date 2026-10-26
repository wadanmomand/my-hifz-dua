import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/dua_models.dart';
import '../engine/dua_state.dart';
import '../engine/memory_game.dart';
import '../engine/narration.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';

/// Match mode built on the APPROVED design image (2026-10-13,
/// screenshot-03, 1008x2128) as a full-bleed background.
/// The baked Haathi stays visible; the live header covers the baked
/// header (slightly larger, fully opaque), the live grid sits on an
/// opaque teal backing over the baked cards, and the live banner slot
/// covers the baked banner (teal when idle, green on a match).
/// Logic unchanged: memory pairs, Arabic card ↔ meaning card,
/// stars on finish. Grid is 4 columns in both modes, like the design.
class MatchScreen extends StatefulWidget {
  final DuaState state;
  final List<DuaItem> duas;
  final bool hard;
  final KidsLang lang;
  const MatchScreen(
      {super.key,
      required this.state,
      required this.duas,
      this.hard = false,
      this.lang = KidsLang.en});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late MemoryGame _game;
  final _narration = Narration();
  bool _busy = false;
  bool _done = false;
  bool _showMatched = false;
  int _stars = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _game = MemoryGame.build(widget.duas,
        pairs: widget.hard ? 8 : 6, lang: widget.lang.code);
    _narration.init();
    final s = KidsStrings(widget.lang);
    _narration.speak(s.get('flipCards'), widget.lang.code);
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _narration.stop();
    super.dispose();
  }

  void _tap(int i) {
    if (_busy || _done) return;
    final res = _game.flip(i);
    setState(() {});
    if (res == FlipResult.mismatch) {
      Sfx.error();
      _busy = true;
      Timer(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() {
            _game.hideMismatch();
            _busy = false;
          });
        }
      });
    } else if (res == FlipResult.match) {
      Sfx.success();
      _bannerTimer?.cancel();
      setState(() => _showMatched = true);
      _bannerTimer = Timer(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _showMatched = false);
      });
      if (_game.isComplete) _finish();
    } else if (res == FlipResult.firstFlip) {
      Sfx.pop();
    }
  }

  Future<void> _finish() async {
    _done = true;
    _stars =
        MemoryGame.starsFor(moves: _game.moves, pairs: _game.totalPairs);
    await widget.state.addStars(_stars);
    await widget.state.addXp(_stars * 20);
    await widget.state.setBest(widget.hard, _stars);
    Sfx.fanfare();
    final s = KidsStrings(widget.lang);
    _narration.speak(s.get('wellDone'), widget.lang.code);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(widget.lang);
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E4A4F),
        body: Stack(
          children: [
            // Approved design image, full-bleed.
            Positioned.fill(
              child: Image.asset(
                'assets/screens/match_bg.jpg',
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF0E4A4F)),
              ),
            ),
            // Live header covering the baked header pill.
            Positioned(
              left: w * .025,
              top: h * .015,
              width: w * (.975 - .025),
              height: h * (.155 - .015),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF5ED8C8), Color(0xFF1FA89A)],
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${s.get('matchGame').toUpperCase()} ${widget.hard ? s.get('hard').toUpperCase() : s.get('easy').toUpperCase()}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HifzChip(
                      color: HifzColors.tealPale,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sports_esports,
                              color: HifzColors.tealDark, size: 18),
                          const SizedBox(width: 4),
                          Text('${s.get('moves')} ${_game.moves}'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HifzChip(
                      color: const Color(0xFFDFF5D0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.extension,
                              color: Colors.green, size: 18),
                          const SizedBox(width: 4),
                          Text(
                              '${s.get('pairs')} ${_game.matches}/${_game.totalPairs}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Opaque teal backing over the baked cards.
            Positioned(
              left: w * .040,
              top: h * .148,
              width: w * (.962 - .040),
              height: h * (.758 - .148),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0B4F5E), Color(0xFF1A8A80)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // Live grid (4 columns, like the design) or result card.
            Positioned(
              left: w * .050,
              top: h * .158,
              width: w * (.952 - .050),
              height: h * (.748 - .158),
              child: _done ? _resultCard(s) : _board(),
            ),
            // Back button (empty teal area, bottom-left of Haathi).
            Positioned(
              left: w * .030,
              top: h * .800,
              width: 52,
              height: 52,
              child: RoundIconButton(
                icon: Icons.arrow_back,
                size: 52,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Banner slot covering the baked banner.
            Positioned(
              left: w * .205,
              top: h * .918,
              width: w * (.800 - .205),
              height: h * (.994 - .918),
              child: _showMatched && !_done
                  ? Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFB7E4A0),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.green, size: 20),
                          SizedBox(width: 6),
                          Text('Matched! +10',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF3FD8C8), Color(0xFF1FA89A)],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _board() {
    // Rows of Expanded cards fill the backing exactly on any screen.
    // (The old GridView with childAspectRatio 0.75 left a wide empty
    // teal band below the 3 rows on tall phones.)
    final deck = _game.deck;
    const cols = 4;
    final rowCount = (deck.length / cols).ceil();
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          for (int r = 0; r < rowCount; r++) ...[
            if (r > 0) const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: [
                  for (int c = 0; c < cols; c++) ...[
                    if (c > 0) const SizedBox(width: 12),
                    Expanded(child: _card(deck[r * cols + c], r * cols + c)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card(MemoryCard card, int i) {
    final faceUp = card.faceUp || card.matched;
    return GestureDetector(
      onTap: () => _tap(i),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, anim) {
          final rotate = Tween(begin: 3.14159, end: 0.0).animate(anim);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (_, child) => Transform(
              transform: Matrix4.rotationY(rotate.value),
              alignment: Alignment.center,
              child: child,
            ),
          );
        },
        child: faceUp ? _faceCard(card, i) : _backCard(i),
      ),
    );
  }

  Widget _faceCard(MemoryCard card, int i) {
    final matched = card.matched;
    final isArabic = card.side == CardSide.arabic;
    final gradient = matched
        ? [const Color(0xFF8FE388), const Color(0xFF2E9E4F)]
        : isArabic
            ? [const Color(0xFFFFD76A), HifzColors.goldDark]
            : [const Color(0xFF5ED8C8), HifzColors.tealDark];
    return Container(
      key: ValueKey('face$i'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: matched ? Colors.white : Colors.white24, width: 2),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: isArabic
            ? Directionality(
                textDirection: TextDirection.rtl,
                child: Text(card.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        fontWeight: FontWeight.w700,
                        color: HifzColors.ink)),
              )
            : Text(card.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
      ),
    );
  }

  Widget _backCard(int i) {
    return Container(
      key: ValueKey('back$i'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HifzColors.purple, HifzColors.purpleDark],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: const Center(
        child: Icon(Icons.star, color: HifzColors.gold, size: 36),
      ),
    );
  }

  Widget _resultCard(KidsStrings s) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, blurRadius: 14, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration,
                color: HifzColors.goldDark, size: 64),
            const SizedBox(height: 8),
            Text(s.get('wellDone'),
                style: const TextStyle(
                    color: HifzColors.ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var k = 1; k <= 3; k++)
                  Icon(Icons.star,
                      color: k <= _stars
                          ? HifzColors.gold
                          : Colors.grey[300],
                      size: 40),
              ],
            ),
            const SizedBox(height: 8),
            Text('${s.get('moves')}: ${_game.moves}',
                style: const TextStyle(
                    color: HifzColors.ink, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            GoldButton(
              label: s.get('playAgain').toUpperCase(),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
