import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_color/Colors.dart';
import '../../../../core/services/service_locator.dart';
import '../cubit/customer_address_cubit.dart';
import '../cubit/customer_address_state.dart';
import '../cubit/delivery_location_cubit.dart';
import '../cubit/delivery_location_state.dart';

class CustomerAddressMapPage extends StatelessWidget {
  final String? orderId;

  const CustomerAddressMapPage({super.key, this.orderId});

  String _resolveOrderId(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map) {
      final value =
          arguments['orderId'] ?? arguments['orders_id'] ?? arguments['id'];
      if (value != null) return value.toString().trim();
    }

    if (arguments is String) return arguments.trim();
    if (arguments is int) return arguments.toString();
    if (orderId != null) return orderId!.trim();
    print(orderId);
    return orderId!.trim();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedOrderId = _resolveOrderId(context);

    if (resolvedOrderId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Missing order id. Please return to the previous page.'),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<CustomerAddressCubit>()..loadCustomerAddress(resolvedOrderId),
        ),
        BlocProvider(create: (_) => DeliveryLocationCubit()..startTracking()),
      ],
      child: _CustomerAddressMapView(resolvedOrderId: resolvedOrderId),
    );
  }
}

class _CustomerAddressMapView extends StatefulWidget {
  final String resolvedOrderId;

  const _CustomerAddressMapView({required this.resolvedOrderId});

  @override
  State<_CustomerAddressMapView> createState() =>
      _CustomerAddressMapViewState();
}

class _CustomerAddressMapViewState extends State<_CustomerAddressMapView> {
  GoogleMapController? _mapController;

  void _showBothLocations(LatLng customerPosition, LatLng deliveryPosition) {
    final controller = _mapController;
    if (controller == null) return;

    var south = customerPosition.latitude < deliveryPosition.latitude
        ? customerPosition.latitude
        : deliveryPosition.latitude;
    var north = customerPosition.latitude > deliveryPosition.latitude
        ? customerPosition.latitude
        : deliveryPosition.latitude;
    var west = customerPosition.longitude < deliveryPosition.longitude
        ? customerPosition.longitude
        : deliveryPosition.longitude;
    var east = customerPosition.longitude > deliveryPosition.longitude
        ? customerPosition.longitude
        : deliveryPosition.longitude;

    if (south == north) {
      south -= 0.001;
      north += 0.001;
    }
    if (west == east) {
      west -= 0.001;
      east += 0.001;
    }

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south, west),
          northeast: LatLng(north, east),
        ),
        72,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('Customer Address'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
      ),
      body: BlocBuilder<CustomerAddressCubit, CustomerAddressState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 14),
                  Text('Loading customer location...'),
                ],
              ),
            );
          }

          if (state.errorMessage != null) {
            return _LocationMessage(
              message: state.errorMessage!,
              onRetry: () => context
                  .read<CustomerAddressCubit>()
                  .loadCustomerAddress(widget.resolvedOrderId),
            );
          }

          final address = state.address;
          final latitude = address?.latitude;
          final longitude = address?.longitude;
          if (address == null || latitude == null || longitude == null) {
            return _LocationMessage(
              message: 'Customer location is unavailable.',
              onRetry: () => context
                  .read<CustomerAddressCubit>()
                  .loadCustomerAddress(widget.resolvedOrderId),
            );
          }

          final customerPosition = LatLng(latitude, longitude);
          return BlocListener<DeliveryLocationCubit, DeliveryLocationState>(
            listener: (context, locationState) {
              final position = locationState.position;
              if (position != null) {
                _showBothLocations(
                  customerPosition,
                  LatLng(position.latitude, position.longitude),
                );
              }
            },
            child: BlocBuilder<DeliveryLocationCubit, DeliveryLocationState>(
              builder: (context, locationState) {
                final position = locationState.position;
                final deliveryPosition = position == null
                    ? null
                    : LatLng(position.latitude, position.longitude);

                return Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: customerPosition,
                        zoom: 16,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                        if (deliveryPosition != null) {
                          _showBothLocations(
                            customerPosition,
                            deliveryPosition,
                          );
                        }
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('customer-location'),
                          position: customerPosition,
                          infoWindow: InfoWindow(
                            title: 'Customer',
                            snippet: address.address,
                          ),
                        ),
                        if (deliveryPosition != null)
                          Marker(
                            markerId: const MarkerId('delivery-location'),
                            position: deliveryPosition,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure,
                            ),
                            infoWindow: const InfoWindow(
                              title: 'Your location',
                              snippet: 'Live GPS location',
                            ),
                          ),
                      },
                      mapToolbarEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: true,
                    ),
                    if (locationState.isLoading ||
                        locationState.errorMessage != null ||
                        deliveryPosition != null)
                      Positioned(
                        top: 12,
                        left: 16,
                        right: 16,
                        child: SafeArea(
                          child: _DeliveryLocationStatus(
                            state: locationState,
                            onRetry: () => context
                                .read<DeliveryLocationCubit>()
                                .startTracking(),
                            onOpenSettings: () => context
                                .read<DeliveryLocationCubit>()
                                .openAppSettings(),
                            onOpenLocationSettings: () => context
                                .read<DeliveryLocationCubit>()
                                .openLocationSettings(),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 20,
                      child: SafeArea(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 16,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Order #${widget.resolvedOrderId}',
                                      style: const TextStyle(
                                        color: AppColors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      address.address.isEmpty
                                          ? 'Customer location'
                                          : address.address,
                                      style: const TextStyle(
                                        color: AppColors.grey,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _DeliveryLocationStatus extends StatelessWidget {
  final DeliveryLocationState state;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenLocationSettings;

  const _DeliveryLocationStatus({
    required this.state,
    required this.onRetry,
    required this.onOpenSettings,
    required this.onOpenLocationSettings,
  });

  @override
  Widget build(BuildContext context) {
    final message =
        state.errorMessage ??
        (state.isLoading
            ? 'Getting your live location...'
            : 'Live location tracking is active.');

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  state.errorMessage == null
                      ? Icons.my_location_rounded
                      : Icons.location_disabled_rounded,
                  color: state.errorMessage == null
                      ? AppColors.primary
                      : AppColors.newBadge,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (state.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (state.errorMessage != null && !state.isLoading)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: state.permissionPermanentlyDenied
                      ? onOpenSettings
                      : state.locationServiceDisabled
                      ? onOpenLocationSettings
                      : onRetry,
                  icon: Icon(
                    state.permissionPermanentlyDenied ||
                            state.locationServiceDisabled
                        ? Icons.settings_rounded
                        : Icons.refresh_rounded,
                    size: 18,
                  ),
                  label: Text(
                    state.permissionPermanentlyDenied ||
                            state.locationServiceDisabled
                        ? 'Open settings'
                        : 'Retry',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LocationMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LocationMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off_rounded,
              size: 48,
              color: AppColors.grey,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.black, fontSize: 16),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
