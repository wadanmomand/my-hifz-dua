import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/dua_state.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';

/// Arithmetic gate — kids can't accidentally open parent settings.
/// Styled to the app's dark-teal 3D look (was a plain Scaffold).
class ParentGateScreen extends StatefulWidget {
  final DuaState state;
  final KidsLang lang;
  const ParentGateScreen({super.key, required this.state, this.lang = KidsLang.en});

  @override
  State<ParentGateScreen> createState() => _ParentGateScreenState();
}

class _ParentGateScreenState extends State<ParentGateScreen> {
  late int _a;
  late int _b;
  late List<int> _options;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    final r = Random();
    _a = 4 + r.nextInt(6);
    _b = 3 + r.nextInt(6);
    final correct = _a + _b;
    final set = {correct};
    while (set.length < 4) {
      set.add(correct + r.nextInt(7) - 3);
    }
    _options = set.where((v) => v > 0).toList()..shuffle(r);
    while (_options.length < 4) {
      _options.add(correct + _options.length + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(widget.lang);
    return Scaffold(
      body: HifzBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: RoundIconButton(
                    icon: Icons.arrow_back_ios_new,
                    size: 48,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black38,
                          blurRadius: 14,
                          offset: Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(s.get('solveToEnter'),
                          style: const TextStyle(
                              color: HifzColors.ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Text('$_a + $_b = ?',
                          style: const TextStyle(
                              color: HifzColors.ink,
                              fontSize: 44,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: _options
                            .map((o) => SizedBox(
                                  width: 96,
                                  height: 64,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: HifzColors.gold,
                                        foregroundColor: HifzColors.ink,
                                        textStyle: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18))),
                                    onPressed: () {
                                      if (o == _a + _b) {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    ParentDashboardScreen(
                                                        state: widget.state,
                                                        lang: widget.lang)));
                                      } else {
                                        setState(_newQuestion);
                                      }
                                    },
                                    child: Text('$o'),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const HaathiImage(height: 110),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Parent dashboard — approved clean design (2026-10-13):
/// navy header + shield, stat cards, progress, best stars,
/// voice toggle, language chips, red reset, Haathi.
class ParentDashboardScreen extends StatelessWidget {
  final DuaState state;
  final KidsLang lang;
  const ParentDashboardScreen(
      {super.key, required this.state, this.lang = KidsLang.en});

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(lang);
    return Scaffold(
      backgroundColor: HifzColors.parentBg,
      body: SafeArea(
        child: Column(
          children: [
            // Navy header.
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: const BoxDecoration(
                color: HifzColors.navy,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back_ios_new,
                    size: 44,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.shield,
                      color: Colors.white, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(s.get('parentDashboard').toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _statCard(Icons.star, Colors.amber,
                              s.get('totalStars'), '${state.stars}')),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _statCard(Icons.bolt, Colors.blue,
                              s.get('xpLabel'), '${state.xp}')),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _statCard(Icons.local_fire_department,
                              Colors.deepOrange,
                              s.get('streak'), '${state.streakDays}')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _whiteCard(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(s.get('duasDone').toUpperCase(),
                                  style: const TextStyle(
                                      color: HifzColors.ink,
                                      fontWeight: FontWeight.w900)),
                            ),
                            Text('${state.learnedDuas.length} / 10',
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: state.learnedDuas.isEmpty
                                ? 0
                                : state.learnedDuas.length / 10,
                            minHeight: 10,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation(
                                HifzColors.tealCard),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _bestRow(Icons.star, Colors.amber, s.get('easy'),
                            state.bestEasy),
                        const SizedBox(height: 6),
                        _bestRow(Icons.local_fire_department,
                            Colors.deepOrange, s.get('hard'), state.bestHard),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _whiteCard(
                    Row(
                      children: [
                        Expanded(
                          child: Text(s.get('narration').toUpperCase(),
                              style: const TextStyle(
                                  color: HifzColors.ink,
                                  fontWeight: FontWeight.w900)),
                        ),
                        Switch(
                          value: state.narration,
                          activeThumbColor: HifzColors.tealCard,
                          onChanged: (v) => state.setNarration(v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _whiteCard(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.get('language').toUpperCase(),
                            style: const TextStyle(
                                color: HifzColors.ink,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            for (final l in KidsLang.values)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: ChoiceChip(
                                    label: Text(l.code.toUpperCase()),
                                    selected: lang == l,
                                    selectedColor: const Color(0xFF2B7DE9),
                                    labelStyle: TextStyle(
                                        color: lang == l
                                            ? Colors.white
                                            : HifzColors.ink,
                                        fontWeight: FontWeight.w800),
                                    onSelected: (_) {
                                      state.setLang(l.code);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      icon: const Icon(Icons.delete_forever,
                          color: Colors.white),
                      label: Text(s.get('resetProgress').toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900)),
                      onPressed: () async {
                        await state.reset();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text(s.get('progressReset'))));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: HaathiImage(height: 90),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _whiteCard(Widget child) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: child,
      );

  Widget _statCard(
      IconData icon, Color color, String label, String value) {
    return _whiteCard(
      Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w900)),
          Text(label.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _bestRow(
      IconData icon, Color color, String label, int stars) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(label.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900)),
        const Spacer(),
        Row(
          children: [
            for (var k = 1; k <= 3; k++)
              Icon(Icons.star,
                  color: k <= stars ? Colors.amber : Colors.grey[300],
                  size: 22),
          ],
        ),
        const SizedBox(width: 6),
        Text('$stars ${stars == 1 ? 'star' : 'stars'}',
            style: const TextStyle(
                color: Colors.amber, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
