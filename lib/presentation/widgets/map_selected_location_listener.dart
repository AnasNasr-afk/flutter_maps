import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/presentation/widgets/app_markers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../business_logic/mapCubit/map_cubit.dart';
import '../../business_logic/mapCubit/map_states.dart';

class MapSelectedLocationListener extends StatelessWidget {
  const MapSelectedLocationListener({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = MapCubit.get(context);
    return BlocListener<MapCubit, MapStates>(
      listener: (context, state) async {
        if (state is MapPlaceSelectedState) {
          final controller = await MapCubit.get(context).mapController.future;

          final cameraPosition = CameraPosition(
            target: state.position,
            zoom: 16,
          );

          await controller
              .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));


          final marker = AppMarkers.buildSearchedPlaceMarker(
              markerId: const MarkerId('selected-location'),
              latLng: state.position,
              infoWindow: InfoWindow(title: state.description));
          cubit.addSearchMarker(marker);
          cubit.searchBarController.close();
          debugPrint("📍 Camera moved to: ${state.position}");
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
