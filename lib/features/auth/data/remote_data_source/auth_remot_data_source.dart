import 'package:dio/dio.dart';

import '../../../../core/constants/api_client/link_api.dart';
import '../../../../core/network/api_consumer.dart';

class AuthRemotDataSource {
  final ApiConsumer apiConsumer;

  AuthRemotDataSource(this.apiConsumer);

  Future<Response> login(String email, String password) {
    return apiConsumer.post(
      ApiConstants.login,
      data: FormData.fromMap({'email': email, 'password': password}),
    );
  }

  Future<Response> register(String name, String email, String password) {
    return apiConsumer.post(
      ApiConstants.signupl,
      data: FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
  }

  Future<Response> verifyCode(String email, String verified) {
    return apiConsumer.post(
      ApiConstants.checkcodelogin,
      data: FormData.fromMap({'email': email, 'verified': verified}),
    );
  }

  Future<Response> verifySignupCode(String email, String verified) {
    return apiConsumer.post(
      ApiConstants.verifiedcodesignup,
      data: FormData.fromMap({'email': email, 'verified': verified}),
    );
  }

  Future<Response> resendCode(String email) {
    return apiConsumer.post(ApiConstants.resendcode, data: {'email': email});
  }

  Future<Response> forgotPassword(String email) {
    return apiConsumer.post(
      ApiConstants.forgetpasswordlink,
      data: FormData.fromMap({'email': email}),
    );
  }

  Future<Response> resetPassword(
    String email,
    String code,
    String newPassword,
  ) {
    return apiConsumer.post(
      ApiConstants.resetpass,
      data: FormData.fromMap({
        'email': email,
        'code': code,
        'password': newPassword,
      }),
    );
  }

  Future<Response> logout() {
    return apiConsumer.post('/logout');
  }

  Future<Response> getCurrentUser() {
    return apiConsumer.get('/user');
  }
}
