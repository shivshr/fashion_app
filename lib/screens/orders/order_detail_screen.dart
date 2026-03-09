import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/core/utils/extensions.dart';
import 'package:fashion_app/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({required this.orderId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(singleOrderProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: orderAsync.when(
        data: (order) {
          if (order == null) return const Center(child: Text('Order not found'));
          final steps = ['pending', 'processing', 'shipped', 'delivered'];
          final currentStep = steps.indexOf(order.orderStatus);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status stepper
                if (order.orderStatus != 'cancelled')
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Order Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          Row(
                            children: List.generate(steps.length, (i) {
                              final isDone = i <= currentStep;
                              return Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        if (i > 0) Expanded(child: Container(height: 2, color: isDone ? AppColors.primary : AppColors.divider)),
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isDone ? AppColors.primary : AppColors.divider,
                                          ),
                                          child: Icon(steps[i].statusIcon, size: 14, color: Colors.white),
                                        ),
                                        if (i < steps.length - 1) Expanded(child: Container(height: 2, color: i < currentStep ? AppColors.primary : AppColors.divider)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(steps[i].capitalize,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
                                          color: isDone ? AppColors.primary : AppColors.textHint,
                                        )),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const Card(
                    color: AppColors.outOfStockBg,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.cancel_rounded, color: AppColors.error),
                          SizedBox(width: 12),
                          Text('This order was cancelled', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Order info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        _InfoRow('Order ID', '#${order.orderId.substring(0, 8).toUpperCase()}'),
                        _InfoRow('Date', order.createdAt?.formatted ?? ''),
                        _InfoRow('Payment', order.paymentStatus.capitalize),
                        _InfoRow('Method', order.paymentMethod.capitalize),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Delivery address
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(order.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(order.shippingAddress.toString(),
                            style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Items
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: item.imageUrl,
                                      width: 56,
                                      height: 62,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                          width: 56,
                                          height: 62,
                                          color: AppColors.background,
                                          child: const Icon(Icons.image_not_supported_outlined)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.w600)),
                                        if (item.selectedSize.isNotEmpty)
                                          Text('Size: ${item.selectedSize}',
                                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                        Text('Qty: ${item.quantity}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  Text(item.subtotal.inr, style: const TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                            )),
                        const Divider(),
                        _InfoRow('Subtotal', order.subtotal.inr),
                        _InfoRow('Shipping', order.shippingFee == 0 ? 'FREE' : order.shippingFee.inr),
                        _InfoRow('Total', order.totalPrice.inr, bold: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _InfoRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w600, fontSize: bold ? 16 : 13,
              color: bold ? AppColors.primary : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
