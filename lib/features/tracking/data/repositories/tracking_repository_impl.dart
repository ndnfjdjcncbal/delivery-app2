import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/driver_location.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../data_sources/location_data_source.dart';
import '../data_sources/tracking_remote_data_source.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final LocationDataSource locationDataSource;
  final TrackingRemoteDataSource remoteDataSource;

  TrackingRepositoryImpl(this.locationDataSource, this.remoteDataSource);

  @override
  Future<Either<Failure, Stream<DriverLocation>>> startTracking() async {
    try {
      return Right(await locationDataSource.startTracking());
    } on LocationTrackingException catch (error) {
      return Left(ServerFailure(error.message));
    } on NetworkException catch (error) {
      return Left(NetworkFailure(error.message));
    } catch (_) {
      return Left(
        ServerFailure('تعذر بدء مشاركة الموقع. تحقق من إعدادات الموقع.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> sendLocation({
    required String orderId,
    required DriverLocation location,
    required String status,
  }) async {
    try {
      await remoteDataSource.sendLocation(
        orderId: orderId,
        location: location,
        status: status,
      );
      return const Right(unit);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } on NetworkException catch (error) {
      return Left(NetworkFailure(error.message));
    } catch (_) {
      return Left(ServerFailure('تعذر إرسال الموقع إلى الخادم.'));
    }
  }

  @override
  Future<Either<Failure, DriverLocation>> stopTracking({
    DriverLocation? lastKnownPosition,
  }) async {
    if (lastKnownPosition != null) return Right(lastKnownPosition);
    try {
      final position = await locationDataSource.getLastKnownPosition();
      if (position == null) {
        return Left(
          ServerFailure(
            'تعذر الحصول على آخر موقع معروف. تحقق من GPS ثم حاول مجددًا.',
          ),
        );
      }
      return Right(position);
    } on LocationTrackingException catch (error) {
      return Left(ServerFailure(error.message));
    } on NetworkException catch (error) {
      return Left(NetworkFailure(error.message));
    } catch (_) {
      return Left(
        ServerFailure('تعذر الحصول على آخر موقع معروف لإتمام التوصيل.'),
      );
    }
  }
}
