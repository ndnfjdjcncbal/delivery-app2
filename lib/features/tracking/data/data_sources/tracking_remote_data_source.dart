import 'package:dio/dio.dart';

import '../../../../core/constants/api_client/link_api.dart';
import '../../../../core/network/api_consumer.dart';
import '../../domain/entities/driver_location.dart';

class TrackingRemoteDataSource {
  final ApiConsumer apiConsumer;

  TrackingRemoteDataSource(this.apiConsumer);

  Future<void> sendLocation({
    required String orderId,
    required DriverLocation location,
    required String status,
  }) async {
    await apiConsumer.post(
      ApiConstants.updateordertraking,
      data: {
        'order_id': orderId,
        'lat': location.latitude,
        'lng': location.longitude,
        'heading': location.heading,
        'status': status,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
  }
}
