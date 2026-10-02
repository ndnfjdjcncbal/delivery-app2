import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryLocationState extends Equatable {
  final bool isLoading;
  final Position? position;
  final String? errorMessage;
  final bool locationServiceDisabled;
  final bool permissionPermanentlyDenied;

  const DeliveryLocationState({
    this.isLoading = false,
    this.position,
    this.errorMessage,
    this.locationServiceDisabled = false,
    this.permissionPermanentlyDenied = false,
  });

  DeliveryLocationState copyWith({
    bool? isLoading,
    Position? position,
    String? errorMessage,
    bool? locationServiceDisabled,
    bool? permissionPermanentlyDenied,
    bool clearErrorMessage = false,
  }) {
    return DeliveryLocationState(
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      locationServiceDisabled:
          locationServiceDisabled ?? this.locationServiceDisabled,
      permissionPermanentlyDenied:
          permissionPermanentlyDenied ?? this.permissionPermanentlyDenied,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    position,
    errorMessage,
    locationServiceDisabled,
    permissionPermanentlyDenied,
  ];
}
