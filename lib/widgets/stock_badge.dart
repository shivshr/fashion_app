import 'package:fashion_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';

class StockBadge extends StatelessWidget {
  final String stockStatus;
  final int stock;
  const StockBadge({required this.stockStatus, required this.stock, super.key});

  @override
  Widget build(BuildContext context) {
    String label;
    switch (stockStatus) {
      case 'out_of_stock':
        label = 'Out of Stock';
        break;
      case 'low_stock':
        label = 'Only $stock left!';
        break;
      default:
        label = 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: stockStatus.stockBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stockStatus.stockColor.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: stockStatus.stockColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
