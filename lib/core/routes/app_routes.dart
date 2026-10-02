import 'package:flutter/material.dart';

import '../../features/auth/presentaion/pages/forgot_password_page.dart';
import '../../features/auth/presentaion/pages/login_page.dart';
import '../../features/auth/presentaion/pages/otp_verification_page_login.dart';
import '../../features/auth/presentaion/pages/reset_password_page.dart';
import '../../features/auth/presentaion/pages/sign_up_page.dart';
import '../../features/auth/presentaion/pages/otp_verification_page_sign.dart';
import '../../features/home/presentation/pages/delivery_home_page.dart';
import '../../features/home/presentation/pages/customer_address_map_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String otpVerification = '/otp-verification';
  static const String signupVerification = '/signup-verification';
  static const String home = '/home';
  static const String viewMap = '/view-map';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginPage(),
    signUp: (_) => SignUpPage(),
    forgotPassword: (_) => const ForgotPasswordPage(),
    resetPassword: (_) => const ResetPasswordPage(),
    otpVerification: (_) => const OtpVerificationPage(),
    signupVerification: (_) => const SignupVerificationPage(),
    home: (_) => const DeliveryHomePage(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (settings.name == viewMap) {
      String? normalizedOrderId;
      final arguments = settings.arguments;

      if (arguments is Map) {
        normalizedOrderId =
            (arguments['orderId'] ?? arguments['orders_id'] ?? arguments['id'])
                ?.toString();
      } else if (arguments is int) {
        normalizedOrderId = arguments.toString();
      } else {
        normalizedOrderId = arguments?.toString();
      }

      if (normalizedOrderId != null && normalizedOrderId.trim().isNotEmpty) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CustomerAddressMapPage(orderId: normalizedOrderId),
        );
      }
    }

    final builder = routes[settings.name];

    if (builder != null) {
      return MaterialPageRoute(settings: settings, builder: builder);
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (_) =>
          const Scaffold(body: Center(child: Text('Route not found'))),
    );
  }
}
