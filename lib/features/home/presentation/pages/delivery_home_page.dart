import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_color/Colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../auth/domain/entiti/entity_login.dart';
import '../../../auth/domain/repo/auth_repo.dart';
import '../../domain/entities/delivery_order.dart';
import '../../domain/repositories/order_repository.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class DeliveryHomePage extends StatelessWidget {
  const DeliveryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => HomeCubit(sl<AuthRepository>())..loadUser(),
      child: const _DeliveryHomeView(),
    );
  }
}

class _DeliveryHomeView extends StatefulWidget {
  const _DeliveryHomeView();

  @override
  State<_DeliveryHomeView> createState() => _DeliveryHomeViewState();
}

class _DeliveryHomeViewState extends State<_DeliveryHomeView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: Color.fromARGB(255, 0, 0, 224),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocProvider<OrdersCubit>(
          create: (_) =>
              OrdersCubit(repository: sl<OrderRepository>())..loadOrders(),
          child: Scaffold(
            backgroundColor: AppColors.backgroundGrey,
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                const OrdersTabView(),
                ProfileTabView(user: state.user!),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                elevation: 0,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.grey,
                backgroundColor: AppColors.white,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.assignment_rounded),
                    label: 'Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class OrdersTabView extends StatelessWidget {
  const OrdersTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<OrdersCubit, OrdersState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.successMessage!)));
          }
        },
        builder: (context, state) {
          if (state.isLoading &&
              state.availableOrders.isEmpty &&
              state.myOrders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Delivery Orders',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            context.read<OrdersCubit>().loadOrders(),
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const TabBar(
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.grey,
                  tabs: [
                    Tab(text: 'Available'),
                    Tab(text: 'My Orders'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _AvailableOrdersList(
                        orders: state.availableOrders,
                        isTakingOrder: state.isTakingOrder,
                        actionOrderId: state.actionOrderId,
                      ),
                      _MyOrdersList(
                        orders: state.myOrders,
                        isDeliveringOrder: state.isDeliveringOrder,
                        actionOrderId: state.actionOrderId,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AvailableOrdersList extends StatelessWidget {
  final List<DeliveryOrder> orders;
  final bool isTakingOrder;
  final String? actionOrderId;

  const _AvailableOrdersList({
    required this.orders,
    required this.isTakingOrder,
    this.actionOrderId,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('No available orders right now'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE6E2FF), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPale,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.customerName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPale,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Available',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _InfoRow(icon: Icons.location_on_rounded, text: order.address),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.attach_money_rounded,
                text: ' a3${order.total}',
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isTakingOrder && actionOrderId == order.id
                      ? null
                      : () async {
                          final orderId = order.id.trim();
                          debugPrint(
                            '[ORDER_DEBUG] Take order tapped; order.id="${order.id}", sending="$orderId"',
                          );
                          if (orderId.isEmpty) {
                            debugPrint(
                              '[ORDER_DEBUG] Stop: order ID is empty.',
                            );
                            return;
                          }

                          final accepted = await context
                              .read<OrdersCubit>()
                              .takeOrder(orderId);
                          debugPrint(
                            '[ORDER_DEBUG] Take order result; orderId="$orderId", accepted=$accepted',
                          );
                          if (!accepted || !context.mounted) {
                            return;
                          }

                          debugPrint(
                            '[ORDER_DEBUG] Opening map with arguments: {orderId: "$orderId"}',
                          );
                          Navigator.of(context).pushNamed(
                            AppRoutes.viewMap,
                            arguments: {'orderId': orderId},
                          );
                        },
                  icon: isTakingOrder && actionOrderId == order.id
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Icons.assignment_turned_in_rounded),
                  label: Text(
                    isTakingOrder && actionOrderId == order.id
                        ? 'Accepting...'
                        : 'Take Order',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size.fromHeight(50),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MyOrdersList extends StatelessWidget {
  final List<DeliveryOrder> orders;
  final bool isDeliveringOrder;
  final String? actionOrderId;

  const _MyOrdersList({
    required this.orders,
    required this.isDeliveringOrder,
    this.actionOrderId,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders assigned yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isDelivered = order.status == 4;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE6E2FF), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDelivered
                          ? AppColors.newBadge.withValues(alpha: 0.12)
                          : AppColors.primaryPale,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isDelivered ? 'Delivered' : 'In Delivery',
                      style: TextStyle(
                        color: isDelivered
                            ? AppColors.newBadge
                            : AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.person_rounded, text: order.customerName),
              const SizedBox(height: 8),
              _InfoRow(icon: Icons.location_on_rounded, text: order.address),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.attach_money_rounded,
                text: '£${order.total}',
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final orderId = order.id.trim();
                    if (orderId.isEmpty) {
                      return;
                    }
                    Navigator.of(context).pushNamed(
                      AppRoutes.viewMap,
                      arguments: {'orderId': orderId},
                    );
                  },
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('View Customer Address'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              if (!isDelivered) const SizedBox(height: 10),
              if (!isDelivered)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isDeliveringOrder && actionOrderId == order.id
                        ? null
                        : () => context.read<OrdersCubit>().deliverOrder(
                            order.id,
                          ),
                    icon: isDeliveringOrder && actionOrderId == order.id
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_rounded),
                    label: Text(
                      isDeliveringOrder && actionOrderId == order.id
                          ? 'Delivering...'
                          : 'Deliver Order',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.newBadge,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.grey, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class ProfileTabView extends StatelessWidget {
  final User? user;

  const ProfileTabView({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.primaryPale,
              child: const Icon(
                Icons.person_rounded,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              user?.name ?? 'Delivery User',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'No email found',
              style: const TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              user?.phone ?? 'No phone',
              style: const TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await context.read<HomeCubit>().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
