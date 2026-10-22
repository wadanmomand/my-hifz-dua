import 'package:flutter/material.dart';
import '../engine/dua_state.dart';
import '../engine/dua_models.dart';
import '../l10n/strings.dart';
import 'learn_screen.dart';
import 'match_screen.dart';
import 'parent_dashboard.dart';

/// Phase 1 home: mode cards + stats. Full game screens land in Phase 2.
class DuaHomeScreen extends StatelessWidget {
  final DuaState state;
  final List<DuaItem> duas;
  final KidsLang lang;
  const DuaHomeScreen(
      {super.key,
      required this.state,
      required this.duas,
      this.lang = KidsLang.en});

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(lang);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('appName')),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            tooltip: s.get('forParents'),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ParentGateScreen(state: state, lang: lang)));
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Chip(
                label: Text(
                    '⭐ ${state.stars}   ${s.get('xpLabel')} ${state.xp}')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('🐘', style: TextStyle(fontSize: 48)),
                    Text(s.get('learnDuas'),
                        style:
                            Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => LearnScreen(
                                      state: state,
                                      duas: duas,
                                      lang: lang)));
                        },
                        child: Text(s.get('learnDuas'))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(s.get('matchGame'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge),
                          const SizedBox(height: 8),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => MatchScreen(
                                            state: state,
                                            duas: duas,
                                            hard: false,
                                            lang: lang)));
                              },
                              child: Text(s.get('easy'))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(s.get('matchGame'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge),
                          const SizedBox(height: 8),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => MatchScreen(
                                            state: state,
                                            duas: duas,
                                            hard: true,
                                            lang: lang)));
                              },
                              child: Text(s.get('hard'))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
                '${state.learnedDuas.length} / ${duas.length} ${s.get('duasDone')}'),
          ],
        ),
      ),
    );
  }
}
