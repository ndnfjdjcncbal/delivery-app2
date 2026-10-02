import 'package:dio/dio.dart';

import '../../../../core/constants/api_client/link_api.dart';
import '../../../../core/network/api_consumer.dart';

class OrderRemoteDataSource {
  final ApiConsumer apiConsumer;

  OrderRemoteDataSource(this.apiConsumer);

  Future<Response> getAvailableOrders() {
    return apiConsumer.get(ApiConstants.getavailableorders);
  }

  Future<Response> getMyOrders(String deliveryUserId) {
    return apiConsumer.get(
      ApiConstants.getmyorders,
      queryParameters: {'delivery_userid': deliveryUserId},
    );
  }

  Future<Response> getCustomerAddress(String orderId) {
    return apiConsumer.post(
      ApiConstants.getorderaddress,
      data: FormData.fromMap({'orders_id': orderId}),
    );
  }

  Future<Response> takeOrder({
    required String deliveryUserId,
    required String orderId,
  }) {
    return apiConsumer.post(
      ApiConstants.updateorderstatus,
      data: FormData.fromMap({
        'delivery_userid': deliveryUserId,
        'orders_id': orderId,
        'new_status': 3,
      }),
    );
  }

  Future<Response> deliverOrder({
    required String deliveryUserId,
    required String orderId,
  }) {
    return apiConsumer.post(
      ApiConstants.deliverorder,
      data: FormData.fromMap({
        'delivery_userid': deliveryUserId,
        'orders_id': orderId,
      }),
    );
  }
}
