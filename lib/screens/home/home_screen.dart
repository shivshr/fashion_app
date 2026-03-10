import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/core/constants/app_routes.dart';
import 'package:fashion_app/providers/auth_provider.dart';
import 'package:fashion_app/providers/product_provider.dart';
import 'package:fashion_app/providers/location_provider.dart';
import 'package:fashion_app/screens/home/widgets/banner_carousel.dart';
import 'package:fashion_app/screens/home/widgets/category_grid.dart';
import 'package:fashion_app/screens/home/widgets/featured_products.dart';
import 'package:fashion_app/widgets/whatsapp_support_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  bool showFullAddress = false;

  /// =================================
  /// WHATSAPP CHAT SUPPORT
  /// =================================
  Future<void> _openWhatsApp() async {

    const phone = "918305771664";

    const message =
        "Hello Balaji Textile, I need help regarding a product.";

    final url = Uri.parse(
        "https://wa.me/$phone?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// =================================
  /// TRY AT HOME POPUP
  /// =================================
  void _showTryAtHome(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const SizedBox(height: 10),

              const Text(
                "Free Trial at home, Pay for what you love!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              _step(Icons.local_shipping,
                  "Order & get it delivered to your doorstep"),

              _step(Icons.home_work,
                  "Try the clothes while our rider waits at your doorstep"),

              _step(Icons.replay,
                  "Don't like it? Return instantly to the delivery partner"),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Continue Shopping"),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _step(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF0F6C5C)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final locationAsync = ref.watch(locationProvider);
    final featured = ref.watch(featuredProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,

      /// STACK FOR FLOATING BUTTON
      body: Stack(
        children: [

          CustomScrollView(
            slivers: [

              /// HEADER
              SliverToBoxAdapter(
                child: Container(
                  color: const Color(0xFFE6F7ED),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 45, 16, 10),
                    child: Column(
                      children: [

                        /// TOP ICON ROW
                        Row(
                          children: [

                            /// WHATSAPP CHAT BUTTON
                            GestureDetector(
                              onTap: _openWhatsApp,
                              child: Container(
                                height: 42,
                                width: 42,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
          padding: const EdgeInsets.all(9),
          child: Image.asset(
            "assets/images/whatsappp.png",
          ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            /// BALAJI LOGO
                            SizedBox(
                              height: 65,
                              child: Image.asset(
                                "assets/images/balaji_logo_transparent.png",
                                fit: BoxFit.contain,
                              ),
                            ),

                            const Spacer(),

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

                        /// LOCATION
                        locationAsync.when(
                          data: (address) {

                            String shortAddress = address.split(',').first;

                            return Column(
                              children: [

                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showFullAddress = !showFullAddress;
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      const Icon(
                                        Icons.home,
                                        color: Color(0xFF0F6C5C),
                                        size: 18,
                                      ),

                                      const SizedBox(width: 6),

                                      Expanded(
                                        child: Text(
                                          showFullAddress
                                              ? "HOME - $address"
                                              : "HOME - $shortAddress",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                      const SizedBox(width: 4),

                                      Icon(
                                        showFullAddress
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),

                                if (showFullAddress)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        address,
                                        style: const TextStyle(fontSize: 13),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                          loading: () => const Text("Fetching location..."),
                          error: (e, _) => const Text("Location unavailable"),
                        ),

                        const SizedBox(height: 14),

                        /// SEARCH BAR
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.search),
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
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

                                /// TRY AT HOME BUTTON
                                GestureDetector(
                                  onTap: () {
                                    _showTryAtHome(context);
                                  },
                                  child: Container(
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// MAIN CONTENT
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

          /// FLOATING WHATSAPP BUTTON
         WhatsAppSupportButton(),

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