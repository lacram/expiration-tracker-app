import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gift_card_model.dart';
import '../../core/constants/api_endpoints.dart';

class GiftCardApiService {
  // 전체 카드 조회
  Future<List<GiftCard>> fetchAllCards() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.cards));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => GiftCard.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load cards: $e');
    }
  }

  // 개별 카드 조회
  Future<GiftCard> fetchCardById(int id) async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.cardById(id)));

      if (response.statusCode == 200) {
        return GiftCard.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Failed to load card: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load card: $e');
    }
  }

  // 상태별 카드 조회
  Future<List<GiftCard>> fetchCardsByStatus(String status) async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.cardsByStatus(status)));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => GiftCard.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cards by status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load cards by status: $e');
    }
  }

  // 카테고리별 카드 조회
  Future<List<GiftCard>> fetchCardsByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.cardsByCategory(category)));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => GiftCard.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cards by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load cards by category: $e');
    }
  }

  // 유효기간 임박 카드 조회
  Future<List<GiftCard>> fetchExpiringSoonCards(int days) async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.expiringSoon(days)));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => GiftCard.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load expiring soon cards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load expiring soon cards: $e');
    }
  }

  // 만료된 카드 조회
  Future<List<GiftCard>> fetchExpiredCards() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.expired));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => GiftCard.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load expired cards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load expired cards: $e');
    }
  }

  // 통계 조회
  Future<Map<String, dynamic>> fetchStats() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.stats));

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load stats: $e');
    }
  }

  // 카드 생성
  Future<GiftCard> createCard(GiftCard card) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.cards),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(card.toJson()),
      );

      if (response.statusCode == 201) {
        return GiftCard.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Failed to create card: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create card: $e');
    }
  }

  // 카드 수정
  Future<GiftCard> updateCard(int id, GiftCard card) async {
    try {
      final response = await http.put(
        Uri.parse(ApiEndpoints.cardById(id)),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(card.toJson()),
      );

      if (response.statusCode == 200) {
        return GiftCard.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Failed to update card: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update card: $e');
    }
  }

  // 카드 삭제
  Future<void> deleteCard(int id) async {
    try {
      final response = await http.delete(Uri.parse(ApiEndpoints.cardById(id)));

      if (response.statusCode != 204) {
        throw Exception('Failed to delete card: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete card: $e');
    }
  }

  // 카드 사용 완료 처리
  Future<GiftCard> markAsUsed(int id) async {
    try {
      final response = await http.put(Uri.parse(ApiEndpoints.markAsUsed(id)));

      if (response.statusCode == 200) {
        return GiftCard.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Failed to mark card as used: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to mark card as used: $e');
    }
  }
}
