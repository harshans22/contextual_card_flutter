import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card_models.dart';

class ApiService {
  static const String baseUrl = 'https://polyjuice.kong.fampay.co';
  static const String endpoint = '/mock/famapp/feed/home_section/?slugs=famx-paypage';
  
  static Future<List<CardGroup>> fetchContextualCards() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<CardGroup> cardGroups = [];
        
        for (final item in jsonData) {
          if (item['hc_groups'] != null) {
            final groups = (item['hc_groups'] as List)
                .map((group) => CardGroup.fromJson(group))
                .toList();
            cardGroups.addAll(groups);
          }
        }
        
        return cardGroups;
      } else {
        throw Exception('Failed to load contextual cards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching contextual cards: $e');
    }
  }
}
