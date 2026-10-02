import 'package:equatable/equatable.dart';

import '../../../auth/domain/entiti/entity_login.dart';

class HomeState extends Equatable {
  User? user;
  final bool isLoading;
  final String? errorMessage;

  HomeState({this.user, this.isLoading = false, this.errorMessage});

  HomeState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return HomeState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [user, isLoading, errorMessage];
}
