import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/dua_state.dart';
import '../l10n/strings.dart';

/// Arithmetic gate — kids can't accidentally open parent settings.
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
      appBar: AppBar(title: Text(s.get('forParents'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(s.get('solveToEnter'),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text('$_a + $_b = ?',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _options
                  .map((o) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(96, 64),
                            textStyle: const TextStyle(fontSize: 28)),
                        onPressed: () {
                          if (o == _a + _b) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ParentDashboardScreen(
                                        state: widget.state,
                                        lang: widget.lang)));
                          } else {
                            setState(_newQuestion);
                          }
                        },
                        child: Text('$o'),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Parent dashboard: stats, narration/language, reset.
class ParentDashboardScreen extends StatelessWidget {
  final DuaState state;
  final KidsLang lang;
  const ParentDashboardScreen(
      {super.key, required this.state, this.lang = KidsLang.en});

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(lang);
    return Scaffold(
      appBar: AppBar(title: Text(s.get('parentDashboard'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('${state.stars}', s.get('stars')),
                  _stat('${state.xp}', s.get('xpLabel')),
                  _stat('${state.streakDays}', s.get('streak')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${s.get('duasDone')}: ${state.learnedDuas.length} / 10'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                      value: state.learnedDuas.isEmpty
                          ? 0
                          : state.learnedDuas.length / 10),
                  const SizedBox(height: 12),
                  Text('${s.get('easy')}: ${'⭐' * state.bestEasy}'),
                  Text('${s.get('hard')}: ${'⭐' * state.bestHard}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: Text(s.get('narration')),
              value: state.narration,
              onChanged: (v) => state.setNarration(v),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(s.get('language')),
                  const Spacer(),
                  for (final l in KidsLang.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(l.label),
                        selected: lang == l,
                        onSelected: (_) {
                          state.setLang(l.code);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: Text(s.get('resetProgress'),
                style: const TextStyle(color: Colors.white)),
            onPressed: () async {
              await state.reset();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.get('progressReset'))));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) => Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          Text(label),
        ],
      );
}
