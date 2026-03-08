import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/core/constants/app_routes.dart';
import 'package:fashion_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeIn)),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.elasticOut)),
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
  if (mounted) {
    _navigate();
  }
});
  }

  void _navigate() {
  if (!mounted) return;

  final authState = ref.read(authStateProvider);

  if (authState.value != null) {
    context.go(AppRoutes.home);
  } else {
    context.go(AppRoutes.phoneLogin);
  }
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, size: 56, color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                const Text('FashionApp',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Style at your doorstep',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 60),
                const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white30), strokeWidth: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
