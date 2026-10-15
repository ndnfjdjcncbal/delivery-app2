import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/driver_location.dart';
import '../repositories/tracking_repository.dart';

class SendLocation {
  final TrackingRepository repository;

  const SendLocation(this.repository);

  Future<Either<Failure, Unit>> call({
    required String orderId,
    required DriverLocation location,
    required String status,
  }) {
    return repository.sendLocation(
      orderId: orderId,
      location: location,
      status: status,
    );
  }
}
