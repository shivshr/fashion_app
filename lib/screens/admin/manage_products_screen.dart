import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/core/constants/app_routes.dart';
import 'package:fashion_app/core/utils/extensions.dart';
import 'package:fashion_app/providers/product_provider.dart';
import 'package:fashion_app/services/product_service.dart';
import 'package:fashion_app/widgets/stock_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ManageProductsScreen extends ConsumerWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.addProduct),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          itemBuilder: (_, i) {
            final p = products[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                        width: 64,
                        height: 72,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 64, height: 72,
                          color: AppColors.background,
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(p.price.inr, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              StockBadge(stockStatus: p.stockStatus, stock: p.stock),
                              const SizedBox(width: 8),
                              if (!p.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.outOfStockBg, borderRadius: BorderRadius.circular(20)),
                                  child: const Text('Hidden', style: TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w600)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (action) => _handleAction(context, ref, p.productId, action, p),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Edit')])),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(children: [
                            Icon(p.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(p.isActive ? 'Hide' : 'Show'),
                          ]),
                        ),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppColors.error), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.error))])),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addProduct),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String productId, String action, dynamic product) {
    final service = ProductService();
    switch (action) {
      case 'edit':
        context.push(AppRoutes.addProduct, extra: product);
        break;
      case 'toggle':
        service.toggleProductActive(productId, !(product.isActive as bool));
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Product?'),
            content: const Text('This will hide the product from customers.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  service.deleteProduct(productId);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
    }
  }
}
