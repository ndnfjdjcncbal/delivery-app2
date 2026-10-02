import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'delivery_location_state.dart';

class DeliveryLocationCubit extends Cubit<DeliveryLocationState> {
  StreamSubscription<Position>? _positionSubscription;
  bool _isStarting = false;

  DeliveryLocationCubit() : super(const DeliveryLocationState());

  Future<void> startTracking() async {
    if (_isStarting || _positionSubscription != null || isClosed) return;

    _isStarting = true;
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Turn on GPS to track your live location.',
            locationServiceDisabled: true,
            permissionPermanentlyDenied: false,
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Location permission is permanently denied. Enable it in app settings.',
            locationServiceDisabled: false,
            permissionPermanentlyDenied: true,
          ),
        );
        return;
      }

      if (permission == LocationPermission.denied) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage:
                'Allow location permission to track your live location.',
            locationServiceDisabled: false,
            permissionPermanentlyDenied: false,
          ),
        );
        return;
      }

      final initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          position: initialPosition,
          clearErrorMessage: true,
          locationServiceDisabled: false,
          permissionPermanentlyDenied: false,
        ),
      );

      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen(
            (position) {
              if (!isClosed) {
                emit(
                  state.copyWith(
                    position: position,
                    clearErrorMessage: true,
                    locationServiceDisabled: false,
                    permissionPermanentlyDenied: false,
                  ),
                );
              }
            },
            onError: (Object error) {
              if (isClosed) return;
              final serviceDisabled = error is LocationServiceDisabledException;
              emit(
                state.copyWith(
                  isLoading: false,
                  errorMessage: serviceDisabled
                      ? 'GPS was turned off. Turn it on to resume live tracking.'
                      : 'Live location tracking stopped. Check your location settings and retry.',
                  locationServiceDisabled: serviceDisabled,
                ),
              );
              unawaited(_positionSubscription?.cancel());
              _positionSubscription = null;
            },
          );
    } on LocationServiceDisabledException {
      _emitTrackingError(
        'Turn on GPS to track your live location.',
        locationServiceDisabled: true,
      );
    } on PermissionDeniedException {
      _emitTrackingError(
        'Allow location permission to track your live location.',
      );
    } on TimeoutException {
      _emitTrackingError(
        'Could not get your location. Check GPS reception and retry.',
      );
    } catch (_) {
      _emitTrackingError(
        'Could not start live location tracking. Check GPS and permission settings.',
      );
    } finally {
      _isStarting = false;
    }
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  void _emitTrackingError(
    String message, {
    bool locationServiceDisabled = false,
  }) {
    if (isClosed) return;
    emit(
      state.copyWith(
        isLoading: false,
        errorMessage: message,
        locationServiceDisabled: locationServiceDisabled,
        permissionPermanentlyDenied: false,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    await super.close();
  }
}
