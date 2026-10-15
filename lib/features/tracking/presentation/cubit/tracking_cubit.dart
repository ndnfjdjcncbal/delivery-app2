import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/driver_location.dart';
import '../../domain/use_cases/send_location.dart';
import '../../domain/use_cases/start_tracking.dart';
import '../../domain/use_cases/stop_tracking.dart';
import 'tracking_state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  final StartTracking startTrackingUseCase;
  final SendLocation sendLocationUseCase;
  final StopTracking stopTrackingUseCase;

  StreamSubscription<DriverLocation>? _positionSubscription;
  Future<Either<Failure, Unit>>? _inFlightSend;
  DriverLocation? _lastLocation;
  String? _activeOrderId;

  TrackingCubit({
    required this.startTrackingUseCase,
    required this.sendLocationUseCase,
    required this.stopTrackingUseCase,
  }) : super(const TrackingInitial());

  Future<void> start(String orderId) async {
    final normalizedOrderId = orderId.trim();
    if (isClosed || normalizedOrderId.isEmpty) return;
    if (state is TrackingStarting) return;
    if (state is TrackingActive) {
      if (_activeOrderId == normalizedOrderId) return;
      emit(
        const TrackingFailure(
          'تتم مشاركة موقع طلب آخر حاليًا. أوقف المشاركة بإتمام ذلك الطلب أولًا.',
        ),
      );
      return;
    }

    emit(TrackingStarting(normalizedOrderId));
    final result = await startTrackingUseCase();
    if (isClosed) return;

    result.fold((failure) => emit(TrackingFailure(failure.message)), (
      positions,
    ) {
      _activeOrderId = normalizedOrderId;
      _lastLocation = null;
      _positionSubscription = positions.listen(
        (location) {
          _lastLocation = location;
          if (!isClosed && _activeOrderId == normalizedOrderId) {
            emit(
              TrackingActive(
                orderId: normalizedOrderId,
                lastLocation: location,
              ),
            );
            unawaited(_sendUpdate(normalizedOrderId, location, 'on_the_way'));
          }
        },
        onError: (Object error) {
          if (isClosed || _activeOrderId != normalizedOrderId) return;
          unawaited(_handleStreamError(error));
        },
        onDone: () {
          if (!isClosed && _activeOrderId == normalizedOrderId) {
            _activeOrderId = null;
            _positionSubscription = null;
            emit(const TrackingStopped());
          }
        },
      );
      emit(TrackingActive(orderId: normalizedOrderId));
    });
  }

  Future<bool> stopAndSendDelivered(String orderId) async {
    final normalizedOrderId = orderId.trim();
    if (isClosed || normalizedOrderId.isEmpty) return false;
    if (_activeOrderId != null && _activeOrderId != normalizedOrderId) {
      emit(
        const TrackingFailure(
          'أوقف مشاركة موقع الطلب الحالي قبل إتمام طلب آخر.',
        ),
      );
      return false;
    }

    await _positionSubscription?.cancel();
    _positionSubscription = null;
    final pendingSend = _inFlightSend;
    if (pendingSend != null) await pendingSend;

    final lastPositionResult = await stopTrackingUseCase(
      lastKnownPosition: _lastLocation,
    );
    if (isClosed) return false;

    final lastPosition = lastPositionResult.fold<DriverLocation?>((failure) {
      emit(TrackingFailure(failure.message));
      return null;
    }, (location) => location);
    if (lastPosition == null) return false;

    final sendResult = await sendLocationUseCase(
      orderId: normalizedOrderId,
      location: lastPosition,
      status: 'delivered',
    );
    if (isClosed) return false;

    final canCompleteOrder = sendResult.fold<bool>(
      (failure) => failure is NetworkFailure,
      (_) => true,
    );
    if (!canCompleteOrder) {
      _activeOrderId = null;
      sendResult.fold(
        (failure) => emit(TrackingFailure(failure.message)),
        (_) {},
      );
      return false;
    }

    _activeOrderId = null;
    _lastLocation = null;
    emit(const TrackingStopped());
    return true;
  }

  Future<void> _sendUpdate(
    String orderId,
    DriverLocation location,
    String status,
  ) async {
    if (_inFlightSend != null) return;
    final request = sendLocationUseCase(
      orderId: orderId,
      location: location,
      status: status,
    );
    _inFlightSend = request;
    final result = await request;
    _inFlightSend = null;
    if (isClosed || _activeOrderId != orderId) return;

    result.fold((failure) {
      if (failure is NetworkFailure) return;
      emit(TrackingFailure(failure.message));
      unawaited(_positionSubscription?.cancel());
      _positionSubscription = null;
      _activeOrderId = null;
    }, (_) {});
  }

  Future<void> _handleStreamError(Object error) async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _activeOrderId = null;
    emit(
      TrackingFailure(
        error is Exception
            ? 'توقفت مشاركة الموقع. تحقق من أذونات الموقع وخدمة GPS.'
            : 'حدث خطأ أثناء قراءة الموقع.',
      ),
    );
  }

  @override
  Future<void> close() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    final pendingSend = _inFlightSend;
    if (pendingSend != null) await pendingSend;
    await super.close();
  }
}
