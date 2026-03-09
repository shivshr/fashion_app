import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/core/constants/app_routes.dart';
import 'package:fashion_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final authUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              ),
              child: Column(
                children: [
                  const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person_rounded, size: 48, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  userAsync.when(
                    data: (u) => Column(
                      children: [
                        Text(u?.name ?? 'User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(authUser?.phoneNumber ?? '', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(color: Colors.white),
                    error: (_, __) => const Text('Error loading profile', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Menu items
            _MenuItem(icon: Icons.shopping_bag_outlined, label: 'My Orders', onTap: () => context.push(AppRoutes.myOrders)),
            _MenuItem(icon: Icons.favorite_outline, label: 'Wishlist', onTap: () => context.push(AppRoutes.wishlist)),
            _MenuItem(icon: Icons.location_on_outlined, label: 'Delivery Addresses', onTap: () {}),
            _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
            _MenuItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
            const Divider(height: 1),
            _MenuItem(
              icon: Icons.logout,
              label: 'Sign Out',
              color: AppColors.error,
              onTap: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) context.go(AppRoutes.phoneLogin);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Consumer(
        builder: (_, ref, __) {
          final mode = ref.watch(themeModeProvider);
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: mode == ThemeMode.dark,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) {
                    ref.read(themeModeProvider.notifier).state = v ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.adminLogin);
                  },
                  child: const Text('Admin Portal'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: color ?? AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
