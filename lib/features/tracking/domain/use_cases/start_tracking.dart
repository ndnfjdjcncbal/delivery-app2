import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/driver_location.dart';
import '../repositories/tracking_repository.dart';

class StartTracking {
  final TrackingRepository repository;

  const StartTracking(this.repository);

  Future<Either<Failure, Stream<DriverLocation>>> call() {
    return repository.startTracking();
  }
}
