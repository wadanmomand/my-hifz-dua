import 'package:flutter/material.dart';
import '../engine/dua_models.dart';
import '../engine/dua_state.dart';
import '../engine/narration.dart';
import '../engine/sfx.dart';
import '../l10n/strings.dart';

/// Learn mode: flip through dua cards. Arabic is display-only —
/// TTS narrates instructions/meanings only, never the dua Arabic.
class LearnScreen extends StatefulWidget {
  final DuaState state;
  final List<DuaItem> duas;
  final KidsLang lang;
  const LearnScreen(
      {super.key, required this.state, required this.duas, this.lang = KidsLang.en});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final _page = PageController();
  final _narration = Narration();
  int _index = 0;

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

  String _l(String en, String ur, String ar) => switch (widget.lang) {
        KidsLang.ur => ur.isNotEmpty ? ur : en,
        KidsLang.ar => ar.isNotEmpty ? ar : en,
        _ => en,
      };

  void _onPage(int i) {
    setState(() => _index = i);
    _narration.stop();
  }

  Future<void> _markLearned(DuaItem dua) async {
    final already = widget.state.learnedDuas.contains(dua.id);
    if (!already) {
      await widget.state.markLearned(dua.id);
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
    // TTS speaks the meaning + instruction only — never the Arabic dua.
    final s = KidsStrings(widget.lang);
    _narration.speak(
        '${dua.meaningFor(widget.lang.code)} ${s.get('tapToHearMeaning')}', widget.lang.code);
  }

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(widget.lang);
    return Scaffold(
      appBar: AppBar(title: Text(s.get('learnDuas'))),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _page,
              onPageChanged: _onPage,
              itemCount: widget.duas.length,
              itemBuilder: (_, i) => _duaCard(widget.duas[i], s),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: _index > 0
                      ? () => _page.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut)
                      : null,
                ),
                Text('${_index + 1} / ${widget.duas.length}'),
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: _index < widget.duas.length - 1
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
    );
  }

  Widget _duaCard(DuaItem dua, KidsStrings s) {
    final learned = widget.state.learnedDuas.contains(dua.id);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _l(dua.titleEn, dua.titleUr, dua.titleAr),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              // Arabic dua — display only, never TTS.
              Directionality(
                textDirection: TextDirection.rtl,
                child: SelectableText(
                  dua.arabic,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(height: 2.0),
                ),
              ),
              const SizedBox(height: 12),
              Text(dua.transliteration,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic, color: Colors.grey[700])),
              const SizedBox(height: 12),
              Text(dua.meaningFor(widget.lang.code),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              Chip(label: Text(dua.source)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(learned ? Icons.check : Icons.star),
                label: Text(learned ? s.get('learned') : s.get('markLearned')),
                onPressed: () => _markLearned(dua),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
