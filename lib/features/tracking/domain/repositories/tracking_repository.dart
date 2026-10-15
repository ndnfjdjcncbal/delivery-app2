import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/driver_location.dart';

abstract class TrackingRepository {
  Future<Either<Failure, Stream<DriverLocation>>> startTracking();

  Future<Either<Failure, Unit>> sendLocation({
    required String orderId,
    required DriverLocation location,
    required String status,
  });

  Future<Either<Failure, DriverLocation>> stopTracking({
    DriverLocation? lastKnownPosition,
  });
}
