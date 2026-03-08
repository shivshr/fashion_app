import 'package:fashion_app/providers/auth_provider.dart';
import 'package:fashion_app/screens/admin/admin_dashboard_screen.dart';
import 'package:fashion_app/screens/admin/admin_login_screen.dart';
import 'package:fashion_app/screens/admin/add_product_screen.dart';
import 'package:fashion_app/screens/admin/manage_products_screen.dart';
import 'package:fashion_app/screens/admin/order_management_screen.dart';
import 'package:fashion_app/screens/auth/otp_verify_screen.dart';
import 'package:fashion_app/screens/auth/phone_login_screen.dart';
import 'package:fashion_app/screens/cart/cart_screen.dart';
import 'package:fashion_app/screens/checkout/checkout_screen.dart';
import 'package:fashion_app/screens/checkout/order_confirmation_screen.dart';
import 'package:fashion_app/screens/checkout/payment_screen.dart';
import 'package:fashion_app/screens/home/home_screen.dart';
import 'package:fashion_app/screens/orders/my_orders_screen.dart';
import 'package:fashion_app/screens/orders/order_detail_screen.dart';
import 'package:fashion_app/screens/products/product_detail_screen.dart';
import 'package:fashion_app/screens/products/product_list_screen.dart';
import 'package:fashion_app/screens/products/search_screen.dart';
import 'package:fashion_app/screens/profile/profile_screen.dart';
import 'package:fashion_app/screens/splash/splash_screen.dart';
import 'package:fashion_app/screens/wishlist/wishlist_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRoutes {
  static const String splash = '/';
  static const String phoneLogin = '/login';
  static const String otpVerify = '/otp';
  static const String home = '/home';
  static const String productList = '/products';
  static const String productDetail = '/product/:id';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static const String orderConfirmation = '/order-confirmation';
  static const String myOrders = '/orders';
  static const String orderDetail = '/order/:id';
  static const String wishlist = '/wishlist';
  static const String profile = '/profile';
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String addProduct = '/admin/add-product';
  static const String manageProducts = '/admin/products';
  static const String orderManagement = '/admin/orders';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) async {
      final isLoggedIn = authState.value != null;
      final isLoading = authState.isLoading;
      if (isLoading) return null;

      final currentPath = state.matchedLocation;

      // These routes are always accessible
      final isPublicRoute = currentPath == AppRoutes.phoneLogin ||
          currentPath == AppRoutes.otpVerify ||
          currentPath == AppRoutes.splash ||
          currentPath == AppRoutes.adminLogin;

      // Admin routes - check SharedPreferences
      final isAdminRoute = currentPath.startsWith('/admin/') &&
          currentPath != AppRoutes.adminLogin;

      if (isAdminRoute) {
        final prefs = await SharedPreferences.getInstance();
        final isAdmin = prefs.getBool('is_admin') ?? false;
        if (!isAdmin) return AppRoutes.adminLogin;
        return null;
      }

      // Customer routes - check Firebase Auth
      if (!isLoggedIn && !isPublicRoute) return AppRoutes.phoneLogin;

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.phoneLogin, builder: (_, __) => const PhoneLoginScreen()),
      GoRoute(
        path: AppRoutes.otpVerify,
        builder: (_, state) => OtpVerifyScreen(phone: state.extra as String),
      ),

      // ── Admin routes (no bottom nav) ─────────────────────────────────
      GoRoute(path: AppRoutes.adminLogin, builder: (_, __) => const AdminLoginScreen()),
      GoRoute(path: AppRoutes.adminDashboard, builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(path: AppRoutes.addProduct, builder: (_, state) => AddProductScreen(product: state.extra)),
      GoRoute(path: AppRoutes.manageProducts, builder: (_, __) => const ManageProductsScreen()),
      GoRoute(path: AppRoutes.orderManagement, builder: (_, __) => const OrderManagementScreen()),

      // ── Customer routes with bottom nav ──────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
          GoRoute(path: AppRoutes.search, builder: (_, __) => const SearchScreen()),
          GoRoute(path: AppRoutes.cart, builder: (_, __) => const CartScreen()),
          GoRoute(path: AppRoutes.wishlist, builder: (_, __) => const WishlistScreen()),
          GoRoute(path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ── Standalone customer screens ───────────────────────────────────
      GoRoute(
        path: AppRoutes.productList,
        builder: (_, state) => ProductListScreen(category: state.extra as String?),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        builder: (_, state) => ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.checkout, builder: (_, __) => const CheckoutScreen()),
      GoRoute(
        path: AppRoutes.payment,
        builder: (_, state) => PaymentScreen(extra: state.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: AppRoutes.orderConfirmation,
        builder: (_, state) => OrderConfirmationScreen(orderId: state.extra as String),
      ),
      GoRoute(path: AppRoutes.myOrders, builder: (_, __) => const MyOrdersScreen()),
      GoRoute(
        path: AppRoutes.orderDetail,
        builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
    ],
  );
});


