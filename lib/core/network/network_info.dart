import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkInfo {
  NetworkInfo() : _connection = InternetConnection();

  final InternetConnection _connection;

  Future<bool> get isConnected async {
    return await _connection.hasInternetAccess;
  }

  Stream<InternetStatus> get internetStatus => _connection.onStatusChange;
}
