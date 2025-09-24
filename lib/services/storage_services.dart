// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _dismissedCardsKey = 'dismissed_cards';
  static const String _remindLaterCardsKey = 'remind_later_cards';
  
  static Future<void> dismissCard(String cardSlug) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedCards = await getDismissedCards();
      if (!dismissedCards.contains(cardSlug)) {
        dismissedCards.add(cardSlug);
        await prefs.setStringList(_dismissedCardsKey, dismissedCards);
      }
      print('Card dismissed: $cardSlug'); // Debug log
    } catch (e) {
      print('Error dismissing card: $e');
      rethrow;
    }
  }
  
  static Future<void> remindLaterCard(String cardSlug) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindLaterCards = await getRemindLaterCards();
      if (!remindLaterCards.contains(cardSlug)) {
        remindLaterCards.add(cardSlug);
        await prefs.setStringList(_remindLaterCardsKey, remindLaterCards);
      }
      print('Card set for remind later: $cardSlug'); // Debug log
    } catch (e) {
      print('Error setting remind later: $e');
      rethrow;
    }
  }
  
  static Future<List<String>> getDismissedCards() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_dismissedCardsKey) ?? [];
  }
  
  static Future<List<String>> getRemindLaterCards() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_remindLaterCardsKey) ?? [];
  }
  
  static Future<void> clearRemindLaterCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_remindLaterCardsKey);
    print('Remind later cards cleared'); // Debug log
  }
  
  static Future<bool> isCardDismissed(String cardSlug) async {
    final dismissedCards = await getDismissedCards();
    return dismissedCards.contains(cardSlug);
  }
  
  static Future<bool> shouldRemindLater(String cardSlug) async {
    final remindLaterCards = await getRemindLaterCards();
    return remindLaterCards.contains(cardSlug);
  }
}
