import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Glossy 3D golden button — brand rule: never flat, never emoji.
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const GoldButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = enabled ? 1.0 : 0.45;
    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.55),
                KidsTheme.gold,
                KidsTheme.goldDark,
              ],
              stops: const [0.0, 0.25, 1.0],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF8A5A00), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                offset: Offset(0, 4),
                blurRadius: 6,
              ),
              BoxShadow(
                color: Color(0x88FFFFFF),
                offset: Offset(0, 2),
                blurRadius: 2,
                spreadRadius: -1,
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5A3B00),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glossy 3D teal button (secondary actions).
class TealButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  const TealButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.4),
              KidsTheme.teal,
              KidsTheme.tealDark,
            ],
            stops: const [0.0, 0.25, 1.0],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF0E5A50), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              offset: Offset(0, 3),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glossy 3D purple button — used for the Quiz mode CTA.
class PurpleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const PurpleButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.55),
              KidsTheme.purple,
              KidsTheme.purpleDark,
            ],
            stops: const [0.0, 0.25, 1.0],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF4A2E8A), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              offset: Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
