import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/issueCubit/issue_cubit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../business_logic/mapCubit/map_cubit.dart';
import '../../business_logic/mapCubit/map_states.dart';
import '../../helpers/location_helper.dart';
import '../widgets/map_legend_window.dart';
import '../widgets/map_search_bar.dart';
import '../widgets/map_selected_location_listener.dart';
import '../widgets/report_issue_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? sessionToken;
  Position? position;
  CameraPosition? cameraPosition;
  Completer<GoogleMapController> controllerCompleter = Completer();
  bool _isLegendVisible = false;


  // Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sessionToken = const Uuid().v4();
    });


  }

  Future<void> _initLocation() async {
    try {
      position = await LocationHelper.getCurrentLocation();
      cameraPosition = CameraPosition(
        target: LatLng(position!.latitude, position!.longitude),
        zoom: 15,
      );

      if (controllerCompleter.isCompleted) {
        final controller = await controllerCompleter.future;
        controller
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition!));
      }

      if (mounted) {
        // final marker = AppMarkers.buildCurrentLocationMarker(position!);
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (cameraPosition != null)
            BlocBuilder<MapCubit, MapStates>(
              buildWhen: (previous, current) =>
                  current is MapMarkerState,
              builder: (context, state) {
                return GoogleMap(
                  initialCameraPosition: cameraPosition!,
                  markers: state is MapMarkerState ? state.markers : {},
                  onMapCreated: (GoogleMapController controller) {
                    if (!controllerCompleter.isCompleted) {
                      controllerCompleter.complete(controller);
                    }
                    MapCubit.get(context).mapController.complete(controller);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  padding: const EdgeInsets.only(bottom: 130, right: 5),
                );
              },
            ),
          MapSearchBar(onSuggestionSelected: (marker) {
            setState(() {
              MapCubit.get(context).markers.add(marker);
            });
          }),
          Positioned(
            top: 120,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'legend_fab',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _isLegendVisible = !_isLegendVisible;
                    });
                  },
                  child: Icon(
                    _isLegendVisible ? Icons.close : Icons.info_outline,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                if (_isLegendVisible)
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 200,
                      ),
                      child: const MapLegendWindow(),
                    ),
                  ),
              ],
            ),
          ),
          const MapSelectedLocationListener(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          _showReportBottomSheet(context);
        },
        backgroundColor: Colors.amber,
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.black,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.amber),
              child: Text('Menu'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => BlocProvider.value(
        value: BlocProvider.of<MapCubit>(context),
        // ✅ Pass the existing MapCubit
        child: BlocProvider(
          create: (_) => IssueCubit(),
          child: const ReportIssueBottomSheet(),
        ),
      ),
    );
  }
}
