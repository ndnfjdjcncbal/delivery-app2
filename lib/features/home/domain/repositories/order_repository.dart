import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/customer_address.dart';
import '../entities/delivery_order.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<DeliveryOrder>>> getAvailableOrders();
  Future<Either<Failure, CustomerAddress>> getCustomerAddress(String orderId);
  Future<Either<Failure, List<DeliveryOrder>>> getMyOrders(
    String deliveryUserId,
  );
  Future<Either<Failure, DeliveryOrder>> takeOrder({
    required String deliveryUserId,
    required String orderId,
  });
  Future<Either<Failure, DeliveryOrder>> deliverOrder({
    required String deliveryUserId,
    required String orderId,
  });
}
