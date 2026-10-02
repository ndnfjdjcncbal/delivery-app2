import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/services/service_locator.dart';
import 'features/auth/data/local_data_source/auth_local_data_source.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initDependencies();

  await sl.allReady();

  final initialRoute = sl<AuthLocalDataSource>().isLoggedIn()
      ? AppRoutes.home
      : AppRoutes.login;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
