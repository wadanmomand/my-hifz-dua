import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_hifz_duas/engine/dua_loader.dart';
import 'package:my_hifz_duas/engine/dua_models.dart';
import 'package:my_hifz_duas/engine/memory_game.dart';
import 'package:my_hifz_duas/l10n/strings.dart';

void main() {
  group('DuaLoader', () {
    test('loads 10 valid duas from bundled JSON', () {
      final raw =
          File('assets/duas/duas.json').readAsStringSync();
      final duas = DuaLoader.loadFromJsonString(raw);
      expect(duas.length, 10);
      expect(duas.first.id, 'bismillah');
      expect(duas.first.source, contains('Quran'));
    });

    test('rejects empty Arabic', () {
      expect(
        () => DuaLoader.validate([
          const DuaItem(
            id: 'x',
            titleEn: 'X',
            titleUr: 'X',
            titleAr: 'X',
            arabic: '',
            transliteration: 'X',
            meaningEn: 'X',
            meaningUr: 'X',
            meaningAr: 'X',
            source: 'Quran',
            category: 'quran',
          ),
        ]),
        throwsStateError,
      );
    });

    test('rejects missing source', () {
      expect(
        () => DuaLoader.validate([
          const DuaItem(
            id: 'x',
            titleEn: 'X',
            titleUr: 'X',
            titleAr: 'X',
            arabic: 'بِسْمِ اللَّهِ',
            transliteration: 'X',
            meaningEn: 'X',
            meaningUr: 'X',
            meaningAr: 'X',
            source: '',
            category: 'quran',
          ),
        ]),
        throwsStateError,
      );
    });

    test('rejects duplicate ids', () {
      const d = DuaItem(
        id: 'dup',
        titleEn: 'X',
        titleUr: 'X',
        titleAr: 'X',
        arabic: 'بِسْمِ اللَّهِ',
        transliteration: 'X',
        meaningEn: 'X',
        meaningUr: 'X',
        meaningAr: 'X',
        source: 'Quran',
        category: 'quran',
      );
      expect(() => DuaLoader.validate([d, d]), throwsStateError);
    });
  });

  group('MemoryGame', () {
    test('builds a deck of 12 cards for 6 pairs', () {
      final duas =
          DuaLoader.loadFromJsonString(
              File('assets/duas/duas.json').readAsStringSync());
      final game = MemoryGame.build(duas, pairs: 6, random: Random(42));
      expect(game.deck.length, 12);
      expect(game.totalPairs, 6);
      // every pairId appears exactly twice, once arabic once meaning
      final ids = <String, List<CardSide>>{};
      for (final c in game.deck) {
        ids.putIfAbsent(c.pairId, () => []).add(c.side);
      }
      expect(ids.length, 6);
      for (final sides in ids.values) {
        expect(sides.toSet(), {CardSide.arabic, CardSide.meaning});
      }
    });

    test('match keeps both cards up and counts a match', () {
      final duas =
          DuaLoader.loadFromJsonString(
              File('assets/duas/duas.json').readAsStringSync());
      final game = MemoryGame.build(duas, pairs: 6, random: Random(1));
      // find the two cards of the same pair
      final i = game.deck.indexWhere((c) => true);
      final pairId = game.deck[i].pairId;
      final j = game.deck.indexWhere(
          (c) => c.pairId == pairId && game.deck.indexOf(c) != i);
      expect(game.flip(i), FlipResult.firstFlip);
      expect(game.flip(j), FlipResult.match);
      expect(game.matches, 1);
      expect(game.deck[i].faceUp, isTrue);
      expect(game.deck[j].faceUp, isTrue);
    });

    test('mismatch flips cards back down via hideMismatch', () {
      final duas =
          DuaLoader.loadFromJsonString(
              File('assets/duas/duas.json').readAsStringSync());
      final game = MemoryGame.build(duas, pairs: 6, random: Random(2));
      final i = game.deck.indexWhere((c) => true);
      final pairId = game.deck[i].pairId;
      final j = game.deck.indexWhere((c) => c.pairId != pairId);
      expect(game.flip(i), FlipResult.firstFlip);
      expect(game.flip(j), FlipResult.mismatch);
      expect(game.matches, 0);
      expect(game.moves, 1);
      game.hideMismatch();
      expect(game.deck[i].faceUp, isFalse);
      expect(game.deck[j].faceUp, isFalse);
    });

    test('flipping the same card twice is ignored', () {
      final duas =
          DuaLoader.loadFromJsonString(
              File('assets/duas/duas.json').readAsStringSync());
      final game = MemoryGame.build(duas, pairs: 6, random: Random(3));
      expect(game.flip(0), FlipResult.firstFlip);
      expect(game.flip(0), FlipResult.ignored);
      expect(game.moves, 0);
    });

    test('game completes when all pairs matched', () {
      final duas =
          DuaLoader.loadFromJsonString(
              File('assets/duas/duas.json').readAsStringSync());
      final game = MemoryGame.build(duas, pairs: 2, random: Random(4));
      final ids = <String, List<int>>{};
      for (var k = 0; k < game.deck.length; k++) {
        ids.putIfAbsent(game.deck[k].pairId, () => []).add(k);
      }
      for (final pair in ids.values) {
        game.flip(pair[0]);
        expect(game.flip(pair[1]), FlipResult.match);
      }
      expect(game.isComplete, isTrue);
    });

    test('stars: fewer moves = more stars', () {
      expect(MemoryGame.starsFor(moves: 6, pairs: 6), 3);
      expect(MemoryGame.starsFor(moves: 10, pairs: 6), 2);
      expect(MemoryGame.starsFor(moves: 30, pairs: 6), 1);
    });
  });

  group('KidsStrings (game 5)', () {
    test('all new keys exist in all three languages', () {
      for (final key in [
        'learnDuas',
        'matchGame',
        'easy',
        'hard',
        'flipCards',
        'moves',
        'pairs',
        'wellDone',
        'duasDone',
      ]) {
        for (final lang in KidsLang.values) {
          final v = KidsStrings.table[key]?[lang];
          expect(v, isNotNull, reason: '$key missing for $lang');
          expect(v!.isNotEmpty, isTrue, reason: '$key empty for $lang');
        }
      }
    });
  });
}
