import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CardUtils {
  static Future<void> handleDeepLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
  
  static EdgeInsets getCardPadding(String designType) {
    switch (designType) {
      case 'HC1':
        return const EdgeInsets.all(12.0);
      case 'HC3':
        return const EdgeInsets.all(16.0);
      case 'HC5':
        return EdgeInsets.zero;
      case 'HC6':
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
      case 'HC9':
        return const EdgeInsets.all(8.0);
      default:
        return const EdgeInsets.all(12.0);
    }
  }
  
  static BorderRadius getCardBorderRadius(String designType) {
    switch (designType) {
      case 'HC1':
      case 'HC3':
        return BorderRadius.circular(12.0);
      case 'HC5':
        return BorderRadius.circular(8.0);
      case 'HC6':
        return BorderRadius.circular(8.0);
      case 'HC9':
        return BorderRadius.circular(8.0);
      default:
        return BorderRadius.circular(12.0);
    }
  }
}
