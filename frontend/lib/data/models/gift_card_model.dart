class GiftCard {
  final int? id;
  final String name;
  final String category;
  final DateTime expirationDate;
  final String status;
  final String? imageBase64;
  final String? barcode;
  final String? memo;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? usedAt;

  GiftCard({
    this.id,
    required this.name,
    required this.category,
    required this.expirationDate,
    required this.status,
    this.imageBase64,
    this.barcode,
    this.memo,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.usedAt,
  });

  // JSON에서 GiftCard 객체로 변환
  factory GiftCard.fromJson(Map<String, dynamic> json) {
    return GiftCard(
      id: json['id'] as int?,
      name: json['name'] as String,
      category: json['category'] as String,
      expirationDate: DateTime.parse(json['expirationDate'] as String),
      status: json['status'] as String,
      imageBase64: json['imageBase64'] as String?,
      barcode: json['barcode'] as String?,
      memo: json['memo'] as String?,
      userId: json['userId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      usedAt: json['usedAt'] != null
          ? DateTime.parse(json['usedAt'] as String)
          : null,
    );
  }

  // GiftCard 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'expirationDate': expirationDate.toIso8601String().split('T')[0], // YYYY-MM-DD 형식
      'status': status,
      if (imageBase64 != null) 'imageBase64': imageBase64,
      if (barcode != null) 'barcode': barcode,
      if (memo != null) 'memo': memo,
      if (userId != null) 'userId': userId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (usedAt != null) 'usedAt': usedAt!.toIso8601String(),
    };
  }

  // 복사본 생성 (일부 필드만 수정)
  GiftCard copyWith({
    int? id,
    String? name,
    String? category,
    DateTime? expirationDate,
    String? status,
    String? imageBase64,
    String? barcode,
    String? memo,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? usedAt,
  }) {
    return GiftCard(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      expirationDate: expirationDate ?? this.expirationDate,
      status: status ?? this.status,
      imageBase64: imageBase64 ?? this.imageBase64,
      barcode: barcode ?? this.barcode,
      memo: memo ?? this.memo,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usedAt: usedAt ?? this.usedAt,
    );
  }

  // 유효기간까지 남은 일수 계산
  int get daysUntilExpiration {
    final now = DateTime.now();
    final difference = expirationDate.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  // 유효기간 임박 여부 (7일 이내)
  bool get isExpiringSoon {
    return daysUntilExpiration >= 0 && daysUntilExpiration <= 7;
  }

  // 만료 여부
  bool get isExpired {
    return daysUntilExpiration < 0;
  }
}

// 카테고리 ENUM
class Category {
  static const String giftcard = 'GIFTCARD';
  static const String voucher = 'VOUCHER';
  static const String coupon = 'COUPON';
  static const String ticket = 'TICKET';
  static const String membership = 'MEMBERSHIP';
  static const String etc = 'ETC';

  static const List<String> values = [
    giftcard,
    voucher,
    coupon,
    ticket,
    membership,
    etc,
  ];

  static String toDisplayName(String category) {
    switch (category) {
      case giftcard:
        return '기프티콘';
      case voucher:
        return '상품권';
      case coupon:
        return '쿠폰';
      case ticket:
        return '티켓';
      case membership:
        return '멤버십';
      case etc:
        return '기타';
      default:
        return category;
    }
  }
}

// 상태 ENUM
class CardStatus {
  static const String active = 'ACTIVE';
  static const String expired = 'EXPIRED';
  static const String used = 'USED';

  static const List<String> values = [
    active,
    expired,
    used,
  ];

  static String toDisplayName(String status) {
    switch (status) {
      case active:
        return '사용 가능';
      case expired:
        return '만료됨';
      case used:
        return '사용 완료';
      default:
        return status;
    }
  }
}
