import 'package:delivert_app2/core/services/service_locator.dart';
import 'package:delivert_app2/features/auth/data/local_data_source/auth_local_data_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/order_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository repository;

  OrdersCubit({required this.repository}) : super(const OrdersState());

  Future<void> loadOrders() async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    await Future.wait([loadAvailableOrders(), loadMyOrders()]);
  }

  Future<void> loadAvailableOrders() async {
    final result = await repository.getAvailableOrders();

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _messageFromFailure(failure),
        ),
      ),
      (available) =>
          emit(state.copyWith(isLoading: false, availableOrders: available)),
    );
  }

  Future<void> loadMyOrders() async {
    final localUser = await sl<AuthLocalDataSource>().getUser();

    if (localUser!.id.isEmpty) {
      emit(state.copyWith(isLoading: false, myOrders: const []));
      return;
    }

    final result = await repository.getMyOrders(localUser.id.toString());

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _messageFromFailure(failure),
        ),
      ),
      (myOrders) => emit(state.copyWith(isLoading: false, myOrders: myOrders)),
    );
  }

  Future<bool> takeOrder(String orderId) async {
    final localUser = await sl<AuthLocalDataSource>().getUser();
    if (localUser == null || localUser.id.isEmpty) {
      return false;
    }
    emit(state.copyWith(isTakingOrder: true, actionOrderId: orderId));

    final result = await repository.takeOrder(
      deliveryUserId: localUser.id,
      orderId: orderId,
    );

    return result.fold<bool>(
      (failure) {
        emit(
          state.copyWith(
            isTakingOrder: false,
            actionOrderId: null,
            errorMessage: _messageFromFailure(failure),
          ),
        );
        return false;
      },
      (order) {
        final availableOrders = state.availableOrders
            .where((element) => element.id != orderId)
            .toList();
        final availableOrder = state.availableOrders.firstWhere(
          (element) => element.id == orderId,
          orElse: () => order,
        );
        final takenOrder = order.id == orderId
            ? order
            : availableOrder.copyWith(status: 3, deliveryUserId: localUser.id);
        final myOrders = [...state.myOrders, takenOrder];

        emit(
          state.copyWith(
            isTakingOrder: false,
            actionOrderId: null,
            availableOrders: availableOrders,
            myOrders: myOrders,
            successMessage: 'Order accepted successfully',
          ),
        );
        return true;
      },
    );
  }

  Future<void> deliverOrder(String orderId) async {
    final localUser = await sl<AuthLocalDataSource>().getUser();

    emit(state.copyWith(isDeliveringOrder: true, actionOrderId: orderId));

    final result = await repository.deliverOrder(
      deliveryUserId: localUser!.id.toString(),
      orderId: orderId,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isDeliveringOrder: false,
          actionOrderId: null,
          errorMessage: _messageFromFailure(failure),
        ),
      ),
      (order) {
        final myOrders = state.myOrders.map((item) {
          if (item.id == orderId) {
            return order.id == orderId ? order : item.copyWith(status: 4);
          }
          return item;
        }).toList();

        emit(
          state.copyWith(
            isDeliveringOrder: false,
            actionOrderId: null,
            myOrders: myOrders,
            successMessage: 'Order delivered successfully',
          ),
        );
      },
    );
  }

  String _messageFromFailure(Failure failure) {
    return failure.message.isNotEmpty
        ? failure.message
        : 'Something went wrong';
  }
}
