import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/map_cubit.dart';
import 'package:flutter_maps/data/repository/maps_repo.dart';
import 'package:flutter_maps/data/webService/web_service.dart';
import 'package:flutter_maps/presentation/screens/map_screen.dart';
import 'package:flutter_maps/router/routes.dart';


class AppRouter {


  Route? generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case Routes.mapScreen:
        return MaterialPageRoute(builder: (_) => BlocProvider(
            create: (BuildContext context) => MapCubit(MapsRepo(WebService())),
        child: const MapScreen()));
    }
    return null;
  }
}
