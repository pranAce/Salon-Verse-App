import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SVTierLevel {
  glow,
  luxe,
  icon;

  static SVTierLevel fromString(String? val) {
    final lower = (val ?? '').toLowerCase().trim();
    if (lower.contains('icon')) return SVTierLevel.icon;
    if (lower.contains('luxe')) return SVTierLevel.luxe;
    return SVTierLevel.glow;
  }
}

class SVTierEmblem extends StatelessWidget {
  final String tierKey;
  final double size;
  final bool showLabel;
  final bool isGlowEnabled;

  const SVTierEmblem({
    super.key,
    required this.tierKey,
    this.size = 48.0,
    this.showLabel = false,
    this.isGlowEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final level = SVTierLevel.fromString(tierKey);

    final List<Color> gradientColors;
    final Color accentColor;
    final IconData emblemIcon;
    final String label;

    switch (level) {
      case SVTierLevel.glow:
        gradientColors = const [
          Color(0xFFFB7185),
          Color(0xFFE11D48),
          Color(0xFF9F1239),
        ];
        accentColor = const Color(0xFFE11D48);
        emblemIcon = Icons.workspace_premium_rounded;
        label = 'GLOW';
        break;
      case SVTierLevel.luxe:
        gradientColors = const [
          Color(0xFFA78BFA),
          Color(0xFF8B5CF6),
          Color(0xFF6D28D9),
        ];
        accentColor = const Color(0xFF8B5CF6);
        emblemIcon = Icons.diamond_rounded;
        label = 'LUXE';
        break;
      case SVTierLevel.icon:
        gradientColors = const [
          Color(0xFFFDE68A),
          Color(0xFFF59E0B),
          Color(0xFFD97706),
        ];
        accentColor = const Color(0xFFF59E0B);
        emblemIcon = Icons.military_tech_rounded;
        label = 'ICON';
        break;
    }

    final emblemWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withAlpha(180),
          width: size >= 48 ? 2.0 : 1.2,
        ),
        boxShadow: isGlowEnabled
            ? [
                BoxShadow(
                  color: accentColor.withAlpha(isDark ? 90 : 60),
                  blurRadius: size * 0.35,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(emblemIcon, size: size * 0.52, color: Colors.white),
      ),
    );

    if (!showLabel) {
      return emblemWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        emblemWidget,
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
          decoration: BoxDecoration(
            color: accentColor.withAlpha(25),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: accentColor.withAlpha(60), width: 1),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: accentColor,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}
