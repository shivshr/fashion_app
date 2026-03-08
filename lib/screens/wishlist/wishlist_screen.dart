import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/providers/product_provider.dart';
import 'package:fashion_app/providers/wishlist_provider.dart';
import 'package:fashion_app/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistIds = ref.watch(wishlistProvider);
    final allProductsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Wishlist (${wishlistIds.length})')),
      body: allProductsAsync.when(
        data: (all) {
          final products = all.where((p) => wishlistIds.contains(p.productId)).toList();
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 72, color: AppColors.textHint),
                  SizedBox(height: 12),
                  Text('No items in wishlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemCount: products.length,
            itemBuilder: (_, i) => ProductCard(product: products[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
