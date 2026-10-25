import 'package:flutter/material.dart';

import '../engine/dua_state.dart';
import '../engine/learn_content.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';

/// Hifz Tracker: overall progress + per-category progress + per-item
/// status list. Status comes from DuaState: new (grey) / learning
/// (orange) / memorized (green star). Marking happens in the learning
/// screens (gold button); this screen is the report.
class TrackerScreen extends StatelessWidget {
  final DuaState state;
  final AppContent content;
  final KidsLang lang;
  const TrackerScreen(
      {super.key,
      required this.state,
      required this.content,
      this.lang = KidsLang.en});

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(lang);
    final duaIds = content.duas.map((d) => d.id).toList();
    final hadithIds = content.hadiths.map((h) => h.id).toList();
    final surahIds = content.surahs.map((x) => x.id).toList();
    final allIds = [...duaIds, ...hadithIds, ...surahIds];
    final memorized = state.memorizedCount(allIds);
    final total = allIds.length;
    final pct = total == 0 ? 0.0 : memorized / total;

    return Scaffold(
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
                      child: BubbleText(s.get('tracker').toUpperCase(),
                          fontSize: 30, textAlign: TextAlign.left),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Overall progress card.
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5)),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              s.get('overallProgress'),
                              style: const TextStyle(
                                  color: HifzColors.ink,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$memorized / $total',
                              style: const TextStyle(
                                  color: HifzColors.tealDark,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 16,
                                backgroundColor: HifzColors.tealPale,
                                valueColor: const AlwaysStoppedAnimation(
                                    HifzColors.goldDark),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _miniStat(
                                    Icons.star, '${state.stars}', s.get('stars')),
                                const SizedBox(width: 20),
                                _miniStat(Icons.flash_on, '${state.xp}',
                                    s.get('xpLabel')),
                                const SizedBox(width: 20),
                                _miniStat(Icons.local_fire_department,
                                    '${state.streakDays}', s.get('streak')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _categorySection(
                          context, s, s.get('learnDuas'), duaIds,
                          (d) => content.duas
                              .firstWhere((x) => x.id == d)
                              .titleFor(lang.code)),
                      _categorySection(
                          context, s, s.get('hadith'), hadithIds,
                          (id) => content.hadiths
                              .firstWhere((x) => x.id == id)
                              .topicFor(lang.code)),
                      _categorySection(
                          context, s, s.get('surahs'), surahIds,
                          (id) => content.surahs
                              .firstWhere((x) => x.id == id)
                              .nameFor(lang.code)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: HifzColors.goldDark, size: 22),
        Text(value,
            style: const TextStyle(
                color: HifzColors.ink, fontWeight: FontWeight.w900)),
        Text(label,
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _categorySection(BuildContext context, KidsStrings s, String title,
      List<String> ids, String Function(String) labelFor) {
    final memorized = state.memorizedCount(ids);
    final learning = state.learningCount(ids);
    final total = ids.length;
    final pct = total == 0 ? 0.0 : memorized / total;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: ExpansionTile(
        iconColor: Colors.white,
        collapsedIconColor: Colors.white70,
        title: Row(
          children: [
            Expanded(
              child: Text(
                '$title ($memorized/$total)',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '${s.get('learning')}: $learning',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation(HifzColors.gold),
            ),
          ),
        ),
        children: [
          for (final id in ids)
            ListTile(
              dense: true,
              title: Text(
                labelFor(id),
                style: const TextStyle(color: Colors.white),
              ),
              trailing: _statusIcon(state.statusOf(id)),
            ),
        ],
      ),
    );
  }

  Widget _statusIcon(int status) {
    switch (status) {
      case DuaState.statusMemorized:
        return const Icon(Icons.star, color: HifzColors.gold);
      case DuaState.statusLearning:
        return const Icon(Icons.timelapse, color: Colors.orange);
      default:
        return const Icon(Icons.circle_outlined, color: Colors.white54);
    }
  }
}
