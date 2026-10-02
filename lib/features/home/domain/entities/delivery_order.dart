import 'package:equatable/equatable.dart';

class DeliveryOrder extends Equatable {
  final String id;
  final String customerName;
  final String address;
  final String total;
  final int status;
  final String type;
  final String? deliveryUserId;

  const DeliveryOrder({
    required this.id,
    required this.customerName,
    required this.address,
    required this.total,
    required this.status,
    required this.type,
    this.deliveryUserId,
  });

  DeliveryOrder copyWith({
    String? id,
    String? customerName,
    String? address,
    String? total,
    int? status,
    String? type,
    String? deliveryUserId,
    String? note,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
      total: total ?? this.total,
      status: status ?? this.status,
      type: type ?? this.type,
      deliveryUserId: deliveryUserId ?? this.deliveryUserId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerName,
    address,
    total,
    status,
    type,
    deliveryUserId,
  ];
}
