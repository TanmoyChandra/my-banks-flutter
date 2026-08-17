import 'package:flutter/material.dart';

class ColorOption {
  final String key;
  final String label;
  final Color from;
  final Color via;
  final Color to;
  final Color glow1;
  final Color glow2;

  const ColorOption({
    required this.key,
    required this.label,
    required this.from,
    required this.via,
    required this.to,
    required this.glow1,
    required this.glow2,
  });
}

Color _hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  return Color(int.parse(hex, radix: 16));
}

final List<ColorOption> cardColors = [
  // ── Blues / Navy (Visa-style) ──────────────────────────────
  ColorOption(key: 'navy',     label: 'Navy',     from: _hexToColor('#1a1a2e'), via: _hexToColor('#16213e'), to: _hexToColor('#0f3460'),   glow1: _hexToColor('#4f8ef7'), glow2: _hexToColor('#a78bfa')),
  ColorOption(key: 'ocean',    label: 'Ocean',    from: _hexToColor('#0c1445'), via: _hexToColor('#0a2d6e'), to: _hexToColor('#1565C0'),   glow1: _hexToColor('#42a5f5'), glow2: _hexToColor('#7c83f7')),
  ColorOption(key: 'midnight', label: 'Midnight', from: _hexToColor('#0d1b2a'), via: _hexToColor('#1b263b'), to: _hexToColor('#415a77'),   glow1: _hexToColor('#778da9'), glow2: _hexToColor('#4a6fa5')),

  // ── Oranges / Ambers (Mastercard-style) ───────────────────
  ColorOption(key: 'amber',    label: 'Amber',    from: _hexToColor('#1c0a00'), via: _hexToColor('#6b2400'), to: _hexToColor('#8b3a00'),   glow1: _hexToColor('#ff6b35'), glow2: _hexToColor('#ffd700')),
  ColorOption(key: 'copper',   label: 'Copper',   from: _hexToColor('#2a1000'), via: _hexToColor('#7c3a00'), to: _hexToColor('#b05a00'),   glow1: _hexToColor('#ff8c42'), glow2: _hexToColor('#f5c518')),
  ColorOption(key: 'rust',     label: 'Rust',     from: _hexToColor('#1a0800'), via: _hexToColor('#5c1a00'), to: _hexToColor('#8b2000'),   glow1: _hexToColor('#e55b00'), glow2: _hexToColor('#d4a017')),

  // ── Greens (RuPay-style) ─────────────────────────────────
  ColorOption(key: 'emerald',  label: 'Emerald',  from: _hexToColor('#0a2f1f'), via: _hexToColor('#145a3c'), to: _hexToColor('#1a7a52'),   glow1: _hexToColor('#34d399'), glow2: _hexToColor('#059669')),
  ColorOption(key: 'forest',   label: 'Forest',   from: _hexToColor('#071a11'), via: _hexToColor('#0e3a22'), to: _hexToColor('#166534'),   glow1: _hexToColor('#22c55e'), glow2: _hexToColor('#15803d')),
  ColorOption(key: 'teal',     label: 'Teal',     from: _hexToColor('#042f2e'), via: _hexToColor('#115e59'), to: _hexToColor('#1a7a74'),   glow1: _hexToColor('#2dd4bf'), glow2: _hexToColor('#0d9488')),

  // ── Purples / Violets ─────────────────────────────────────
  ColorOption(key: 'violet',   label: 'Violet',   from: _hexToColor('#1a0533'), via: _hexToColor('#3b0764'), to: _hexToColor('#5b21b6'),   glow1: _hexToColor('#c084fc'), glow2: _hexToColor('#7c3aed')),
  ColorOption(key: 'plum',     label: 'Plum',     from: _hexToColor('#200035'), via: _hexToColor('#4a0070'), to: _hexToColor('#6a0dad'),   glow1: _hexToColor('#e879f9'), glow2: _hexToColor('#a21caf')),

  // ── Reds / Rose ───────────────────────────────────────────
  ColorOption(key: 'crimson',  label: 'Crimson',  from: _hexToColor('#1a0000'), via: _hexToColor('#4c0519'), to: _hexToColor('#7f1d1d'),   glow1: _hexToColor('#f87171'), glow2: _hexToColor('#b91c1c')),
  ColorOption(key: 'magenta',  label: 'Magenta',  from: _hexToColor('#7A003F'), via: _hexToColor('#991165'), to: _hexToColor('#B8228B'),   glow1: _hexToColor('#ff7eb3'), glow2: _hexToColor('#f472b6')),

  // ── Neutral / Dark ───────────────────────────────────────
  ColorOption(key: 'graphite', label: 'Graphite', from: _hexToColor('#111111'), via: _hexToColor('#2a2a2a'), to: _hexToColor('#404040'),   glow1: _hexToColor('#9ca3af'), glow2: _hexToColor('#6b7280')),
];

ColorOption getCardColors(String? colorKey) {
  if (colorKey == null || colorKey.isEmpty) return cardColors.first;
  return cardColors.firstWhere((c) => c.key == colorKey, orElse: () => cardColors.first);
}
