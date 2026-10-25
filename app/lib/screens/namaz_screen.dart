import 'package:flutter/material.dart';

import '../engine/learn_content.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';

/// Namaz guide — Wudu (10 steps) and Salah (17 steps), step by step.
/// A learning guide, not tracker content: no memorized marking here.
class NamazScreen extends StatelessWidget {
  final List<NamazStep> wudu;
  final List<NamazStep> salah;
  final KidsLang lang;
  const NamazScreen(
      {super.key,
      required this.wudu,
      required this.salah,
      this.lang = KidsLang.en});

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(lang);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                        child: BubbleText(s.get('namaz').toUpperCase(),
                            fontSize: 32, textAlign: TextAlign.left),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        Color(0xFFFFD76A),
                        HifzColors.goldDark
                      ]),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: HifzColors.ink,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 15),
                    tabs: [
                      Tab(text: s.get('wuduSteps')),
                      Tab(text: s.get('salahSteps')),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _stepList(wudu),
                      _stepList(salah),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepList(List<NamazStep> steps) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: steps.length,
      itemBuilder: (_, i) {
        final step = steps[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4)),
            ],
          ),
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.titleFor(lang.code),
                      style: const TextStyle(
                          color: HifzColors.ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w900),
                    ),
                    if (step.arabic.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          step.arabic,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: HifzColors.goldCalligraphy,
                              fontSize: 21,
                              height: 1.9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    if (step.transliteration.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(step.transliteration,
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                              fontSize: 15)),
                    ],
                    const SizedBox(height: 6),
                    Text(step.meaningFor(lang.code),
                        style: const TextStyle(
                            color: HifzColors.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
