import 'package:flutter/material.dart';

class ColorUtils {
  static Color fromHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) {
      return Colors.transparent;
    }
    
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static LinearGradient createGradient(
    List<String> colors,
    double angle,
  ) {
    final gradientColors = colors.map(ColorUtils.fromHex).toList();
    
    // Convert angle to alignment
    final radians = (angle * 3.14159) / 180;
    final alignment = Alignment(
      -1 * (1 - 2 * ((angle % 360) / 360)),
      -1 * (1 - 2 * ((angle % 360) / 360)),
    );
    
    return LinearGradient(
      colors: gradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: List.generate(
        gradientColors.length,
        (index) => index / (gradientColors.length - 1),
      ),
    );
  }
}
