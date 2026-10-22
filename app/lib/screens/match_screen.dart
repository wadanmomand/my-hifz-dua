import 'dart:async';
import 'package:flutter/material.dart';
import '../engine/dua_models.dart';
import '../engine/dua_state.dart';
import '../engine/memory_game.dart';
import '../engine/narration.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';

/// Match mode: memory pairs — Arabic card ↔ meaning card.
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
  int _stars = 0;

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
      appBar: AppBar(
        title: Text('${s.get('matchGame')} — ${widget.hard ? s.get('hard') : s.get('easy')}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('${s.get('moves')}: ${_game.moves}  •  ${_game.matches}/${_game.totalPairs} ${s.get('pairs')}'),
          ),
        ],
      ),
      body: _done ? _resultCard(s) : _board(cols),
    );
  }

  Widget _board(int cols) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
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
    return Container(
      key: ValueKey('face$i'),
      decoration: BoxDecoration(
        color: matched
            ? Colors.green[100]
            : (isArabic ? Colors.amber[100] : Colors.teal[100]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: matched ? Colors.green : Colors.grey[300]!, width: 2),
      ),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: isArabic
            ? Directionality(
                textDirection: TextDirection.rtl,
                child: Text(card.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15, height: 1.8, fontWeight: FontWeight.w600)),
              )
            : Text(card.text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Widget _backCard(int i) {
    return Container(
      key: ValueKey('back$i'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Text('⭐', style: TextStyle(fontSize: 36)),
      ),
    );
  }

  Widget _resultCard(KidsStrings s) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              Text(s.get('wellDone'),
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text('⭐' * _stars,
                  style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text('${s.get('moves')}: ${_game.moves}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(s.get('playAgain')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
