import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/gift_card_model.dart';
import '../providers/gift_card_provider.dart';
import '../widgets/barcode_display.dart';

class CardDetailScreen extends StatefulWidget {
  final int cardId;

  const CardDetailScreen({super.key, required this.cardId});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  GiftCard? _card;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    final provider = Provider.of<GiftCardProvider>(context, listen: false);
    // 로컬에서 찾기
    final card = provider.cards.firstWhere(
      (c) => c.id == widget.cardId,
      orElse: () => throw Exception('Card not found'),
    );

    setState(() {
      _card = card;
      _isLoading = false;
    });
  }

  // 카드 삭제
  Future<void> _deleteCard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카드 삭제'),
        content: const Text('정말로 이 카드를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<GiftCardProvider>(context, listen: false);
      final success = await provider.deleteCard(widget.cardId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('카드가 삭제되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? '카드 삭제에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 사용 완료 처리
  Future<void> _markAsUsed() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용 완료'),
        content: const Text('이 카드를 사용 완료로 처리하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<GiftCardProvider>(context, listen: false);
      final success = await provider.markCardAsUsed(widget.cardId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('카드가 사용 완료 처리되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadCard(); // 새로고침
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? '사용 완료 처리에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_card == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('카드 상세')),
        body: const Center(
          child: Text('카드를 찾을 수 없습니다'),
        ),
      );
    }

    final card = _card!;
    final dateFormat = DateFormat('yyyy년 MM월 dd일');

    Color statusColor;
    if (card.status == CardStatus.used) {
      statusColor = Colors.grey;
    } else if (card.isExpired) {
      statusColor = Colors.red;
    } else if (card.isExpiringSoon) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('카드 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteCard,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이미지 (있는 경우)
            if (card.imageBase64 != null)
              Image.memory(
                Uri.parse(card.imageBase64!).data!.contentAsBytes(),
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.card_giftcard, size: 64),
                    ),
                  );
                },
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상태 뱃지
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor, width: 1.5),
                        ),
                        child: Text(
                          CardStatus.toDisplayName(card.status),
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        Category.toDisplayName(card.category),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 카드 이름
                  Text(
                    card.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 유효기간
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: '유효기간',
                    value: dateFormat.format(card.expirationDate),
                    valueColor: statusColor,
                  ),

                  if (card.status == CardStatus.active) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.timer,
                      label: '남은 기간',
                      value: card.daysUntilExpiration >= 0
                          ? 'D-${card.daysUntilExpiration}'
                          : '만료됨',
                      valueColor: statusColor,
                    ),
                  ],

                  // 생성일
                  if (card.createdAt != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.add_circle_outline,
                      label: '등록일',
                      value: dateFormat.format(card.createdAt!),
                    ),
                  ],

                  // 사용일
                  if (card.usedAt != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: Icons.check_circle_outline,
                      label: '사용일',
                      value: dateFormat.format(card.usedAt!),
                      valueColor: Colors.grey,
                    ),
                  ],

                  // 메모
                  if (card.memo != null && card.memo!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      '메모',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(card.memo!),
                    ),
                  ],

                  // 바코드
                  if (card.barcode != null && card.barcode!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      '바코드',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: BarcodeDisplay(
                        barcode: card.barcode!,
                        width: MediaQuery.of(context).size.width - 64,
                        height: 100,
                      ),
                    ),
                  ],

                  // 사용 완료 버튼
                  if (card.status == CardStatus.active) ...[
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _markAsUsed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        '사용 완료 처리',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
