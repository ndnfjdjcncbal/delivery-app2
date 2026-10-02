import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/order_repository.dart';
import 'customer_address_state.dart';

class CustomerAddressCubit extends Cubit<CustomerAddressState> {
  final OrderRepository repository;

  CustomerAddressCubit(this.repository) : super(const CustomerAddressState());

  Future<void> loadCustomerAddress(String orderId) async {
    emit(const CustomerAddressState(isLoading: true));

    final result = await repository.getCustomerAddress(orderId);
    result.fold(
      (failure) => emit(CustomerAddressState(errorMessage: failure.message)),
      (address) {
        final latitude = address.latitude;
        final longitude = address.longitude;
        final validCoordinates =
            latitude != null &&
            longitude != null &&
            latitude >= -90 &&
            latitude <= 90 &&
            longitude >= -180 &&
            longitude <= 180;

        if (!validCoordinates) {
          emit(
            const CustomerAddressState(
              errorMessage: 'Customer location is missing or invalid.',
            ),
          );
          return;
        }

        emit(CustomerAddressState(address: address));
      },
    );
  }
}
