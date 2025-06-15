import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/mapCubit/map_cubit.dart';
import 'package:flutter_maps/data/repository/maps_repo.dart';
import 'package:flutter_maps/data/webService/web_service.dart';
import 'package:flutter_maps/presentation/screens/login/loginCubit/login_cubit.dart';
import 'package:flutter_maps/presentation/screens/map_screen.dart';
import 'package:flutter_maps/presentation/screens/signUp/signupCubit/signup_cubit.dart';
import 'package:flutter_maps/router/routes.dart';

import '../presentation/screens/login/login_screen.dart';
import '../presentation/screens/signUp/signup_screen.dart';


class AppRouter {


  Route? generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context)=> LoginCubit(),
                child: const LoginScreen()));

      case Routes.signUpScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context)=> SignupCubit(),
              child: const SignUpScreen()),
        );

      // case Routes.signupSuccessfulScreen:
      //   return MaterialPageRoute(
      //     builder: (_) => const SignupSuccessfulScreen(),
      //   );
      // case Routes.homeLayout:
      //   return MaterialPageRoute(builder: (_)=> BlocProvider(create: (BuildContext context) => MapCubit(MapsRepo(WebService())),
      //   child: const HomeLayout()));

      case Routes.mapScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (BuildContext context) => MapCubit(MapsRepo(WebService())),
        child: const MapScreen()));
    }
    return null;
  }
}
