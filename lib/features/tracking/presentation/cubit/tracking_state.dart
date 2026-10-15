import 'package:equatable/equatable.dart';

import '../../domain/entities/driver_location.dart';

abstract class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

class TrackingInitial extends TrackingState {
  const TrackingInitial();
}

class TrackingStarting extends TrackingState {
  final String orderId;

  const TrackingStarting(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class TrackingActive extends TrackingState {
  final String orderId;
  final DriverLocation? lastLocation;

  const TrackingActive({required this.orderId, this.lastLocation});

  @override
  List<Object?> get props => [orderId, lastLocation];
}

class TrackingStopped extends TrackingState {
  const TrackingStopped();
}

class TrackingFailure extends TrackingState {
  final String message;

  const TrackingFailure(this.message);

  @override
  List<Object?> get props => [message];
}
