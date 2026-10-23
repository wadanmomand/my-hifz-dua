import 'dart:async';

import 'package:flutter/material.dart';

import '../engine/dua_models.dart';
import '../engine/dua_state.dart';
import '../engine/memory_game.dart';
import '../engine/narration.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';

/// Match mode — approved dark-teal 3D design (2026-10-13):
/// pill header (title + Moves + Pairs), purple glossy star cards,
/// golden Arabic / teal meaning faces, green matched faces,
/// Haathi + "Matched! +10" banner. Logic unchanged: memory pairs,
/// Arabic card ↔ meaning card, stars on finish.
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
    final cols = widget.hard ? 4 : 3;
    return Scaffold(
      body: HifzBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back_ios_new,
                      size: 48,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5ED8C8), HifzColors.tealDark],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3)),
                          ],
                        ),
                        child: Text(
                          '${s.get('matchGame').toUpperCase()} ${widget.hard ? s.get('hard').toUpperCase() : s.get('easy').toUpperCase()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: HifzChip(
                        color: HifzColors.tealPale,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sports_esports,
                                color: HifzColors.tealDark, size: 18),
                            const SizedBox(width: 6),
                            Text('${s.get('moves')} ${_game.moves}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: HifzChip(
                        color: const Color(0xFFDFF5D0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.extension,
                                color: Colors.green, size: 18),
                            const SizedBox(width: 6),
                            Text(
                                '${s.get('pairs')} ${_game.matches}/${_game.totalPairs}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _done ? _resultCard(s) : _board(cols),
              ),
              if (_showMatched && !_done)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
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
              else
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: HaathiImage(height: 84),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _board(int cols) {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: _game.deck.length,
      itemBuilder: (_, i) => _card(_game.deck[i], i),
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
        margin: const EdgeInsets.all(32),
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
