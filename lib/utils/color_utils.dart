import 'dart:math' as math;

import 'package:flutter/material.dart';

class ColorUtils {
  static Color fromHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.transparent;
    var value = hexString.replaceAll('#', '').toLowerCase();
    // Support 6/7 (#RRGGBB) and 8/9 (#AARRGGBB)
    if (value.length == 6) value = 'ff$value';
    return Color(int.parse(value, radix: 16));
  }

  // 0° = left -> right, 90° = top -> bottom (because we rotate the baseline)
  static LinearGradient createGradient(List<String> colors, double angle) {
    final gradientColors = (colors.isEmpty ? ['#000000', '#000000'] : colors)
        .map(fromHex)
        .toList();
    if (gradientColors.length == 1) gradientColors.add(gradientColors.first);

    final radians = (angle % 360) * math.pi / 180.0;

    return LinearGradient(
      colors: gradientColors,
      begin: Alignment.centerLeft, // baseline vector [0°] [web:25][web:34]
      end: Alignment.centerRight, // baseline vector [0°] [web:25][web:34]
      transform: GradientRotation(
        radians,
      ), // apply angle in radians [web:29][web:24]
      stops: List<double>.generate(
        gradientColors.length,
        (i) =>
            gradientColors.length == 1 ? 1.0 : i / (gradientColors.length - 1),
      ),
    );
  }
}
