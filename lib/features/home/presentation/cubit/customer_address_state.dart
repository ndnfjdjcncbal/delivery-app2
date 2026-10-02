import 'package:equatable/equatable.dart';

import '../../domain/entities/customer_address.dart';

class CustomerAddressState extends Equatable {
  final bool isLoading;
  final CustomerAddress? address;
  final String? errorMessage;

  const CustomerAddressState({
    this.isLoading = false,
    this.address,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, address, errorMessage];
}
