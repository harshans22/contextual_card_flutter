import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../models/card_models.dart';
import 'color_utils.dart';
import 'card_utils.dart';

class TextUtils {
  static Widget buildFormattedText(
    FormattedText? formattedText, {
    String? fallbackText,
    double defaultFontSize = 16,
    Color defaultColor = Colors.black,
    FontWeight defaultFontWeight = FontWeight.normal,
  }) {
    // Handle null or empty formatted text
    if (formattedText == null) {
      return buildSimpleText(
        fallbackText,
        fontSize: defaultFontSize,
        color: defaultColor,
        fontWeight: defaultFontWeight,
      );
    }
    
    // Check if formatted text is meaningful (not just spaces or empty)
    final hasValidText = formattedText.text.trim().isNotEmpty;
    final hasValidEntities = formattedText.entities.isNotEmpty && 
        formattedText.entities.any((entity) => entity.text.trim().isNotEmpty);
    
    // If no valid content, use fallback
    if (!hasValidText && !hasValidEntities) {
      return buildSimpleText(
        fallbackText,
        fontSize: defaultFontSize,
        color: defaultColor,
        fontWeight: defaultFontWeight,
      );
    }
    
    final spans = <InlineSpan>[];
    String text = formattedText.text;
    
    // Handle cases where text is just placeholders or spaces
    if (text.trim().isEmpty || text.trim() == '{}' * formattedText.entities.length) {
      // If text is empty/spaces but entities exist, just render entities
      for (final entity in formattedText.entities) {
        if (entity.text.trim().isNotEmpty) {
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
        }
      }
    } else {
      // Normal processing with placeholders
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
        } else {
          // If no placeholder found, just add the entity text
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
        }
      }
      
      // Add remaining text
      if (text.trim().isNotEmpty) {
        spans.add(TextSpan(
          text: text,
          style: TextStyle(
            color: defaultColor,
            fontSize: defaultFontSize,
            fontWeight: defaultFontWeight,
          ),
        ));
      }
    }
    
    // If no spans were created, use fallback
    if (spans.isEmpty) {
      return buildSimpleText(
        fallbackText,
        fontSize: defaultFontSize,
        color: defaultColor,
        fontWeight: defaultFontWeight,
      );
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
    // Handle null, empty, or whitespace-only text
    if (text == null || text.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    
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
  
  static bool hasValidText(String? text) {
    return text != null && text.trim().isNotEmpty;
  }
  
  static bool hasValidFormattedText(FormattedText? formattedText) {
    if (formattedText == null) return false;
    
    final textIsValid = hasValidText(formattedText.text);
    final hasValidEntities = formattedText.entities.isNotEmpty && 
        formattedText.entities.any((entity) => hasValidText(entity.text));
    
    return textIsValid || hasValidEntities;
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
    
    final family = fontFamily.toLowerCase();
    if (family.contains('bold') && family.contains('semi')) {
      return FontWeight.w600;
    } else if (family.contains('bold')) {
      return FontWeight.bold;
    } else if (family.contains('medium')) {
      return FontWeight.w500;
    }
    return FontWeight.normal;
  }
  
  static TextDecoration? _getTextDecoration(String? fontStyle) {
    if (fontStyle == null) return null;
    
    switch (fontStyle.toLowerCase()) {
      case 'underline':
        return TextDecoration.underline;
      case 'italic':
        return TextDecoration.none; // Flutter handles italic via fontStyle
      default:
        return null;
    }
  }
}
