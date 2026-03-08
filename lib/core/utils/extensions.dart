import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  String get capitalize => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');

  bool get isValidPhone => RegExp(r'^\+?[0-9]{10,13}$').hasMatch(replaceAll(RegExp(r'\s+'), ''));
}

extension DoubleExtensions on double {
  String get inr {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return formatter.format(this);
  }

  String get inrDecimal {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    return formatter.format(this);
  }
}

extension IntExtensions on int {
  String get inr => toDouble().inr;
}

extension DateTimeExtensions on DateTime {
  String get formatted => DateFormat('dd MMM yyyy, hh:mm a').format(this);
  String get dateOnly => DateFormat('dd MMM yyyy').format(this);
}

extension StockExtensions on String {
  Color get stockColor {
    switch (this) {
      case 'in_stock':
        return AppColors.inStock;
      case 'low_stock':
        return AppColors.lowStock;
      case 'out_of_stock':
        return AppColors.outOfStock;
      default:
        return AppColors.textSecondary;
    }
  }

  Color get stockBgColor {
    switch (this) {
      case 'in_stock':
        return AppColors.inStockBg;
      case 'low_stock':
        return AppColors.lowStockBg;
      case 'out_of_stock':
        return AppColors.outOfStockBg;
      default:
        return AppColors.background;
    }
  }
}

extension OrderStatusExtensions on String {
  Color get statusColor {
    switch (this) {
      case 'pending':
        return AppColors.warning;
      case 'processing':
        return AppColors.info;
      case 'shipped':
        return AppColors.primary;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get statusIcon {
    switch (this) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'processing':
        return Icons.settings_rounded;
      case 'shipped':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
