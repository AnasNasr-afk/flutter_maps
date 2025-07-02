import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/mapCubit/map_cubit.dart';
import 'package:flutter_maps/data/repository/maps_repo.dart';
import 'package:flutter_maps/data/webService/web_service.dart';
import 'package:flutter_maps/presentation/screens/change_password_screen.dart';
import 'package:flutter_maps/presentation/screens/login/loginCubit/login_cubit.dart';
import 'package:flutter_maps/presentation/screens/map_screen.dart';
import 'package:flutter_maps/presentation/screens/notifications_screen.dart';
import 'package:flutter_maps/presentation/screens/signUp/signupCubit/signup_cubit.dart';
import 'package:flutter_maps/presentation/screens/side_by_side_screenshots_preview.dart';
import 'package:flutter_maps/router/routes.dart';

import '../business_logic/userReportsCubit/user_reports_cubit.dart';
import '../business_logic/userSecurityCubit/user_security_cubit.dart';
import '../presentation/screens/admin_analytics_screen.dart';
import '../presentation/screens/login/login_screen.dart';
import '../presentation/screens/signUp/signup_screen.dart';
import '../presentation/screens/user_reports_screen.dart';

class AppRouter {
  Route? generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider(
                create: (context) => LoginCubit(), child: const LoginScreen()));

      case Routes.signUpScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
              create: (context) => SignupCubit(), child: const SignUpScreen()),
        );

      case Routes.mapScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider(
                create: (BuildContext context) =>
                    MapCubit(MapsRepo(WebService())),
                child: const MapScreen()));

      case Routes.userReportsScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
                value: MapCubit(MapsRepo(WebService())),
                child: BlocProvider(
                    create: (context) => UserReportsCubit(),
                    child: const UserReportsScreen())));

      case Routes.notificationsScreen:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case Routes.adminAnalyticsScreen:
        return MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen());
      case Routes.changePasswordScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider(
                create: (context) => UserSecurityCubit(),
                child: const ChangePasswordScreen()));
      case Routes.sideBySideScreenshotsPreview:
        return MaterialPageRoute(
            builder: (_) => const SideBySideScreenshotsPreview());
    }
    return null;
  }
}
