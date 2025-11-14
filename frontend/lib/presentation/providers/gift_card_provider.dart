import 'package:flutter/foundation.dart';
import '../../data/models/gift_card_model.dart';
import '../../data/services/gift_card_api_service.dart';
import '../../data/services/ocr_api_service.dart';
import '../../data/models/ocr_response_model.dart';

class GiftCardProvider with ChangeNotifier {
  final GiftCardApiService _apiService = GiftCardApiService();
  final OcrApiService _ocrService = OcrApiService();

  List<GiftCard> _cards = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _error;

  // 필터링 상태
  String? _selectedStatus;
  String? _selectedCategory;

  List<GiftCard> get cards => _cards;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedStatus => _selectedStatus;
  String? get selectedCategory => _selectedCategory;

  // 필터링된 카드 목록
  List<GiftCard> get filteredCards {
    var filtered = _cards;

    if (_selectedStatus != null) {
      filtered = filtered.where((card) => card.status == _selectedStatus).toList();
    }

    if (_selectedCategory != null) {
      filtered = filtered.where((card) => card.category == _selectedCategory).toList();
    }

    return filtered;
  }

  // 전체 카드 로드
  Future<void> loadCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cards = await _apiService.fetchAllCards();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 통계 로드
  Future<void> loadStats() async {
    try {
      _stats = await _apiService.fetchStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // 카드 생성
  Future<bool> createCard(GiftCard card) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCard = await _apiService.createCard(card);
      _cards.add(newCard);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 카드 수정
  Future<bool> updateCard(int id, GiftCard card) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCard = await _apiService.updateCard(id, card);
      final index = _cards.indexWhere((c) => c.id == id);
      if (index != -1) {
        _cards[index] = updatedCard;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 카드 삭제
  Future<bool> deleteCard(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteCard(id);
      _cards.removeWhere((card) => card.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 카드 사용 완료 처리
  Future<bool> markCardAsUsed(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final usedCard = await _apiService.markAsUsed(id);
      final index = _cards.indexWhere((c) => c.id == id);
      if (index != -1) {
        _cards[index] = usedCard;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // OCR 처리
  Future<OcrResponse?> processImageOcr(String imageBase64) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _ocrService.processImage(imageBase64);
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // 상태 필터 설정
  void setStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  // 카테고리 필터 설정
  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // 필터 초기화
  void clearFilters() {
    _selectedStatus = null;
    _selectedCategory = null;
    notifyListeners();
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
