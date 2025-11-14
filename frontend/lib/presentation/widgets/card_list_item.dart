import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/gift_card_model.dart';
import '../screens/card_detail_screen.dart';

class CardListItem extends StatelessWidget {
  final GiftCard card;

  const CardListItem({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final isExpiringSoon = card.isExpiringSoon;
    final isExpired = card.isExpired;

    Color statusColor;
    if (card.status == CardStatus.used) {
      statusColor = Colors.grey;
    } else if (isExpired) {
      statusColor = Colors.red;
    } else if (isExpiringSoon) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardDetailScreen(cardId: card.id!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 썸네일 (있는 경우)
              if (card.imageBase64 != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    Uri.parse(card.imageBase64!).data!.contentAsBytes(),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.card_giftcard, size: 30),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // 카드 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카드 이름
                    Text(
                      card.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 카테고리
                    Text(
                      Category.toDisplayName(card.category),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 유효기간
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(card.expirationDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (card.status == CardStatus.active) ...[
                          if (isExpiringSoon)
                            Text(
                              '(D-${card.daysUntilExpiration})',
                              style: TextStyle(
                                fontSize: 14,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else if (!isExpired)
                            Text(
                              '(D-${card.daysUntilExpiration})',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // 상태 뱃지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  CardStatus.toDisplayName(card.status),
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
