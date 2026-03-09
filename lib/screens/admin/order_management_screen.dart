import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/core/utils/extensions.dart';
import 'package:fashion_app/providers/order_provider.dart';
import 'package:fashion_app/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends ConsumerState<OrderManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = [null, 'pending', 'processing', 'shipped', 'delivered', 'cancelled'];
  final _tabLabels = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((status) => _OrderList(status: status)).toList(),
      ),
    );
  }
}

class _OrderList extends ConsumerWidget {
  final String? status;
  const _OrderList({this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider(status));

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Center(child: Text('No orders'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (_, i) {
            final o = orders[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showUpdateDialog(context, ref, o.orderId, o.orderStatus),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('#${o.orderId.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          _StatusBadge(o.orderStatus),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('📞 ${o.userPhone}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text('👤 ${o.userName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text('${o.items.length} item(s)', style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(o.createdAt?.dateOnly ?? '', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: o.paymentStatus == 'paid' ? AppColors.inStockBg : AppColors.lowStockBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(o.paymentStatus.capitalize,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: o.paymentStatus == 'paid' ? AppColors.success : AppColors.warning,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 8),
                              Text(o.totalPrice.inr,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  void _showUpdateDialog(BuildContext context, WidgetRef ref, String orderId, String currentStatus) {
    final statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update Order Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...statuses.map((s) => ListTile(
                  leading: Icon(s.statusIcon, color: s == currentStatus ? AppColors.primary : AppColors.textHint),
                  title: Text(s.capitalize, style: TextStyle(fontWeight: s == currentStatus ? FontWeight.w700 : FontWeight.normal)),
                  trailing: s == currentStatus ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: s == currentStatus
                      ? null
                      : () async {
                          Navigator.pop(context);
                          await OrderService().updateOrderStatus(orderId, s);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Status updated to ${s.capitalize}'), backgroundColor: AppColors.success),
                          );
                        },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.statusColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.statusIcon, size: 12, color: status.statusColor),
          const SizedBox(width: 4),
          Text(status.capitalize, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: status.statusColor)),
        ],
      ),
    );
  }
}
