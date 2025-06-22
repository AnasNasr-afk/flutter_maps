import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../business_logic/mapCubit/map_cubit.dart';
import '../../business_logic/mapCubit/map_states.dart';
import '../../helpers/components.dart';
import '../../helpers/location_helper.dart';
import '../../router/routes.dart';
import '../widgets/build_drawer_item.dart';
import '../widgets/map_legend_window.dart';
import '../widgets/map_search_bar.dart';
import '../widgets/map_selected_location_listener.dart';

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
    final cubit = MapCubit.get(context);
    cubit.setContext(context); // 🧠 this is the fix
    return Scaffold(
      body: Stack(
        children: [
          if (cameraPosition != null)
            BlocBuilder<MapCubit, MapStates>(
              buildWhen: (previous, current) => current is MapMarkerState || current is MapRouteState,
              builder: (context, state) {
                return GoogleMap(
                  zoomControlsEnabled: false,

                  initialCameraPosition: cameraPosition!,
                  markers: state is MapMarkerState ? state.markers : {},
                  polylines: state is MapRouteState ? {state.polyline} : {},
                  onMapCreated: (GoogleMapController controller) {
                    if (state is MapRouteState) {
                      controller.animateCamera(CameraUpdate.newLatLng(state.cameraTarget));
                    }
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
              MapCubit.get(context).addSearchMarker(marker);
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

      floatingActionButton: BlocBuilder<MapCubit, MapStates>(
        builder: (context, state) {
          final cubit = MapCubit.get(context);

          if (!cubit.isAdminChecked) {
            return FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 24.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                builder: (context, size, child) {
                  return SizedBox(
                    height: size,
                    width: size,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  );
                },
              ),
            );
          }

          if (cubit.isAdmin) {
            return FloatingActionButton(
              backgroundColor: Colors.amber,
              onPressed: () {
                // admin logic
              },
              child: const Icon(
                Icons.analytics_outlined,
                color: Colors.black,
                size: 30,
              ),
            );
          } else {
            return FloatingActionButton(
              heroTag: null,
              onPressed: () {
                showReportBottomSheet(context);
              },
              backgroundColor: Colors.amber,
              child: const Icon(
                Icons.add,
                size: 30,
                color: Colors.black,
              ),
            );
          }
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FirebaseAuth.instance.currentUser?.displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? 'No email found',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BuildDrawerItem(
                icon: Icons.report_problem_outlined,
                title: 'Reported Issues',
                onTap: () {
                  Navigator.popAndPushNamed(context, Routes.userReportsScreen);
                },
              ),
              BuildDrawerItem(
                icon: Icons.notifications_active_outlined,
                title: 'Notifications',
                onTap: () {
                  Navigator.popAndPushNamed(context, Routes.notificationsScreen);
                },
              ),
              BuildDrawerItem(
                icon: Icons.language,
                title: 'Change Language',
                onTap: () {},
              ),

              const SizedBox(height: 10),

              // 🛠 Support & Account
              BuildDrawerItem(
                icon: Icons.support_agent,
                title: 'Call Support',
                onTap: () {
                  callSupport(context);
                },
              ),
              BuildDrawerItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {},
              ),
              BuildDrawerItem(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                onTap: () {},
              ),

              const SizedBox(height: 10),

              // ℹ️ Info
              BuildDrawerItem(
                icon: Icons.info_outline,
                title: 'About App',
                onTap: () {
                  showModernAboutDialog(context);
                },
              ),

              const Spacer(),
              const Divider(),

              // 🚪 Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ElevatedButton.icon(
                  onPressed: ()  {
                    logOut(context);
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
