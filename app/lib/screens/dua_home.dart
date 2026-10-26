import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/dua_models.dart';
import '../engine/dua_state.dart';
import '../engine/learn_content.dart';
import '../l10n/strings.dart';
import '../widgets/hifz_3d.dart';
import 'learn_screen.dart';
import 'library_screen.dart';
import 'match_screen.dart';
import 'parent_dashboard.dart';
import 'tracker_screen.dart';

/// Home screen built on the APPROVED design image (2026-10-13,
/// screenshot-01, 1008x2128) as a full-bleed background.
/// The baked art (title, Haathi, Learn/Match cards) is the screen itself;
/// live widgets cover only the dynamic parts (XP badge, Easy/Hard pills)
/// and invisible tap zones make the baked chips/cards interactive.
/// All rects are fractions of the design image, measured by visual
/// grounding on 2026-10-24; covers are slightly larger than the baked
/// elements so no baked text or glow peeks out.
class DuaHomeScreen extends StatefulWidget {
  final DuaState state;
  final List<DuaItem> duas;
  final AppContent content;
  final KidsLang lang;
  const DuaHomeScreen(
      {super.key,
      required this.state,
      required this.duas,
      required this.content,
      this.lang = KidsLang.en});

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
      case 'tracker':
        await _go(TrackerScreen(
            state: widget.state, content: widget.content, lang: _lang));
        break;
      case 'library':
        await _go(LibraryScreen(
            state: widget.state, content: widget.content, lang: _lang));
        break;
      case 'parents':
        await _go(ParentGateScreen(
            state: widget.state, lang: _lang, content: widget.content));
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
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    /// Invisible tap zone over a baked element (fractions of the design).
    Widget zone(double x1, double y1, double x2, double y2, VoidCallback onTap) {
      return Positioned(
        left: w * x1,
        top: h * y1,
        width: w * (x2 - x1),
        height: h * (y2 - y1),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),
      );
    }

    /// Live pill covering a baked pill (slightly larger, fully opaque).
    Widget pill(double x1, double y1, double x2, double y2, String label,
        bool selected, List<Color> gradient, VoidCallback onTap) {
      return Positioned(
        left: w * x1,
        top: h * y1,
        width: w * (x2 - x1),
        height: h * (y2 - y1),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradient),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: selected ? Colors.white70 : Colors.white24,
                  width: selected ? 2.5 : 1.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 4)),
              ],
            ),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!selected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                Text(
                  label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E4A4F),
        body: Stack(
          children: [
            // Approved design image, full-bleed.
            Positioned.fill(
              child: Image.asset(
                'assets/screens/home_bg.jpg',
                fit: BoxFit.fill,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF0E4A4F)),
              ),
            ),
            // Tap zones over baked elements.
            zone(.039, .038, .319, .106, _showLanguageDialog),
            zone(.862, .028, .967, .120,
                () => _go(ParentGateScreen(
                    state: widget.state,
                    lang: _lang,
                    content: widget.content))),
            zone(.046, .477, .486, .800,
                () => _go(LearnScreen(
                    state: widget.state, duas: widget.duas, lang: _lang))),
            zone(.520, .477, .956, .803,
                () => _go(MatchScreen(
                    state: widget.state,
                    duas: widget.duas,
                    hard: _hard,
                    lang: _lang))),
            // Live XP tile covering the baked badge (top stretched to
            // cover the baked star tip that peeks above the badge).
            Positioned(
              left: w * .570,
              top: h * .010,
              width: w * (.850 - .570),
              height: h * (.178 - .010),
              child: GestureDetector(
                onTap: _showProgressDialog,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFFD76A), HifzColors.goldDark],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star,
                          color: HifzColors.tealDark, size: 22),
                      const SizedBox(width: 4),
                      Text(
                        'XP ${widget.state.xp}',
                        style: const TextStyle(
                            color: HifzColors.tealDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Menu button in the empty sky gap between EN chip and XP tile.
            Positioned(
              left: w * .42,
              top: h * .040,
              width: 52,
              height: 52,
              child: Container(
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
                      value: 'tracker',
                      child: Row(
                        children: [
                          const Icon(Icons.track_changes,
                              color: HifzColors.tealDark),
                          const SizedBox(width: 8),
                          Text(s.get('tracker')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'library',
                      child: Row(
                        children: [
                          const Icon(Icons.library_books,
                              color: HifzColors.tealDark),
                          const SizedBox(width: 8),
                          Text(s.get('library')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'parents',
                      child: Row(
                        children: [
                          const Icon(Icons.lock, color: HifzColors.tealDark),
                          const SizedBox(width: 8),
                          Text(s.get('forParents')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'language',
                      child: Row(
                        children: [
                          const Icon(Icons.language, color: HifzColors.tealDark),
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
                          const Icon(Icons.star, color: HifzColors.goldDark),
                          const SizedBox(width: 8),
                          Text(s.get('duasDone')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Live Easy / Hard pills covering the baked toggles.
            // Both pills are ALWAYS opaque (their gradient): the old
            // translucent unselected pill let the baked label show
            // through next to the live label (double "Hard" text).
            // Selection is shown by the border, not transparency.
            pill(.182, .888, .500, .978, s.get('easy').toUpperCase(), !_hard,
                const [Color(0xFF3FD8C8), Color(0xFF1FA89A)],
                () => setState(() => _hard = false)),
            pill(.510, .888, .812, .978, s.get('hard').toUpperCase(), _hard,
                const [Color(0xFFF5B301), Color(0xFFE8960F)],
                () => setState(() => _hard = true)),
          ],
        ),
      ),
    );
  }
}
