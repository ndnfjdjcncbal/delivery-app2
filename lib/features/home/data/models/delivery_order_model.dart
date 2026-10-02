import 'package:delivert_app2/features/home/domain/entities/delivery_order.dart';

class DeliveryOrderModel extends DeliveryOrder {
  const DeliveryOrderModel({
    required super.id,
    required super.customerName,
    required super.address,
    required super.total,
    required super.status,
    required super.type,
    super.deliveryUserId,
  });

  @override
  DeliveryOrderModel copyWith({
    String? id,
    String? customerName,
    String? address,
    String? total,
    int? status,
    String? type,
    String? deliveryUserId,
    String? note,
  }) {
    return DeliveryOrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
      total: total ?? this.total,
      status: status ?? this.status,
      type: type ?? this.type,
      deliveryUserId: deliveryUserId ?? this.deliveryUserId,
    );
  }

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    String valueOf(List<String> keys, [Map<String, dynamic>? source]) {
      final map = source ?? json;
      for (final key in keys) {
        final value = map[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      return '';
    }

    final customerMap = json['customer'] is Map<String, dynamic>
        ? json['customer'] as Map<String, dynamic>
        : (json['customer'] is Map
              ? Map<String, dynamic>.from(json['customer'] as Map)
              : null);

    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : (json['user'] is Map
              ? Map<String, dynamic>.from(json['user'] as Map)
              : null);

    final customerName = valueOf([
      'customer_name',
      'customerName',
      'user_name',
      'userName',
      'name',
      'full_name',
      'fullName',
    ], customerMap ?? userMap ?? json);

    final address = valueOf([
      'address',
      'delivery_address',
      'deliveryAddress',
      'order_address',
      'location',
    ]);

    final total = valueOf([
      'total',
      'total_price',
      'totalPrice',
      'amount',
      'price',
    ]);

    final statusValue = json['order_status'] ?? json['status'] ?? 0;
    final status = int.tryParse(statusValue.toString()) ?? 0;

    return DeliveryOrderModel(
      id: valueOf(['orders_id', 'order_id', 'id', 'ordersId']),
      customerName: customerName.isNotEmpty ? customerName : 'Customer',
      address: address.isNotEmpty ? address : 'Address not provided',
      total: total.isNotEmpty ? total : '0',
      status: status,
      type: valueOf(['order_type', 'type', 'delivery_type'], json),
      deliveryUserId: valueOf([
        'delivery_userid',
        'deliveryUserId',
        'delivery_user_id',
      ], json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders_id': id,
      'customer_name': customerName,
      'address': address,
      'total': total,
      'order_status': status,
      'order_type': type,
      'delivery_userid': deliveryUserId,
    };
  }
}
