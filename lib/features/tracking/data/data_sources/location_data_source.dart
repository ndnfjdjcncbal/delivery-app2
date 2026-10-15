import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/driver_location.dart';

class LocationTrackingException implements Exception {
  final String message;

  const LocationTrackingException(this.message);
}

class LocationDataSource {
  Future<Stream<DriverLocation>> startTracking() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationTrackingException(
        'يرجى تفعيل خدمة الموقع (GPS) لبدء مشاركة موقعك.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationTrackingException(
        'تم رفض إذن الموقع نهائيًا. فعّل إذن الموقع من إعدادات التطبيق.',
      );
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      throw const LocationTrackingException(
        'يلزم السماح للتطبيق بالوصول إلى الموقع لمشاركة موقع التوصيل.',
      );
    }

    try {
      return Geolocator.getPositionStream(
        locationSettings: _locationSettings(),
      ).map(
        (position) => DriverLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          heading: _validHeading(position.heading),
        ),
      );
    } on LocationServiceDisabledException {
      throw const LocationTrackingException(
        'تم إيقاف خدمة الموقع. فعّل GPS لمتابعة مشاركة الموقع.',
      );
    } on PermissionDeniedException {
      throw const LocationTrackingException(
        'تعذر الوصول إلى الموقع. تحقق من أذونات الموقع في إعدادات التطبيق.',
      );
    }
  }

  Future<DriverLocation?> getLastKnownPosition() async {
    final position = await Geolocator.getLastKnownPosition();
    if (position == null) return null;
    return DriverLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      heading: _validHeading(position.heading),
    );
  }

  double _validHeading(double heading) {
    return heading.isFinite && heading >= 0 && heading <= 360 ? heading : 0;
  }

  LocationSettings _locationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'مشاركة الموقع المباشر',
          notificationText: 'يتم مشاركة موقعك أثناء توصيل الطلب',
          enableWakeLock: true,
        ),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
  }
}
