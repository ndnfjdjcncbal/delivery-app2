import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/delivery_order_model.dart';
import '../../data/models/customer_address_model.dart';
import '../../domain/entities/customer_address.dart';
import '../../domain/entities/delivery_order.dart';
import '../../domain/repositories/order_repository.dart';
import '../remote_data_source/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<DeliveryOrder>>> getAvailableOrders() async {
    try {
      final response = await remoteDataSource.getAvailableOrders();
      final items = _extractOrders(response.data);
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerAddress>> getCustomerAddress(
    String orderId,
  ) async {
    try {
      final response = await remoteDataSource.getCustomerAddress(orderId);
      final payload = response.data;
      final data = payload is Map ? payload['data'] : null;
      Map<String, dynamic>? addressJson;

      if (data is List && data.isNotEmpty && data.first is Map) {
        addressJson = Map<String, dynamic>.from(data.first as Map);
      } else if (data is Map) {
        addressJson = Map<String, dynamic>.from(data);
      }

      if (addressJson == null) {
        return Left(ServerFailure('Customer address was not found.'));
      }

      final model = CustomerAddressModel.fromJson(addressJson);
      return Right(_toCustomerAddress(model));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (_) {
      return Left(ServerFailure('Could not read the customer address.'));
    }
  }

  @override
  Future<Either<Failure, List<DeliveryOrder>>> getMyOrders(
    String deliveryUserId,
  ) async {
    try {
      final response = await remoteDataSource.getMyOrders(deliveryUserId);
      final items = _extractOrders(response.data);
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeliveryOrder>> takeOrder({
    required String deliveryUserId,
    required String orderId,
  }) async {
    try {
      final response = await remoteDataSource.takeOrder(
        deliveryUserId: deliveryUserId,
        orderId: orderId,
      );

      final order = _extractOrder(response.data, defaultStatus: 3);
      print(deliveryUserId);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeliveryOrder>> deliverOrder({
    required String deliveryUserId,
    required String orderId,
  }) async {
    try {
      final response = await remoteDataSource.deliverOrder(
        deliveryUserId: deliveryUserId,
        orderId: orderId,
      );

      final order = _extractOrder(response.data, defaultStatus: 4);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  List<DeliveryOrder> _extractOrders(dynamic payload) {
    final data = payload is Map ? payload['data'] : payload;
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => _toEntity(
              DeliveryOrderModel.fromJson(Map<String, dynamic>.from(item)),
            ),
          )
          .toList();
    }

    if (data is Map) {
      final items = data['data'] ?? data['result'] ?? data['items'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map(
              (item) => _toEntity(
                DeliveryOrderModel.fromJson(Map<String, dynamic>.from(item)),
              ),
            )
            .toList();
      }
    }

    return [];
  }

  DeliveryOrder _extractOrder(dynamic payload, {required int defaultStatus}) {
    final data = payload is Map ? payload['data'] : payload;
    if (data is Map) {
      final item = Map<String, dynamic>.from(data);
      final model = DeliveryOrderModel.fromJson(item);
      final order = _toEntity(model);
      final hasStatus =
          item.containsKey('order_status') || item.containsKey('status');
      return hasStatus ? order : order.copyWith(status: defaultStatus);
    }

    return const DeliveryOrder(
      id: '',
      customerName: 'Customer',
      address: 'Address not provided',
      total: '0',
      status: 0,
      type: 'delivery',
    );
  }

  DeliveryOrder _toEntity(DeliveryOrderModel model) {
    return DeliveryOrder(
      id: model.id,
      customerName: model.customerName,
      address: model.address,
      total: model.total,
      status: model.status,
      type: model.type,
      deliveryUserId: model.deliveryUserId,
    );
  }

  CustomerAddress _toCustomerAddress(CustomerAddressModel model) {
    return CustomerAddress(
      address: model.address,
      latitude: model.latitude,
      longitude: model.longitude,
    );
  }
}
