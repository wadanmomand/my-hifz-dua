import 'dart:math';
import 'dua_models.dart';

/// Which side of a memory pair a card shows.
enum CardSide { arabic, meaning }

/// One card in the memory deck. Arabic and meaning cards form pairs
/// sharing the same [pairId] (the dua id).
class MemoryCard {
  final String pairId;
  final CardSide side;
  final String text;
  bool faceUp = false;
  bool matched = false;

  MemoryCard({required this.pairId, required this.side, required this.text});
}

enum FlipResult { firstFlip, match, mismatch, ignored }

/// Pure memory-game logic: deck building, flip/match rules, scoring.
class MemoryGame {
  final List<MemoryCard> deck;
  int moves = 0;
  int matches = 0;
  int _firstFlipped = -1;

  MemoryGame(this.deck);

  factory MemoryGame.build(
    List<DuaItem> duas, {
    int pairs = 6,
    String lang = 'en',
    Random? random,
  }) {
    if (duas.length < pairs) {
      throw ArgumentError('Need at least $pairs duas, have ${duas.length}');
    }
    final rand = random ?? Random();
    final picked = List<DuaItem>.from(duas)..shuffle(rand);
    final chosen = picked.take(pairs);
    final cards = <MemoryCard>[];
    for (final d in chosen) {
      cards.add(MemoryCard(
          pairId: d.id, side: CardSide.arabic, text: d.arabic));
      cards.add(MemoryCard(
          pairId: d.id, side: CardSide.meaning, text: d.meaningFor(lang)));
    }
    cards.shuffle(rand);
    return MemoryGame(cards);
  }

  int get totalPairs => deck.length ~/ 2;
  bool get isComplete => matches == totalPairs;

  FlipResult flip(int index) {
    if (index < 0 || index >= deck.length) return FlipResult.ignored;
    final card = deck[index];
    if (card.faceUp || card.matched) return FlipResult.ignored;

    card.faceUp = true;
    if (_firstFlipped == -1) {
      _firstFlipped = index;
      return FlipResult.firstFlip;
    }
    final first = deck[_firstFlipped];
    _firstFlipped = -1;
    moves++;
    if (first.pairId == card.pairId) {
      first.matched = true;
      card.matched = true;
      matches++;
      return FlipResult.match;
    }
    return FlipResult.mismatch;
  }

  /// Turn mismatched face-up cards back down (UI calls after a delay).
  void hideMismatch() {
    for (final c in deck) {
      if (c.faceUp && !c.matched) c.faceUp = false;
    }
  }

  /// Stars from efficiency: perfect-ish play = 3, sloppy = 1.
  static int starsFor({required int moves, required int pairs}) {
    if (moves <= pairs + 2) return 3;
    if (moves <= pairs * 2) return 2;
    return 1;
  }
}
