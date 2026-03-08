import 'package:fashion_app/models/product_model.dart';
import 'package:fashion_app/widgets/product_card.dart';
import 'package:flutter/material.dart';

class FeaturedProductsRow extends StatelessWidget {
  final List<ProductModel> products;

  const FeaturedProductsRow({required this.products, super.key});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No featured products yet')),
      );
    }

    return SizedBox(
      height: 340, // slightly bigger so cards always fit
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 190,
            child: ProductCard(
              product: products[index],
            ),
          );
        },
      ),
    );
  }
}