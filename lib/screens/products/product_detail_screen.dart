// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:fashion_app/core/constants/app_colors.dart';
// import 'package:fashion_app/core/constants/app_routes.dart';
// import 'package:fashion_app/core/utils/extensions.dart';
// import 'package:fashion_app/models/cart_item_model.dart';
// import 'package:fashion_app/providers/cart_provider.dart';
// import 'package:fashion_app/providers/product_provider.dart';
// import 'package:fashion_app/providers/wishlist_provider.dart';
// import 'package:fashion_app/widgets/stock_badge.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// class ProductDetailScreen extends ConsumerStatefulWidget {
//   final String productId;
//   const ProductDetailScreen({required this.productId, super.key});

//   @override
//   ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
// }

// class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
//   String? _selectedSize;
//   int _currentImage = 0;

//   @override
//   Widget build(BuildContext context) {
//     final productAsync = ref.watch(singleProductProvider(widget.productId));
//     final wishlist = ref.watch(wishlistProvider);

//     return productAsync.when(
//       data: (product) {
//         if (product == null) return const Scaffold(body: Center(child: Text('Product not found')));
//         final isWishlisted = wishlist.contains(product.productId);

//         return Scaffold(
//           backgroundColor: AppColors.background,
//           body: CustomScrollView(
//             slivers: [
//               SliverAppBar(
//                 expandedHeight: 360,
//                 pinned: true,
//                 backgroundColor: AppColors.surface,
//                 actions: [
//                   IconButton(
//                     icon: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border,
//                         color: isWishlisted ? AppColors.error : AppColors.textPrimary),
//                     onPressed: () => ref.read(wishlistProvider.notifier).toggle(product.productId),
//                   ),
//                 ],
//                 flexibleSpace: FlexibleSpaceBar(
//                   background: Stack(
//                     children: [
//                       CarouselSlider.builder(
//                         itemCount: product.imageUrls.length,
//                         options: CarouselOptions(
//                           height: 400,
//                           viewportFraction: 1,
//                           onPageChanged: (i, _) => setState(() => _currentImage = i),
//                         ),
//                         itemBuilder: (_, i, __) => CachedNetworkImage(
//                           imageUrl: product.imageUrls[i],
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           placeholder: (_, __) => Container(color: AppColors.shimmerBase),
//                           errorWidget: (_, __, ___) => Container(
//                             color: AppColors.background,
//                             child: const Icon(Icons.image_not_supported_outlined, size: 60, color: AppColors.textHint),
//                           ),
//                         ),
//                       ),
//                       if (product.imageUrls.length > 1)
//                         Positioned(
//                           bottom: 56,
//                           left: 0,
//                           right: 0,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: List.generate(
//                               product.imageUrls.length,
//                               (i) => AnimatedContainer(
//                                 duration: const Duration(milliseconds: 300),
//                                 margin: const EdgeInsets.symmetric(horizontal: 3),
//                                 width: i == _currentImage ? 20 : 8,
//                                 height: 8,
//                                 decoration: BoxDecoration(
//                                   color: i == _currentImage ? AppColors.primary : Colors.white.withOpacity(0.7),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: AppColors.surface,
//                     borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//                   ),
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: Text(product.name,
//                                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
//                           ),
//                           StockBadge(stockStatus: product.stockStatus, stock: product.stock),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Text(product.price.inr,
//                               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
//                           if (product.comparePrice != null) ...[
//                             const SizedBox(width: 10),
//                             Text(
//                               product.comparePrice!.inr,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 color: AppColors.textHint,
//                                 decoration: TextDecoration.lineThrough,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             if (product.discountPercent > 0)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                                 decoration: BoxDecoration(
//                                   color: AppColors.error.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Text(
//                                   '${product.discountPercent.toInt()}% OFF',
//                                   style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700),
//                                 ),
//                               ),
//                           ],
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           const Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
//                           const SizedBox(width: 4),
//                           Text('${product.rating}  (${product.reviewCount} reviews)',
//                               style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
//                         ],
//                       ),
//                       const Divider(height: 28),
//                       // Size selector
//                       if (product.sizes.isNotEmpty) ...[
//                         const Text('Select Size', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
//                         const SizedBox(height: 10),
//                         Wrap(
//                           spacing: 10,
//                           children: product.sizes.map((size) {
//                             final isSelected = _selectedSize == size;
//                             return GestureDetector(
//                               onTap: product.inStock ? () => setState(() => _selectedSize = size) : null,
//                               child: AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 width: 48,
//                                 height: 48,
//                                 decoration: BoxDecoration(
//                                   color: isSelected ? AppColors.primary : AppColors.surface,
//                                   borderRadius: BorderRadius.circular(10),
//                                   border: Border.all(
//                                     color: isSelected ? AppColors.primary : AppColors.divider,
//                                     width: isSelected ? 2 : 1,
//                                   ),
//                                 ),
//                                 child: Center(
//                                   child: Text(size,
//                                       style: TextStyle(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w600,
//                                         color: isSelected ? Colors.white : AppColors.textPrimary,
//                                       )),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                         const Divider(height: 28),
//                       ],
//                       const Text('Product Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
//                       const SizedBox(height: 8),
//                       Text(product.description,
//                           style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
//                       const SizedBox(height: 100),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           bottomNavigationBar: Container(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
//             decoration: BoxDecoration(
//               color: AppColors.surface,
//               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))],
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: product.inStock
//                         ? () {
//                             if (product.sizes.isNotEmpty && _selectedSize == null) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('Please select a size')),
//                               );
//                               return;
//                             }
//                             ref.read(cartProvider.notifier).addItem(CartItemModel(
//                                   productId: product.productId,
//                                   name: product.name,
//                                   imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
//                                   price: product.price,
//                                   quantity: 1,
//                                   selectedSize: _selectedSize ?? '',
//                                   availableStock: product.stock,
//                                 ));
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('Added to cart! 🛒'), backgroundColor: AppColors.success),
//                             );
//                           }
//                         : null,
//                     child: const Text('Add to Cart'),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: product.inStock
//                         ? () {
//                             if (product.sizes.isNotEmpty && _selectedSize == null) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('Please select a size')),
//                               );
//                               return;
//                             }
//                             ref.read(cartProvider.notifier).addItem(CartItemModel(
//                                   productId: product.productId,
//                                   name: product.name,
//                                   imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
//                                   price: product.price,
//                                   quantity: 1,
//                                   selectedSize: _selectedSize ?? '',
//                                   availableStock: product.stock,
//                                 ));
//                             context.push(AppRoutes.cart);
//                           }
//                         : null,
//                     child: product.inStock ? const Text('Buy Now') : const Text('Out of Stock'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//       loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
//       error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/core/constants/app_routes.dart';
import 'package:fashion_app/core/utils/extensions.dart';
import 'package:fashion_app/models/cart_item_model.dart';
import 'package:fashion_app/providers/cart_provider.dart';
import 'package:fashion_app/providers/product_provider.dart';
import 'package:fashion_app/providers/wishlist_provider.dart';
import 'package:fashion_app/widgets/stock_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({required this.productId, super.key});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? _selectedSize;
  int _currentImage = 0;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(singleProductProvider(widget.productId));
    final wishlist = ref.watch(wishlistProvider);

    return productAsync.when(
      data: (product) {
        if (product == null) return const Scaffold(body: Center(child: Text('Product not found')));
        final isWishlisted = wishlist.contains(product.productId);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                backgroundColor: AppColors.surface,
                actions: [
                  IconButton(
                    icon: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? AppColors.error : AppColors.textPrimary),
                    onPressed: () => ref.read(wishlistProvider.notifier).toggle(product.productId),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      CarouselSlider.builder(
                        itemCount: product.imageUrls.length,
                        options: CarouselOptions(
                          height: 400,
                          viewportFraction: 1,
                          onPageChanged: (i, _) => setState(() => _currentImage = i),
                        ),
                        itemBuilder: (_, i, __) => CachedNetworkImage(
                          imageUrl: product.imageUrls[i],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) => Container(color: AppColors.shimmerBase),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.background,
                            child: const Icon(Icons.image_not_supported_outlined, size: 60, color: AppColors.textHint),
                          ),
                        ),
                      ),
                      if (product.imageUrls.length > 1)
                        Positioned(
                          bottom: 56,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              product.imageUrls.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: i == _currentImage ? 20 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: i == _currentImage ? AppColors.primary : Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(product.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          ),
                          StockBadge(stockStatus: product.stockStatus, stock: product.stock),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(product.price.inr,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          if (product.comparePrice != null) ...[
                            const SizedBox(width: 10),
                            Text(
                              product.comparePrice!.inr,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (product.discountPercent > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${product.discountPercent.toInt()}% OFF',
                                  style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
                          const SizedBox(width: 4),
                          Text('${product.rating}  (${product.reviewCount} reviews)',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                      const Divider(height: 28),
                      // Size selector
                      if (product.sizes.isNotEmpty) ...[
                        const Text('Select Size', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: product.sizes.map((size) {
                            final isSelected = _selectedSize == size;
                            return GestureDetector(
                              onTap: product.inStock ? () => setState(() => _selectedSize = size) : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.divider,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(size,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                      )),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const Divider(height: 28),
                      ],
                      const Text('Product Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(product.description,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: product.inStock
                        ? () {
                            if (product.sizes.isNotEmpty && _selectedSize == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a size')),
                              );
                              return;
                            }
                            ref.read(cartProvider.notifier).addItem(CartItemModel(
                                  productId: product.productId,
                                  name: product.name,
                                  imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                                  price: product.price,
                                  quantity: 1,
                                  selectedSize: _selectedSize ?? '',
                                  availableStock: product.stock,
                                ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart! 🛒'), backgroundColor: AppColors.success),
                            );
                          }
                        : null,
                    child: const Text('Add to Cart'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: product.inStock
                        ? () {
                            if (product.sizes.isNotEmpty && _selectedSize == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a size')),
                              );
                              return;
                            }
                            ref.read(cartProvider.notifier).addItem(CartItemModel(
                                  productId: product.productId,
                                  name: product.name,
                                  imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                                  price: product.price,
                                  quantity: 1,
                                  selectedSize: _selectedSize ?? '',
                                  availableStock: product.stock,
                                ));
                            context.go(AppRoutes.cart);
                          }
                        : null,
                    child: product.inStock ? const Text('Buy Now') : const Text('Out of Stock'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}