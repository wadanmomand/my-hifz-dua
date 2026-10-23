import 'package:flutter/material.dart';

/// Shared 3D design system for My Hifz Duas — dark teal + gold,
/// matching the approved 2026-10-13 design screens. Flutter-drawn
/// (gradients, gloss, star field) so every screen renders its design
/// without baked art, and dynamic content (dua text, card grids)
/// always stays live and localized.

class HifzColors {
  static const Color bgTop = Color(0xFF0E4A4F);
  static const Color bgBottom = Color(0xFF062A2E);
  static const Color tealCard = Color(0xFF2AB8A6);
  static const Color tealDark = Color(0xFF1E8A7D);
  static const Color tealPale = Color(0xFFD8F4EF);
  static const Color gold = Color(0xFFF5B301);
  static const Color goldLight = Color(0xFFFFE08A);
  static const Color goldDark = Color(0xFFD99400);
  static const Color goldCalligraphy = Color(0xFFB8860B);
  static const Color purple = Color(0xFF9B7ED9);
  static const Color purpleDark = Color(0xFF6C4FB0);
  static const Color cream = Color(0xFFFFF8E7);
  static const Color ink = Color(0xFF2D3A4A);
  static const Color navy = Color(0xFF1B2A4A);
  static const Color parentBg = Color(0xFFEEF2F5);
}

/// Dark teal night-sky background with scattered golden stars.
class HifzBackground extends StatelessWidget {
  final Widget child;
  const HifzBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [HifzColors.bgTop, HifzColors.bgBottom],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _StarField()),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarPainter());
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Deterministic pseudo-random stars (fixed seed → stable layout).
    var seed = 1234567;
    int next() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed;
    }

    final paint = Paint()..color = const Color(0xFFFFD76A);
    for (var i = 0; i < 70; i++) {
      final x = (next() % 1000) / 1000 * size.width;
      final y = (next() % 1000) / 1000 * size.height;
      final r = 1.0 + (next() % 3);
      final alpha = 60 + (next() % 140);
      paint.color = Color.fromRGBO(255, 215, 106, alpha / 255);
      canvas.drawCircle(Offset(x, y), r, paint);
      // A few 4-point sparkles.
      if (i % 9 == 0) {
        final s = r + 4;
        final path = Path()
          ..moveTo(x, y - s)
          ..quadraticBezierTo(x, y, x + s, y)
          ..quadraticBezierTo(x, y, x, y + s)
          ..quadraticBezierTo(x, y, x - s, y)
          ..quadraticBezierTo(x, y, x, y - s);
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Chunky golden 3D bubble text: gradient letters, white outline,
/// stacked depth — the app's signature title style.
class BubbleText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign textAlign;

  const BubbleText(this.text,
      {super.key, this.fontSize = 44, this.textAlign = TextAlign.center});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [HifzColors.goldLight, HifzColors.gold, HifzColors.goldDark],
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 1.05,
          shadows: [
            for (final o in [
              const Offset(-2.5, 0),
              const Offset(2.5, 0),
              const Offset(0, -2.5),
              const Offset(0, 2.5),
              const Offset(-2.5, -2.5),
              const Offset(2.5, -2.5),
              const Offset(-2.5, 2.5),
              const Offset(2.5, 2.5),
            ])
              Shadow(offset: o, color: Colors.white, blurRadius: 0),
            for (var i = 1; i <= 8; i++)
              Shadow(
                  offset: Offset(0, 2.5 + i.toDouble()),
                  color: const Color(0xFF8A5A00),
                  blurRadius: 0),
            const Shadow(
                offset: Offset(0, 13), color: Colors.black26, blurRadius: 6),
          ],
        ),
      ),
    );
  }
}

/// Glossy gradient card with a white top highlight — the 3D card look.
class GlossyCard extends StatelessWidget {
  final Widget child;
  final List<Color> gradient;
  final double radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GlossyCard({
    super.key,
    required this.child,
    required this.gradient,
    this.radius = 24,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
              color: Colors.black38, blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Stack(
        children: [
          // Gloss: soft white sheen across the top.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 44,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(radius)),
              ),
            ),
          ),
          child,
        ],
      ),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}

/// Golden pill button with dark 3D text.
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double fontSize;

  const GoldButton(
      {super.key, required this.label, this.onPressed, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: HifzColors.gold,
        foregroundColor: HifzColors.ink,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999)),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      onPressed: onPressed,
      child: Text(label,
          style: TextStyle(
              fontSize: fontSize, fontWeight: FontWeight.w900)),
    );
  }
}

/// Round glossy teal button (arrows, lock, back).
class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  const RoundIconButton(
      {super.key, required this.icon, this.onPressed, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HifzColors.tealCard, HifzColors.tealDark],
        ),
        boxShadow: const [
          BoxShadow(
              color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

/// Small pill chip (XP, language, counters).
class HifzChip extends StatelessWidget {
  final Widget child;
  final Color color;
  final VoidCallback? onTap;

  const HifzChip(
      {super.key, required this.child, this.color = HifzColors.cream, this.onTap});

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
            color: HifzColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 15),
        child: child,
      ),
    );
    if (onTap == null) return chip;
    return GestureDetector(onTap: onTap, child: chip);
  }
}

/// Haathi companion art. Falls back to nothing if the asset is not
/// installed yet, so a missing binary can never crash the app.
class HaathiImage extends StatelessWidget {
  final double height;
  const HaathiImage({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/art/haathi.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}
