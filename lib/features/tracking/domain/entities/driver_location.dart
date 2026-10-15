import 'package:equatable/equatable.dart';

class DriverLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double heading;

  const DriverLocation({
    required this.latitude,
    required this.longitude,
    this.heading = 0,
  });

  @override
  List<Object?> get props => [latitude, longitude, heading];
}
