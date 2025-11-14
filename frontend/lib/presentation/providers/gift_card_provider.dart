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

  // 검색 및 정렬 상태
  String _searchQuery = '';
  SortOption _sortOption = SortOption.dateDesc;

  List<GiftCard> get cards => _cards;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedStatus => _selectedStatus;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;

  // 필터링, 검색, 정렬된 카드 목록
  List<GiftCard> get filteredCards {
    var filtered = _cards;

    // 상태 필터
    if (_selectedStatus != null) {
      filtered = filtered.where((card) => card.status == _selectedStatus).toList();
    }

    // 카테고리 필터
    if (_selectedCategory != null) {
      filtered = filtered.where((card) => card.category == _selectedCategory).toList();
    }

    // 검색
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((card) {
        final query = _searchQuery.toLowerCase();
        return card.name.toLowerCase().contains(query) ||
               (card.memo?.toLowerCase().contains(query) ?? false) ||
               (card.barcode?.contains(_searchQuery) ?? false);
      }).toList();
    }

    // 정렬
    switch (_sortOption) {
      case SortOption.nameAsc:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.dateAsc:
        filtered.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
        break;
      case SortOption.dateDesc:
        filtered.sort((a, b) => b.expirationDate.compareTo(a.expirationDate));
        break;
      case SortOption.category:
        filtered.sort((a, b) => a.category.compareTo(b.category));
        break;
      case SortOption.status:
        filtered.sort((a, b) => a.status.compareTo(b.status));
        break;
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

  // 검색어 설정
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // 정렬 옵션 설정
  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  // 필터 초기화
  void clearFilters() {
    _selectedStatus = null;
    _selectedCategory = null;
    _searchQuery = '';
    notifyListeners();
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// 정렬 옵션 열거형
enum SortOption {
  nameAsc,     // 이름 오름차순
  nameDesc,    // 이름 내림차순
  dateAsc,     // 유효기간 오름차순 (임박순)
  dateDesc,    // 유효기간 내림차순
  category,    // 카테고리순
  status,      // 상태순
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.nameAsc:
        return '이름순 (가나다)';
      case SortOption.nameDesc:
        return '이름순 (다나가)';
      case SortOption.dateAsc:
        return '유효기간 임박순';
      case SortOption.dateDesc:
        return '유효기간 최신순';
      case SortOption.category:
        return '카테고리순';
      case SortOption.status:
        return '상태순';
    }
  }
}
