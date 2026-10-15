import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/driver_location.dart';
import '../repositories/tracking_repository.dart';

class StopTracking {
  final TrackingRepository repository;

  const StopTracking(this.repository);

  Future<Either<Failure, DriverLocation>> call({
    DriverLocation? lastKnownPosition,
  }) {
    return repository.stopTracking(lastKnownPosition: lastKnownPosition);
  }
}
