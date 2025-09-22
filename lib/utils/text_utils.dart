import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../models/card_models.dart';
import 'color_utils.dart';
import 'card_utils.dart';

class TextUtils {
  static Widget buildFormattedText(
    FormattedText formattedText, {
    double defaultFontSize = 16,
    Color defaultColor = Colors.black,
    FontWeight defaultFontWeight = FontWeight.normal,
  }) {
    final spans = <InlineSpan>[];
    String text = formattedText.text;
    
    for (int i = 0; i < formattedText.entities.length; i++) {
      final entity = formattedText.entities[i];
      final placeholder = '{}';
      final index = text.indexOf(placeholder);
      
      if (index != -1) {
        // Add text before entity
        if (index > 0) {
          spans.add(TextSpan(
            text: text.substring(0, index),
            style: TextStyle(
              color: defaultColor,
              fontSize: defaultFontSize,
              fontWeight: defaultFontWeight,
            ),
          ));
        }
        
        // Add entity text
        spans.add(TextSpan(
          text: entity.text,
          style: TextStyle(
            color: ColorUtils.fromHex(entity.color) != Colors.transparent
                ? ColorUtils.fromHex(entity.color)
                : defaultColor,
            fontSize: entity.fontSize ?? defaultFontSize,
            fontWeight: _getFontWeight(entity.fontFamily),
            decoration: _getTextDecoration(entity.fontStyle),
          ),
          recognizer: entity.url != null
              ? (TapGestureRecognizer()
                ..onTap = () => CardUtils.handleDeepLink(entity.url!))
              : null,
        ));
        
        // Update text to remaining part
        text = text.substring(index + placeholder.length);
      }
    }
    
    // Add remaining text
    if (text.isNotEmpty) {
      spans.add(TextSpan(
        text: text,
        style: TextStyle(
          color: defaultColor,
          fontSize: defaultFontSize,
          fontWeight: defaultFontWeight,
        ),
      ));
    }
    
    return RichText(
      textAlign: _getTextAlign(formattedText.align),
      text: TextSpan(children: spans),
    );
  }
  
  static Widget buildSimpleText(
    String? text, {
    double fontSize = 16,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.left,
  }) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
  
  static TextAlign _getTextAlign(String align) {
    switch (align.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }
  
  static FontWeight _getFontWeight(String? fontFamily) {
    if (fontFamily == null) return FontWeight.normal;
    
    if (fontFamily.contains('bold')) {
      return FontWeight.bold;
    } else if (fontFamily.contains('semi_bold')) {
      return FontWeight.w600;
    }
    return FontWeight.normal;
  }
  
  static TextDecoration? _getTextDecoration(String? fontStyle) {
    if (fontStyle == null) return null;
    
    switch (fontStyle.toLowerCase()) {
      case 'underline':
        return TextDecoration.underline;
      default:
        return null;
    }
  }
}
