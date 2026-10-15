import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/Repositories/auth_repository_impl.dart';
import '../../features/auth/data/local_data_source/auth_local_data_source.dart';
import '../../features/auth/data/remote_data_source/auth_remot_data_source.dart';
import '../../features/auth/domain/repo/auth_repo.dart';
import '../../features/auth/domain/use_cases/login_usecase.dart';
import '../../features/auth/domain/use_cases/register_usecase.dart';
import '../../features/auth/domain/use_cases/verify_signup_code_usecase.dart';
import '../../features/auth/domain/use_cases/request_password_reset_code_usecase.dart';
import '../../features/auth/domain/use_cases/resend_password_reset_code_usecase.dart';
import '../../features/auth/domain/use_cases/reset_password_usecase.dart';
import '../../features/auth/domain/use_cases/verify_password_reset_code_usecase.dart';
import '../../features/auth/presentaion/bloc/forgot_password/forgot_password_bloc.dart';
import '../../features/auth/presentaion/bloc/login/login_bloc.dart';
import '../../features/auth/presentaion/bloc/signup/signup_bloc.dart';
import '../../features/home/data/remote_data_source/order_remote_data_source.dart';
import '../../features/home/data/repositories/order_repository_impl.dart';
import '../../features/home/domain/repositories/order_repository.dart';
import '../../features/home/presentation/cubit/customer_address_cubit.dart';
import '../../features/profile/data/remote_data_source/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/use_cases/change_password_usecase.dart';
import '../../features/profile/domain/use_cases/update_profile_usecase.dart';
import '../../features/profile/domain/use_cases/update_profile_image_usecase.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/tracking/data/data_sources/location_data_source.dart';
import '../../features/tracking/data/data_sources/tracking_remote_data_source.dart';
import '../../features/tracking/data/repositories/tracking_repository_impl.dart';
import '../../features/tracking/domain/repositories/tracking_repository.dart';
import '../../features/tracking/domain/use_cases/send_location.dart';
import '../../features/tracking/domain/use_cases/start_tracking.dart';
import '../../features/tracking/domain/use_cases/stop_tracking.dart';
import '../../features/tracking/presentation/cubit/tracking_cubit.dart';
import '../network/dio_consumer.dart';

final sl = GetIt.instance;

void initDependencies() {
  sl.registerSingletonAsync<SharedPreferences>(
    () async => await SharedPreferences.getInstance(),
  );

  sl.registerLazySingleton<Dio>(() => Dio());

  sl.registerLazySingleton<DioConsumer>(() => DioConsumer(sl<Dio>()));

  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSource(sl<DioConsumer>()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(sl<OrderRemoteDataSource>()),
  );
  sl.registerLazySingleton<LocationDataSource>(() => LocationDataSource());
  sl.registerLazySingleton<TrackingRemoteDataSource>(
    () => TrackingRemoteDataSource(sl<DioConsumer>()),
  );
  sl.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(
      sl<LocationDataSource>(),
      sl<TrackingRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<StartTracking>(
    () => StartTracking(sl<TrackingRepository>()),
  );
  sl.registerLazySingleton<SendLocation>(
    () => SendLocation(sl<TrackingRepository>()),
  );
  sl.registerLazySingleton<StopTracking>(
    () => StopTracking(sl<TrackingRepository>()),
  );
  sl.registerFactory<TrackingCubit>(
    () => TrackingCubit(
      startTrackingUseCase: sl<StartTracking>(),
      sendLocationUseCase: sl<SendLocation>(),
      stopTrackingUseCase: sl<StopTracking>(),
    ),
  );
  sl.registerFactory<CustomerAddressCubit>(
    () => CustomerAddressCubit(sl<OrderRepository>()),
  );

  sl.registerLazySingleton<AuthRemotDataSource>(
    () => AuthRemotDataSource(sl<DioConsumer>()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemotDataSource>(),
      sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(sl<DioConsumer>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      sl<ProfileRemoteDataSource>(),
      sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<UpdateProfileImageUseCase>(
    () => UpdateProfileImageUseCase(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<ChangePasswordUseCase>(
    () => ChangePasswordUseCase(sl<ProfileRepository>()),
  );
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      updateProfileUseCase: sl<UpdateProfileUseCase>(),
      updateProfileImageUseCase: sl<UpdateProfileImageUseCase>(),
      changePasswordUseCase: sl<ChangePasswordUseCase>(),
      requestPasswordResetCodeUseCase:
          sl<RequestPasswordResetCodeUseCase>(),
    ),
  );

  sl.registerLazySingleton<RequestPasswordResetCodeUseCase>(
    () => RequestPasswordResetCodeUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyPasswordResetCodeUseCase>(
    () => VerifyPasswordResetCodeUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ResendPasswordResetCodeUseCase>(
    () => ResendPasswordResetCodeUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifySignupCodeUseCase>(
    () => VerifySignupCodeUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<SignupBloc>(
    () => SignupBloc(
      usecase: sl<RegisterUseCase>(),
      verifySignupCodeUseCase: sl<VerifySignupCodeUseCase>(),
      resendCodeUseCase: sl<ResendPasswordResetCodeUseCase>(),
    ),
  );

  sl.registerFactory<LoginBloc>(() => LoginBloc(usecase: sl<LoginUseCase>()));
  sl.registerFactory<ForgotPasswordBloc>(
    () => ForgotPasswordBloc(
      requestCodeUseCase: sl<RequestPasswordResetCodeUseCase>(),
      verifyCodeUseCase: sl<VerifyPasswordResetCodeUseCase>(),
      resendCodeUseCase: sl<ResendPasswordResetCodeUseCase>(),
      resetPasswordUseCase: sl<ResetPasswordUseCase>(),
    ),
  );
}
