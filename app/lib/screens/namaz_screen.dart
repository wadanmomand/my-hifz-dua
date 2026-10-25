import 'package:flutter/material.dart';

import '../engine/dua_state.dart';
import '../engine/learn_content.dart';
import '../engine/narration.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';
import '../widgets/mockup_screen.dart';

/// Namaz guide — mockup-faithful (v1.1.0+6, 100%-fidelity rule).
/// Baked: title, Haathi, star field. Live: top chips, tabs, cream card
/// with the step list. Logic unchanged: Wudu (10 steps) and Salah
/// (17 steps), step by step. A learning guide, not tracker content:
/// no memorized marking here. Each step has its own speaker button
/// (reads the step meaning only — never Arabic).
class NamazScreen extends StatefulWidget {
  final DuaState state;
  final List<NamazStep> wudu;
  final List<NamazStep> salah;
  final KidsLang lang;
  const NamazScreen(
      {super.key,
      required this.state,
      required this.wudu,
      required this.salah,
      this.lang = KidsLang.en});

  @override
  State<NamazScreen> createState() => _NamazScreenState();
}

class _NamazScreenState extends State<NamazScreen> {
  final _narration = Narration();
  int _tab = 0;

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

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(widget.lang);
    final steps = _tab == 0 ? widget.wudu : widget.salah;
    return MockupScaffold(
      bgAsset: 'assets/screens/namaz_bg.jpg',
      builder: (c) => [
        // Top bar: back + live chips over the baked chips.
        c.zone(.048, .088, .148, .138, () => Navigator.pop(context)),
        c.pos(.421, .088, .577, .138,
            mockupLangChip(widget.lang.code.toUpperCase())),
        c.pos(.812, .072, .964, .166, mockupXpChip(widget.state.xp)),
        // Live tabs over the baked tabs.
        c.pos(.103, .430, .484, .501,
            _tabPill(s.get('wuduSteps'), _tab == 0, () {
          setState(() => _tab = 0);
        })),
        c.pos(.511, .430, .901, .502,
            _tabPill(s.get('salahSteps'), _tab == 1, () {
          setState(() => _tab = 1);
        })),
        // Live cream card over the baked card: steps list.
        c.pos(
          .061,
          .521,
          .938,
          .904,
          mockupCreamCard(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: mockupGoldPill('${steps.length} Steps'),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: steps.length,
                      itemBuilder: (_, i) => _stepRow(steps[i], i),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabPill(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFD76A), HifzColors.goldDark],
                )
              : null,
          color: selected ? null : HifzColors.tealDark,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
              color: selected ? HifzColors.ink : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _stepRow(NamazStep step, int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3FD8C8), Color(0xFF1FA89A)],
              ),
            ),
            child: Text(
              '${i + 1}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.titleFor(widget.lang.code),
                  style: const TextStyle(
                      color: HifzColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                ),
                if (step.arabic.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      step.arabic,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          color: HifzColors.goldCalligraphy,
                          fontSize: 20,
                          height: 1.9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                if (step.transliteration.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(step.transliteration,
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                          fontSize: 15)),
                ],
                const SizedBox(height: 4),
                Text(step.meaningFor(widget.lang.code),
                    style: const TextStyle(
                        color: HifzColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            // Speaker reads the step meaning only — never the Arabic.
            onTap: () => _narration.speak(
                step.meaningFor(widget.lang.code), widget.lang.code),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFD76A), HifzColors.goldDark],
                ),
              ),
              child: const Icon(Icons.volume_up,
                  color: HifzColors.ink, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
