import 'package:equatable/equatable.dart';

import '../../domain/entities/delivery_order.dart';

class OrdersState extends Equatable {
  final bool isLoading;
  final bool isTakingOrder;
  final bool isDeliveringOrder;
  final String? actionOrderId;
  final List<DeliveryOrder> availableOrders;
  final List<DeliveryOrder> myOrders;
  final String? errorMessage;
  final String? successMessage;

  const OrdersState({
    this.isLoading = false,
    this.isTakingOrder = false,
    this.isDeliveringOrder = false,
    this.actionOrderId,
    this.availableOrders = const [],
    this.myOrders = const [],
    this.errorMessage,
    this.successMessage,
  });

  OrdersState copyWith({
    bool? isLoading,
    bool? isTakingOrder,
    bool? isDeliveringOrder,
    String? actionOrderId,
    List<DeliveryOrder>? availableOrders,
    List<DeliveryOrder>? myOrders,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      isTakingOrder: isTakingOrder ?? this.isTakingOrder,
      isDeliveringOrder: isDeliveringOrder ?? this.isDeliveringOrder,
      actionOrderId: actionOrderId ?? this.actionOrderId,
      availableOrders: availableOrders ?? this.availableOrders,
      myOrders: myOrders ?? this.myOrders,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isTakingOrder,
    isDeliveringOrder,
    actionOrderId,
    availableOrders,
    myOrders,
    errorMessage,
    successMessage,
  ];
}
