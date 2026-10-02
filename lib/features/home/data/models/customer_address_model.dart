import '../../domain/entities/customer_address.dart';

class CustomerAddressModel extends CustomerAddress {
  const CustomerAddressModel({
    required super.address,
    required super.latitude,
    required super.longitude,
  });

  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) {
    String valueOf(String key) => json[key]?.toString().trim() ?? '';

    final address = [
      valueOf('addres_street'),
      valueOf('addres_city'),
      valueOf('addres_country'),
    ].where((part) => part.isNotEmpty).join(', ');

    return CustomerAddressModel(
      address: address,
      latitude: double.tryParse(valueOf('addres_lat')),
      longitude: double.tryParse(valueOf('addres_long')),
    );
  }
}
