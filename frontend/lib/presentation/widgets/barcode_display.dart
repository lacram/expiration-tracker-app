import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class BarcodeDisplay extends StatelessWidget {
  final String barcode;
  final double width;
  final double height;

  const BarcodeDisplay({
    super.key,
    required this.barcode,
    this.width = 300,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 바코드 이미지
          BarcodeWidget(
            barcode: Barcode.code128(),
            data: barcode,
            width: width,
            height: height,
            drawText: false,
            errorBuilder: (context, error) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    '바코드를 생성할 수 없습니다',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // 바코드 번호
          Text(
            barcode,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
