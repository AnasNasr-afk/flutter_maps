import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_maps/business_logic/map_cubit.dart';
import 'package:flutter_maps/helpers/location_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:uuid/uuid.dart';
import '../widgets/build_suggestion_bloc.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static Position? position;
  Completer<GoogleMapController> controllerCompleter = Completer();

  static final CameraPosition cameraPosition = CameraPosition(
    target: LatLng(position?.latitude ?? 0.0, position?.longitude ?? 0.0),
    zoom: 17,
  );

  Future<void> getMyCurrentLocation() async {
    try {
      position = await LocationHelper.getCurrentLocation();
      final GoogleMapController controller = await controllerCompleter.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position!.latitude, position!.longitude),
          zoom: 17,
        ),
      ));
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Widget buildFloatingSearchBar() {
    MapCubit cubit = MapCubit.get(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      controller: cubit.searchBarController,
      hint: 'Search...',
      queryStyle: const TextStyle(fontSize: 18),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) => getPlacesSuggestions(query),
      builder: (context, transition) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.white,
          elevation: 4.0,
          child: const BuildSuggestionsBloc(),
        ),
      ),
    );
  }

  void getPlacesSuggestions(String query) {
    final sessionToken = const Uuid().v4();
    MapCubit.get(context).emitPlacesSuggestion(query, sessionToken);
  }

  Widget buildMap() {
    return GoogleMap(
      initialCameraPosition: cameraPosition,
      mapType: MapType.normal,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: true,
      onMapCreated: (GoogleMapController googleMapController) {
        controllerCompleter.complete(googleMapController);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getMyCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          position != null
              ? buildMap()
              : const Center(child: CircularProgressIndicator(color: Colors.black)),
          buildFloatingSearchBar(),
        ],
      ),
    );
  }
}