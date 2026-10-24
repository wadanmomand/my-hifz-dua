import 'package:flutter/material.dart';

import '../engine/dua_models.dart';
import '../engine/dua_state.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';
import 'learn_screen.dart';
import 'match_screen.dart';
import 'parent_dashboard.dart';

/// Home screen — approved dark-teal 3D design (2026-10-13):
/// golden bubble title, Haathi companion, glossy Learn / Match cards,
/// XP chip, parent lock, Easy/Hard toggle. Replaces the Phase-1
/// placeholder (plain AppBar + emoji + flat cards).
class DuaHomeScreen extends StatefulWidget {
  final DuaState state;
  final List<DuaItem> duas;
  final KidsLang lang;
  const DuaHomeScreen(
      {super.key, required this.state, required this.duas, this.lang = KidsLang.en});

  @override
  State<DuaHomeScreen> createState() => _DuaHomeScreenState();
}

class _DuaHomeScreenState extends State<DuaHomeScreen> {
  late KidsLang _lang;
  bool _hard = false;

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
  }

  KidsLang _fromCode(String code) => switch (code) {
        'ur' => KidsLang.ur,
        'ar' => KidsLang.ar,
        _ => KidsLang.en,
      };

  /// Push a screen, then refresh (XP/stars/language may have changed).
  Future<void> _go(Widget page) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => page));
    if (mounted) {
      setState(() => _lang = _fromCode(widget.state.lang));
    }
  }

  Future<void> _onMenuSelected(String value) async {
    switch (value) {
      case 'parents':
        await _go(ParentGateScreen(state: widget.state, lang: _lang));
        break;
      case 'language':
        await _showLanguageDialog();
        break;
      case 'voice':
        await widget.state.setNarration(!widget.state.narration);
        if (mounted) setState(() {});
        break;
      case 'progress':
        await _showProgressDialog();
        break;
    }
  }

  Future<void> _showLanguageDialog() async {
    final picked = await showDialog<KidsLang>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(KidsStrings(_lang).get('language')),
        children: [
          for (final l in KidsLang.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, l),
              child: Row(
                children: [
                  Text(l.label),
                  const Spacer(),
                  if (l == _lang)
                    const Icon(Icons.check, color: HifzColors.tealDark),
                ],
              ),
            ),
        ],
      ),
    );
    if (picked != null && picked != _lang) {
      await widget.state.setLang(picked.code);
      if (mounted) setState(() => _lang = picked);
    }
  }

  Future<void> _showProgressDialog() async {
    final s = KidsStrings(_lang);
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.get('duasDone')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${s.get('stars')}: ${widget.state.stars}'),
            Text('${s.get('xpLabel')}: ${widget.state.xp}'),
            Text('${s.get('streak')}: ${widget.state.streakDays}'),
            Text(
                '${s.get('duasDone')}: ${widget.state.learnedDuas.length} / 10'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = KidsStrings(_lang);
    return Scaffold(
      body: HifzBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row: menu button, XP chip.
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [HifzColors.tealCard, HifzColors.tealDark],
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black38,
                              blurRadius: 8,
                              offset: Offset(0, 4)),
                        ],
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onSelected: _onMenuSelected,
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'parents',
                            child: Row(
                              children: [
                                const Icon(Icons.lock,
                                    color: HifzColors.tealDark),
                                const SizedBox(width: 8),
                                Text(s.get('forParents')),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'language',
                            child: Row(
                              children: [
                                const Icon(Icons.language,
                                    color: HifzColors.tealDark),
                                const SizedBox(width: 8),
                                Text(s.get('language')),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'voice',
                            child: Row(
                              children: [
                                Icon(
                                    widget.state.narration
                                        ? Icons.volume_up
                                        : Icons.volume_off,
                                    color: HifzColors.tealDark),
                                const SizedBox(width: 8),
                                Text(s.get('narration')),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'progress',
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    color: HifzColors.goldDark),
                                const SizedBox(width: 8),
                                Text(s.get('duasDone')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    HifzChip(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              color: HifzColors.goldDark, size: 18),
                          const SizedBox(width: 4),
                          Text(
                              '${widget.state.stars}  ${s.get('xpLabel')} ${widget.state.xp}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const BubbleText('MY HIFZ DUAS', fontSize: 46),
                const SizedBox(height: 24),
                // Learn card — glossy teal.
                GlossyCard(
                  gradient: const [Color(0xFF3ED6C4), HifzColors.tealDark],
                  onTap: () => _go(LearnScreen(
                      state: widget.state, duas: widget.duas, lang: _lang)),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.menu_book_rounded,
                            color: Colors.white, size: 38),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          s.get('learnDuas').toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white70, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Match card — glossy gold.
                GlossyCard(
                  gradient: const [Color(0xFFFFD76A), HifzColors.goldDark],
                  onTap: () => _go(MatchScreen(
                      state: widget.state,
                      duas: widget.duas,
                      hard: _hard,
                      lang: _lang)),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.style_rounded,
                            color: HifzColors.ink, size: 38),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          s.get('matchGame').toUpperCase(),
                          style: const TextStyle(
                              color: HifzColors.ink,
                              fontSize: 24,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.black45, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Easy / Hard toggle.
                Row(
                  children: [
                    Expanded(
                      child: _DifficultyPill(
                        label: s.get('easy').toUpperCase(),
                        selected: !_hard,
                        selectedColor: Colors.green,
                        onTap: () => setState(() => _hard = false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DifficultyPill(
                        label: s.get('hard').toUpperCase(),
                        selected: _hard,
                        selectedColor: Colors.deepOrange,
                        onTap: () => setState(() => _hard = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Center(child: HaathiImage(height: 120)),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '${s.get('duasDone')}: ${widget.state.learnedDuas.length} / 10',
                    style: const TextStyle(
                        color: HifzColors.cream,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyPill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _DifficultyPill(
      {required this.label,
      required this.selected,
      required this.selectedColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: selected
                  ? Colors.white70
                  : Colors.white.withValues(alpha: 0.25),
              width: 1.5),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
