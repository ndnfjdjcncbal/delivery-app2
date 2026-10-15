import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routes/app_routes.dart';
import 'core/services/service_locator.dart';
import 'features/auth/data/local_data_source/auth_local_data_source.dart';
import 'features/tracking/presentation/cubit/tracking_cubit.dart';

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
    return BlocProvider<TrackingCubit>(
      create: (_) => sl<TrackingCubit>(),
      child: MaterialApp(
        title: 'Delivery App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: initialRoute,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
