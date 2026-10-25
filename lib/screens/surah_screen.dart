import 'package:flutter/material.dart';

import '../engine/dua_state.dart';
import '../engine/learn_content.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';

/// Surah section — last 10 surahs of Juz Amma in Uthmani text.
/// Arabic is display-only (never TTS). Gold button marks memorized.
class SurahScreen extends StatefulWidget {
  final DuaState state;
  final List<SurahItem> surahs;
  final KidsLang lang;
  const SurahScreen(
      {super.key,
      required this.state,
      required this.surahs,
      this.lang = KidsLang.en});

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  final _page = PageController();
  int _index = 0;

  void _onPage(int i) {
    setState(() => _index = i);
    widget.state.markLearning(widget.surahs[i].id);
  }

  Future<void> _markMemorized(SurahItem s) async {
    final already = widget.state.statusOf(s.id) == DuaState.statusMemorized;
    if (!already) {
      await widget.state.markMemorized(s.id);
      await widget.state.addXp(10);
      await widget.state.addStars(1);
      Sfx.star();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(KidsStrings(widget.lang).get('wellDone'))),
        );
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(widget.lang);
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
                      child: BubbleText(s.get('surahs').toUpperCase(),
                          fontSize: 32, textAlign: TextAlign.left),
                    ),
                    HifzChip(
                      child: Text('${_index + 1} / ${widget.surahs.length}'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  onPageChanged: _onPage,
                  itemCount: widget.surahs.length,
                  itemBuilder: (_, i) => _card(widget.surahs[i], s),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back_ios_new,
                      onPressed: _index > 0
                          ? () => _page.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut)
                          : null,
                    ),
                    const Spacer(),
                    RoundIconButton(
                      icon: Icons.arrow_forward_ios,
                      onPressed: _index < widget.surahs.length - 1
                          ? () => _page.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(SurahItem surah, KidsStrings s) {
    final memorized =
        widget.state.statusOf(surah.id) == DuaState.statusMemorized;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, blurRadius: 14, offset: Offset(0, 8)),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                surah.nameFor(widget.lang.code),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF2B7DE9),
                    fontSize: 26,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  surah.arabicName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: HifzColors.goldCalligraphy,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              // Ayahs, numbered, RTL, display-only.
              Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    for (var i = 0; i < surah.ayahs.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                surah.ayahs[i],
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    color: HifzColors.ink,
                                    fontSize: 22,
                                    height: 1.9,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: HifzColors.tealPale,
                              ),
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                    color: HifzColors.tealDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(surah.meaningFor(widget.lang.code),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: HifzColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              GoldButton(
                label: memorized
                    ? s.get('learned').toUpperCase()
                    : s.get('markLearned').toUpperCase(),
                onPressed: () => _markMemorized(surah),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
