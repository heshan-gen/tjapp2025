import 'dart:math';
import 'package:flutter/material.dart';

class ColorService {
  static final ColorService _instance = ColorService._internal();
  factory ColorService() => _instance;
  ColorService._internal();

  // Cache colors for each category to ensure consistency
  final Map<String, Color> _categoryColors = {};
  final List<Color> _usedColors = [];

  // Define the vibrant color palette used across the app
  static const List<Color> _vibrantColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.amber,
    Colors.lightGreen,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
  ];

  /// Get a consistent vibrant color for a category
  /// This ensures the same category always gets the same color across the app
  Color getCategoryColor(final String iconName, {final int? index}) {
    // Return cached color if already assigned
    if (_categoryColors.containsKey(iconName)) {
      return _categoryColors[iconName]!;
    }

    // Filter out recently used colors to avoid repetition
    final List<Color> availableColors = _vibrantColors.where((final color) {
      // Check if this color was used in the last 3 items
      final recentColors = _usedColors.length > 3
          ? _usedColors.sublist(_usedColors.length - 3)
          : _usedColors;
      return !recentColors.contains(color);
    }).toList();

    // If no available colors, use all colors
    final List<Color> colorPool =
        availableColors.isNotEmpty ? availableColors : _vibrantColors;

    // Use the icon name to generate a consistent seed
    final int seed = iconName.hashCode;
    final Random random = Random(seed);

    // Get a random color from the available pool
    final Color selectedColor = colorPool[random.nextInt(colorPool.length)];

    // Cache the color for this category
    _categoryColors[iconName] = selectedColor;

    // Track used colors
    _usedColors.add(selectedColor);

    // Keep only last 5 used colors to avoid memory buildup
    if (_usedColors.length > 5) {
      _usedColors.removeAt(0);
    }

    return selectedColor;
  }

  /// Get all available vibrant colors
  static List<Color> get vibrantColors => _vibrantColors;

  /// Clear the color cache (useful for testing or resetting)
  void clearCache() {
    _categoryColors.clear();
    _usedColors.clear();
  }

  /// Get a random color from the vibrant palette (for one-time use)
  static Color getRandomVibrantColor() {
    final random = Random();
    return _vibrantColors[random.nextInt(_vibrantColors.length)];
  }
}
