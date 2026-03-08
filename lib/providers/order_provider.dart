import 'package:fashion_app/models/order_model.dart';
import 'package:fashion_app/providers/auth_provider.dart';
import 'package:fashion_app/services/order_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

final userOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(orderServiceProvider).streamUserOrders(user.uid);
});

final allOrdersProvider = StreamProvider.family<List<OrderModel>, String?>((ref, status) {
  return ref.watch(orderServiceProvider).streamAllOrders(status: status);
});

final singleOrderProvider = FutureProvider.family<OrderModel?, String>((ref, orderId) {
  return ref.watch(orderServiceProvider).getOrder(orderId);
});

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(orderServiceProvider).getAdminStats();
});
