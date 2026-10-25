import 'package:flutter/material.dart';

import '../engine/dua_state.dart';
import '../engine/learn_content.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';
import '../widgets/mockup_screen.dart';

/// Hifz Tracker — mockup-faithful summary (v1.1.0+6, 100%-fidelity rule).
/// Baked (approved pixels): title, Haathi, star field, category card art,
/// legend row. Live on top: top chips, overall bar + counts, category
/// counts (pills in the sampled card colors so they blend into the baked
/// cards). Tapping a category card opens its per-item list.
/// Logic unchanged: status from DuaState (new / learning / memorized).
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
    final memDuas = state.memorizedCount(duaIds);
    final memHadith = state.memorizedCount(hadithIds);
    final memSurahs = state.memorizedCount(surahIds);

    void openDetail(String title, List<String> ids,
        String Function(String) labelFor) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => TrackerDetailScreen(
                  state: state,
                  title: title,
                  ids: ids,
                  labelFor: labelFor,
                  lang: lang)));
    }

    final openDuas = () => openDetail(s.get('learnDuas'), duaIds,
        (d) => content.duas.firstWhere((x) => x.id == d).titleFor(lang.code));
    final openHadith = () => openDetail(s.get('hadith'), hadithIds,
        (id) => content.hadiths.firstWhere((x) => x.id == id).topicFor(lang.code));
    final openSurahs = () => openDetail(s.get('surahs'), surahIds,
        (id) => content.surahs.firstWhere((x) => x.id == id).nameFor(lang.code));

    return MockupScaffold(
      bgAsset: 'assets/screens/tracker_bg.jpg',
      builder: (c) => [
        // Top bar: back + live chips over the baked chips.
        c.zone(.028, .028, .142, .062, () => Navigator.pop(context)),
        c.pos(.413, .024, .583, .064,
            mockupLangChip(lang.code.toUpperCase())),
        c.pos(.794, .013, .975, .072, mockupXpChip(state.xp)),
        // Overall progress: live bar + live text over the baked bar/text.
        c.pos(
          .090,
          .458,
          .910,
          .548,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9E9D0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 16,
                    backgroundColor: const Color(0xFFE8DCC0),
                    valueColor:
                        const AlwaysStoppedAnimation(HifzColors.goldDark),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$memorized of $total ${s.get('memorized')}',
                  style: const TextStyle(
                      color: HifzColors.tealDark,
                      fontSize: 17,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
        // Category cards: tap zones + live count pills (sampled colors).
        // (Pills carry the tap too: a plain Container would block the
        // zone beneath it, so each pill is its own GestureDetector.)
        c.zone(.079, .566, .921, .684, openDuas),
        c.pos(
            .320,
            .612,
            .860,
            .682,
            _countPill(
                const Color(0xFF10828C),
                '${duaIds.length} items, $memDuas '
                '${s.get('memorized')}',
                openDuas)),
        c.zone(.079, .701, .921, .819, openHadith),
        c.pos(
            .320,
            .748,
            .860,
            .818,
            _countPill(
                const Color(0xFFF2B63E),
                '${hadithIds.length} items, $memHadith '
                '${s.get('memorized')}',
                openHadith)),
        c.zone(.079, .834, .921, .944, openSurahs),
        c.pos(
            .320,
            .882,
            .860,
            .952,
            _countPill(
                const Color(0xFF469752),
                '${surahIds.length} Surahs, $memSurahs '
                '${s.get('memorized')}',
                openSurahs)),
      ],
    );
  }

  /// Opaque count pill in the baked card's own color, so the live count
  /// replaces the baked sample count with no visible seam.
  Widget _countPill(Color color, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: color,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

/// Per-item list for one tracker category (drill-down from the summary).
class TrackerDetailScreen extends StatelessWidget {
  final DuaState state;
  final String title;
  final List<String> ids;
  final String Function(String) labelFor;
  final KidsLang lang;
  const TrackerDetailScreen(
      {super.key,
      required this.state,
      required this.title,
      required this.ids,
      required this.labelFor,
      this.lang = KidsLang.en});

  @override
  Widget build(BuildContext context) {
    final memorized = state.memorizedCount(ids);
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
                      child: BubbleText(
                          '$title ($memorized/${ids.length})'.toUpperCase(),
                          fontSize: 24,
                          textAlign: TextAlign.left),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: mockupCreamCard(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: ids.length,
                      itemBuilder: (_, i) {
                        final id = ids[i];
                        return ListTile(
                          dense: true,
                          title: Text(
                            labelFor(id),
                            style: const TextStyle(
                                color: HifzColors.ink,
                                fontWeight: FontWeight.w700),
                          ),
                          trailing: _statusIcon(state.statusOf(id)),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusIcon(int status) {
    switch (status) {
      case DuaState.statusMemorized:
        return const Icon(Icons.star, color: HifzColors.goldDark);
      case DuaState.statusLearning:
        return const Icon(Icons.timelapse, color: Colors.orange);
      default:
        return const Icon(Icons.circle_outlined, color: Colors.grey);
    }
  }
}
