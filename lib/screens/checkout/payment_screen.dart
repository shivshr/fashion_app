import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/core/constants/app_routes.dart';
import 'package:fashion_app/core/utils/extensions.dart';
import 'package:fashion_app/models/order_model.dart';
import 'package:fashion_app/models/user_model.dart';
import 'package:fashion_app/providers/auth_provider.dart';
import 'package:fashion_app/providers/cart_provider.dart';
import 'package:fashion_app/providers/order_provider.dart';
import 'package:fashion_app/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> extra;
  const PaymentScreen({required this.extra, super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late final PaymentService _paymentService;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    _paymentService.initialize(
      onSuccess: _onPaymentSuccess,
      onError: _onPaymentError,
    );
  }

  Future<void> _onPaymentSuccess(String paymentId, String orderId, String signature) async {
    setState(() => _processing = true);
    try {
      final user = ref.read(authStateProvider).value!;
      final userProfile = await ref.read(authServiceProvider).getUserProfile(user.uid);
      final items = ref.read(cartProvider);
      final address = widget.extra['address'] as AddressModel;
      final total = ref.read(cartTotalProvider);
      final subtotal = ref.read(cartSubtotalProvider);
      final shipping = ref.read(cartShippingFeeProvider);

      final order = OrderModel(
        orderId: '',
        userId: user.uid,
        userPhone: user.phoneNumber ?? '',
        userName: widget.extra['name'] ?? userProfile?.name ?? '',
        items: items,
        shippingAddress: address,
        subtotal: subtotal,
        shippingFee: shipping,
        totalPrice: total,
        paymentId: paymentId,
        paymentStatus: 'paid',
        orderStatus: 'pending',
      );

      final createdOrderId = await ref.read(orderServiceProvider).createOrder(order);
      ref.read(cartProvider.notifier).clearCart();

      if (mounted) context.go(AppRoutes.orderConfirmation, extra: createdOrderId);
    } catch (e) {
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order creation failed: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _onPaymentError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: $message'), backgroundColor: AppColors.error),
    );
  }

  void _openRazorpay() {
    final user = ref.read(authStateProvider).value;
    final total = ref.read(cartTotalProvider);
    _paymentService.openCheckout(
      amount: total,
      phone: user?.phoneNumber ?? '',
      name: widget.extra['name'] ?? '',
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(cartTotalProvider);
    final items = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: _processing
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing your order...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        ...items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(child: Text('${item.name} × ${item.quantity}')),
                                  Text(item.subtotal.inr, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            )),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            Text(total.inr,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Powered by', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.security, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text('Secure payment via Razorpay',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _openRazorpay,
                    icon: const Icon(Icons.payment),
                    label: Text('Pay ${total.inr}'),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text('UPI • Cards • Net Banking • Wallets',
                        style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
