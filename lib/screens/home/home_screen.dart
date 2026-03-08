import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/core/constants/app_routes.dart';
import 'package:fashion_app/providers/auth_provider.dart';
import 'package:fashion_app/providers/product_provider.dart';
import 'package:fashion_app/screens/home/widgets/banner_carousel.dart';
import 'package:fashion_app/screens/home/widgets/category_grid.dart';
import 'package:fashion_app/screens/home/widgets/featured_products.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final featured = ref.watch(featuredProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
  floating: true,
  snap: true,
  backgroundColor: Colors.transparent,
  elevation: 0,
  expandedHeight: 200,
  flexibleSpace: SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: [

          /// BEIGE LOCATION CARD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF4E6D4),
                  Color(0xFFEED7BC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [

                const Icon(
                  Icons.location_on,
                  color: Color(0xFF9C7B50),
                  size: 22,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Deliver to",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9C7B50),
                        ),
                      ),

                      userAsync.when(
                        data: (u) => Text(
                          u?.address?.toString() ?? "Indore, India",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A3C20),
                          ),
                        ),
                        loading: () => const Text("Loading..."),
                        error: (_, __) => const Text("Set address"),
                      ),
                    ],
                  ),
                ),

                /// PROFILE ICON
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4E6D4),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF9C7B50),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          /// SEARCH BAR
          GestureDetector(
            onTap: () => context.push(AppRoutes.search),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                  )
                ],
              ),
              child: Row(
                children: [

                  const SizedBox(width: 14),

                  const Icon(Icons.search, color: Colors.grey),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Text(
                      "Search fashion...",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  /// TRY AT HOME BUTTON
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6B4A2E),
                          Color(0xFF2E1B0F),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.home, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          "Try At Home",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const BannerCarousel(),
                const SizedBox(height: 24),
                const _SectionHeader(title: '⭐ SHOP BY CATEGORY ⭐'),
                const SizedBox(height: 12),
                const CategoryGrid(),
                const SizedBox(height: 24),
                const _SectionHeader(title: '⭐ FEATURED PRODUCTS'),
                const SizedBox(height: 12),
                
                featured.when(
                  data: (products) => FeaturedProductsRow(products: products),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: AppColors.textPrimary),
      ),
    );
  }
}
