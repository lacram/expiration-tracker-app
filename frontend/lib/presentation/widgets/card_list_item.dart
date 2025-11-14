import 'package:flutter/material.dart';
import '../../data/models/gift_card_model.dart';
import '../screens/card_detail_screen.dart';

class CardListItem extends StatelessWidget {
  final GiftCard card;

  const CardListItem({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final daysLeft = card.daysUntilExpiration;
    final isExpiringSoon = card.isExpiringSoon;
    final isExpired = card.isExpired;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CardDetailScreen(cardId: card.id!),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 0.1);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              var fadeAnimation = animation.drive(Tween(begin: 0.0, end: 1.0));

              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 250),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: _getCardGradient(),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _getCardColor().withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 배경 패턴
              Positioned(
                right: -20,
                top: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    _getCategoryIcon(),
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
              // 카드 내용
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단: 카테고리 배지 + 상태
                    Row(
                      children: [
                        _buildCategoryBadge(),
                        const Spacer(),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 카드 이름
                    Text(
                      card.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // 하단: 유효기간 정보
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatExpirationDate(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (!isExpired) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getDaysLeftText(daysLeft),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    // 바코드 번호 (있는 경우)
                    if (card.barcode != null && card.barcode!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.qr_code_rounded,
                            size: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            card.barcode!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getCardGradient() {
    if (card.isExpired) {
      return LinearGradient(
        colors: [Colors.grey[700]!, Colors.grey[500]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (card.isExpiringSoon) {
      return LinearGradient(
        colors: [Colors.orange[700]!, Colors.orange[500]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return _getCategoryGradient();
    }
  }

  LinearGradient _getCategoryGradient() {
    switch (card.category) {
      case Category.giftcard:
        return LinearGradient(
          colors: [Colors.purple[600]!, Colors.purple[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case Category.voucher:
        return LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case Category.coupon:
        return LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case Category.ticket:
        return LinearGradient(
          colors: [Colors.red[700]!, Colors.red[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case Category.membership:
        return LinearGradient(
          colors: [Colors.indigo[700]!, Colors.indigo[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [Colors.teal[700]!, Colors.teal[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getCardColor() {
    if (card.isExpired) return Colors.grey;
    if (card.isExpiringSoon) return Colors.orange;

    switch (card.category) {
      case Category.giftcard:
        return Colors.purple;
      case Category.voucher:
        return Colors.blue;
      case Category.coupon:
        return Colors.green;
      case Category.ticket:
        return Colors.red;
      case Category.membership:
        return Colors.indigo;
      default:
        return Colors.teal;
    }
  }

  IconData _getCategoryIcon() {
    switch (card.category) {
      case Category.giftcard:
        return Icons.card_giftcard_rounded;
      case Category.voucher:
        return Icons.local_activity_rounded;
      case Category.coupon:
        return Icons.confirmation_number_rounded;
      case Category.ticket:
        return Icons.confirmation_num_rounded;
      case Category.membership:
        return Icons.card_membership_rounded;
      default:
        return Icons.credit_card_rounded;
    }
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(),
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            Category.toDisplayName(card.category),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (card.status == CardStatus.used) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.check_circle_rounded,
              size: 14,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              '사용완료',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _formatExpirationDate() {
    final date = card.expirationDate;
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _getDaysLeftText(int days) {
    if (days == 0) return '오늘 만료';
    if (days == 1) return '1일 남음';
    return '$days일 남음';
  }
}
