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

          /// ===============================
          /// TOP HEADER
          /// ===============================
          SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 45, 16, 10),
    child: Column(
      children: [

        /// TOP ICON ROW
        Row(
          children: [

            /// WHATSAPP ICON
            Container(
              height: 42,
              width: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F7ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat, // whatsapp style
                color: Colors.green,
                size: 22,
              ),
            ),

            const Spacer(),

            /// BALAJI LOGO (BIGGER)
            SizedBox(
              height: 60,
              child: Image.asset(
                "assets/images/balaji_logo_transparent.png",
                fit: BoxFit.contain,
              ),
            ),

            const Spacer(),

            /// PROFILE ICON
            Container(
              height: 42,
              width: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF0F6C5C),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        /// LOCATION (CENTERED)
        userAsync.when(
          data: (u) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home, color: Color(0xFF0F6C5C), size: 18),
              const SizedBox(width: 6),

              Text(
                "HOME - ${u?.address?.toString() ?? "167, 1401, 4th Tank Road"}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 18)
            ],
          ),
          loading: () => const Text("Loading..."),
          error: (_, __) => const Text("Set address"),
        ),

        const SizedBox(height: 14),

        /// SEARCH BAR
        GestureDetector(
          onTap: () => context.push(AppRoutes.search),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [

                const Icon(Icons.search, color: Colors.grey),

                const SizedBox(width: 8),

                const Expanded(
                  child: Text(
                    "Search fashion & products",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                /// TRY AT HOME BUTTON (BIGGER)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xFF0F6C5C),
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 18,
                        color: Color(0xFF0F6C5C),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "TRY AT HOME",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F6C5C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
),

          /// ===============================
          /// MAIN CONTENT
          /// ===============================
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
                  data: (products) =>
                      FeaturedProductsRow(products: products),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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

/// =================================
/// SECTION HEADER
/// =================================
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}