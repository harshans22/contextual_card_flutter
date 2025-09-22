import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _dismissedCardsKey = 'dismissed_cards';
  static const String _remindLaterCardsKey = 'remind_later_cards';
  
  static Future<void> dismissCard(String cardSlug) async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedCards = await getDismissedCards();
    dismissedCards.add(cardSlug);
    await prefs.setStringList(_dismissedCardsKey, dismissedCards);
  }
  
  static Future<void> remindLaterCard(String cardSlug) async {
    final prefs = await SharedPreferences.getInstance();
    final remindLaterCards = await getRemindLaterCards();
    remindLaterCards.add(cardSlug);
    await prefs.setStringList(_remindLaterCardsKey, remindLaterCards);
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
