import 'package:flutter/material.dart';

class ColorOption {
  final String key;
  final String label;

  const ColorOption({required this.key, required this.label});

  Color base(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (key) {
      case 'primary': return scheme.primaryContainer;
      case 'secondary': return scheme.secondaryContainer;
      case 'tertiary': return scheme.tertiaryContainer;
      case 'error': return scheme.errorContainer;
      case 'neutral': return scheme.surfaceContainerHighest;
      default: return scheme.primaryContainer;
    }
  }

  Color onBase(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (key) {
      case 'primary': return scheme.onPrimaryContainer;
      case 'secondary': return scheme.onSecondaryContainer;
      case 'tertiary': return scheme.onTertiaryContainer;
      case 'error': return scheme.onErrorContainer;
      case 'neutral': return scheme.onSurface;
      default: return scheme.onPrimaryContainer;
    }
  }
}

final List<ColorOption> cardColors = const [
  ColorOption(key: 'primary', label: 'Primary Theme'),
  ColorOption(key: 'secondary', label: 'Secondary Theme'),
  ColorOption(key: 'tertiary', label: 'Tertiary Theme'),
  ColorOption(key: 'error', label: 'Accent Theme'),
  ColorOption(key: 'neutral', label: 'Neutral Theme'),
];

ColorOption getCardColors(String? colorKey) {
  if (colorKey == null || colorKey.isEmpty) return cardColors.first;
  return cardColors.firstWhere((c) => c.key == colorKey, orElse: () => cardColors.first);
}
