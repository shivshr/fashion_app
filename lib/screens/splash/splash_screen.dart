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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.elasticOut),
      ),
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

      /// LIGHT GREEN BACKGROUND
      backgroundColor: const Color(0xFFE6F7ED),

      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,

          child: ScaleTransition(
            scale: _scaleAnim,

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                /// BALAJI LOGO
                Image.asset(
                  "assets/images/logo_transparent.png",
                  height: 500,
                ),

                const SizedBox(height: 30),

                /// LOADING
                const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation(Color(0xFF0F6C5C)),
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}