import 'package:flutter/material.dart';

import 'hifz_3d.dart';

/// Mockup-faithful screens (v1.1.0+6, 100%-fidelity rule, user-locked
/// 2026-10-26).
///
/// Same pattern as Round-2 Home: the approved mockup JPG is the full-bleed
/// background (BoxFit.fill, so fractional coords map 1:1 to the screen).
/// Static chrome (title, Haathi, star field, card art) stays baked —
/// literally the approved pixels. Only live/dynamic values sit on top,
/// as opaque widgets slightly larger than the baked element they cover,
/// so no baked sample value (e.g. "XP 120", "12 of 60") ever shows through.
class MockupCtx {
  final double w, h;
  const MockupCtx(this.w, this.h);

  /// Invisible tap zone over a baked element.
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

  /// Fractional positioned widget.
  Widget pos(double x1, double y1, double x2, double y2, Widget child) {
    return Positioned(
      left: w * x1,
      top: h * y1,
      width: w * (x2 - x1),
      height: h * (y2 - y1),
      child: child,
    );
  }
}

class MockupScaffold extends StatelessWidget {
  final String bgAsset;
  final List<Widget> Function(MockupCtx ctx) builder;
  const MockupScaffold(
      {super.key, required this.bgAsset, required this.builder});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0E4A4F),
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            bgAsset,
            fit: BoxFit.fill,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF0E4A4F)),
          ),
        ),
        ...builder(MockupCtx(size.width, size.height)),
      ]),
    );
  }
}

/// Live top-bar language chip covering the baked chip (display-only;
/// language switching stays on Home, as before).
Widget mockupLangChip(String code) {
  return Container(
    decoration: BoxDecoration(
      color: HifzColors.tealDark,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white70, width: 1.5),
    ),
    alignment: Alignment.center,
    child: Text(
      code,
      style: const TextStyle(
          color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
    ),
  );
}

/// Live top-bar XP chip covering the baked "XP 120" badge (display-only).
Widget mockupXpChip(int xp) {
  return Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFD76A), HifzColors.goldDark],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
      ],
    ),
    alignment: Alignment.center,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: HifzColors.tealDark, size: 20),
        const SizedBox(width: 4),
        Text(
          '$xp',
          style: const TextStyle(
              color: HifzColors.tealDark,
              fontSize: 16,
              fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
}

/// Cream card matching the mockup cards (sampled from the approved art).
Widget mockupCreamCard({required Widget child}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF9E9D0),
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(color: Colors.black38, blurRadius: 14, offset: Offset(0, 8)),
      ],
    ),
    child: child,
  );
}

/// Gold pill label (e.g. "1 of 20", "Surah 112, 4 Ayahs").
Widget mockupGoldPill(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFD76A), HifzColors.goldDark],
      ),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: const TextStyle(
          color: HifzColors.ink, fontSize: 15, fontWeight: FontWeight.w900),
    ),
  );
}

/// Gold pill button with a star, as in the mockups.
Widget mockupGoldButton(
    {required String label, required VoidCallback onPressed}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD76A), HifzColors.goldDark],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: HifzColors.ink, size: 24),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                  color: HifzColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Gold round arrow button; dimmed when [onPressed] is null.
/// Always a true circle: centered square inside its rect.
Widget mockupGoldArrow(
    {required IconData icon, required VoidCallback? onPressed}) {
  return LayoutBuilder(builder: (_, constraints) {
    final side = constraints.maxWidth < constraints.maxHeight
        ? constraints.maxWidth
        : constraints.maxHeight;
    return Center(
      child: Opacity(
        opacity: onPressed == null ? 0.4 : 1.0,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFD76A), HifzColors.goldDark],
              ),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: HifzColors.ink, size: 26),
          ),
        ),
      ),
    );
  });
}

/// Small gold speaker button. Always speaks MEANINGS only, never Arabic.
Widget mockupSpeakerButton({required VoidCallback onPressed}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD76A), HifzColors.goldDark],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: const Icon(Icons.volume_up, color: HifzColors.ink, size: 26),
    ),
  );
}
