import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/service_locator.dart';
import '../../../auth/data/local_data_source/auth_local_data_source.dart';
import '../../../auth/domain/entiti/entity_login.dart';
import '../../../auth/domain/repo/auth_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AuthRepository authRepository;

  HomeCubit(this.authRepository) : super(HomeState());

  Future<void> loadUser() async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    final localUser = await sl<AuthLocalDataSource>().getUser();
    emit(state.copyWith(user: localUser ?? state.user, isLoading: false));
  }

  Future<void> logout() async {
    emit(state.copyWith(isLoading: true));
    await sl<AuthLocalDataSource>().clearUser();
    await authRepository.logout();
    emit(
      state.copyWith(
        user: state.user,
        isLoading: false,
        clearErrorMessage: true,
      ),
    );
  }
}
