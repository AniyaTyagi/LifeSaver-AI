import 'package:flutter/material.dart';

class PaletteStyle {
  final Color bg;
  final Color text;
  final Color textSecondary;
  final Color border;
  final Color accent;

  const PaletteStyle({
    required this.bg,
    required this.text,
    required this.textSecondary,
    required this.border,
    required this.accent,
  });
}

// The 5 palette colors used for widgets/cards:
// 1. Primary Navy: #0D1E4C
// 2. Slate Blue: #26415E
// 3. Soft Blue: #83A6CE
// 4. Secondary Pink: #C48CB3
// 5. Light Pink: #E5C9D7

final List<PaletteStyle> paletteStyles = [
  // 1. Indigo/Blue Style (Light Indigo card, dark text)
  const PaletteStyle(
    bg: Color(0xFFEEF2F6),
    text: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    border: Color(0xFFE2E8F0),
    accent: Color(0xFF4F46E5),
  ),
  // 2. Purple Style (Light Purple card, dark text)
  const PaletteStyle(
    bg: Color(0xFFF5F3FF),
    text: Color(0xFF0F172A),
    textSecondary: Color(0xFF6B21A8),
    border: Color(0xFFDDD6FE),
    accent: Color(0xFF7C3AED),
  ),
  // 3. Emerald Style (Light Emerald card, dark text)
  const PaletteStyle(
    bg: Color(0xFFECFDF5),
    text: Color(0xFF0F172A),
    textSecondary: Color(0xFF065F46),
    border: Color(0xFFA7F3D0),
    accent: Color(0xFF059669),
  ),
  // 4. Amber/Orange Style (Light Orange card, dark text)
  const PaletteStyle(
    bg: Color(0xFFFFF7ED),
    text: Color(0xFF0F172A),
    textSecondary: Color(0xFF9A3412),
    border: Color(0xFFFED7AA),
    accent: Color(0xFFEA580C),
  ),
  // 5. Pink Style (Light Pink card, dark text)
  const PaletteStyle(
    bg: Color(0xFFFDF2F8),
    text: Color(0xFF0F172A),
    textSecondary: Color(0xFF9D174D),
    border: Color(0xFFFBCFE8),
    accent: Color(0xFFDB2777),
  ),
];
