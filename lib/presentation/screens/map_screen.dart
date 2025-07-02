import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../business_logic/mapCubit/map_cubit.dart';
import '../../business_logic/mapCubit/map_states.dart';
import '../../helpers/components.dart';
import '../../helpers/location_helper.dart';
import '../../router/routes.dart';
import '../widgets/build_drawer_item.dart';
import '../widgets/glowing_fab.dart';
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
      MapCubit.get(context).loadMarkersFromFirebase();
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
        controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition!));
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = MapCubit.get(context);

    cubit.setContext(context);

    return Scaffold(
      body: Stack(
        children: [
          if (cameraPosition != null)
            BlocBuilder<MapCubit, MapStates>(
              buildWhen: (previous, current) =>
              current is MapMarkerState || current is MapRouteState,
              builder: (context, state) {
                return GoogleMap(

                  zoomControlsEnabled: false,

                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: cameraPosition!,
                  markers: state is MapMarkerState ? state.markers : {},
                  polylines: state is MapRouteState ? {state.polyline} : {},
                  onMapCreated: (controller) {
                    if (state is MapRouteState) {
                      controller.animateCamera(
                          CameraUpdate.newLatLng(state.cameraTarget));
                    }
                    if (!controllerCompleter.isCompleted) {
                      controllerCompleter.complete(controller);
                    }
                    cubit.mapController.complete(controller);
                  },
                  padding: EdgeInsets.only(bottom: 130.h, right: 5.w),
                );
              },
            ),

          /// Search Bar
          MapSearchBar(
            onSuggestionSelected: (marker) {
              setState(() => cubit.addSearchMarker(marker));
            },
          ),

          /// Legend FAB and Window
          Positioned(
            top: 120.h,
            right: 10.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'legend_fab',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    setState(() => _isLegendVisible = !_isLegendVisible);
                  },
                  child: Icon(
                    _isLegendVisible ? Icons.close : Icons.info_outline,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                if (_isLegendVisible)
                  Material(
                    elevation: 4.h,
                    borderRadius: BorderRadius.circular(12.r),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 200.w),
                      child: const MapLegendWindow(),
                    ),
                  ),
              ],
            ),
          ),

          /// Custom My Location Button (bottom right)
          Positioned(
            bottom: 120.h,
            right: 15.w,
            child: FloatingActionButton.small(

              heroTag: 'my_location_fab',
              backgroundColor: Colors.white,
              onPressed: () async {
                final currentPosition = await LocationHelper.getCurrentLocation();
                final controller = await controllerCompleter.future;
                controller.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(currentPosition.latitude, currentPosition.longitude),
                  ),
                );
              },
              child:  Icon(Icons.my_location,
                  size: 24.sp,
                  color: Colors.black),
            ),
          ),

          const MapSelectedLocationListener(),
        ],
      ),

      /// FAB
      floatingActionButton: BlocBuilder<MapCubit, MapStates>(
        builder: (context, state) {
          if (!cubit.isAdminChecked) {
            return FloatingActionButton(
              onPressed: () {

              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 24.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                builder: (_, size, __) => SizedBox(
                  height: size,
                  width: size,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              ),
            );
          }
          return GlowingFAB(
            isAdmin: cubit.isAdmin,
            onPressed: () {
              if (cubit.isAdmin) {
                Navigator.pushNamed(context, Routes.adminAnalyticsScreen);
              } else {
                showReportBottomSheet(context);
              }
            },
          );


        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      /// Drawer
      drawer: Drawer(

        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8.r,
                      offset: Offset(0, 3.h),
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.r),
                    bottomRight: Radius.circular(20.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FirebaseAuth.instance.currentUser?.displayName ?? 'User',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? 'No email found',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
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
                icon: Icons.support_agent,
                title: 'Call Support',
                onTap: () => callSupport(context),
              ),
              BuildDrawerItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {
                  Navigator.popAndPushNamed(context, Routes.changePasswordScreen);
                },
              ),
              BuildDrawerItem(
                icon: Icons.info_outline,
                title: 'About App',
                onTap: () => showModernAboutDialog(context),
              ),
              const Spacer(),
              const Divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: ElevatedButton.icon(
                  onPressed: () => logOut(context),
                  icon: Icon(Icons.logout, color: Colors.white, size: 20.sp),
                  label: Text(
                    'Logout',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 4.h,
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
