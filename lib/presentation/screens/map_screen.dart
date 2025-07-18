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
import '../../helpers/color_manager.dart';
import '../../helpers/components.dart';
import '../../helpers/location_helper.dart';
import '../../router/routes.dart';
import '../widgets/build_drawer_item.dart';
import '../widgets/glowing_fab.dart';
import '../widgets/map_legend_window.dart';
import '../widgets/map_selected_location_listener.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {

  String? sessionToken;
  Position? position;
  CameraPosition? cameraPosition;
  Completer<GoogleMapController> controllerCompleter = Completer();
  bool _isLegendVisible = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initLocation(); // Retry getting location when user returns to the app
    }
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // <-- add this
    _initLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sessionToken = const Uuid().v4();
      MapCubit.get(context).loadMarkersFromFirebase();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
          if (cameraPosition == null)
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
          Positioned(
            top: 60.h,
            left: 10.w,
            child: Builder(
              builder: (context) => FloatingActionButton.small(
                heroTag: 'menu_fab',
                backgroundColor: Colors.white,
                elevation: 2,
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: Icon(Icons.menu, color: Colors.black, size: 24.sp),
              ),
            ),
          ),
          Positioned(
            top: 65.h,
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
                  elevation: 2,
                  child: Icon(
                    _isLegendVisible ? Icons.close : Icons.info_outline,
                    color: Colors.black,
                    size: 24.sp,
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
          Positioned(
            bottom: 120.h,
            right: 15.w,
            child: FloatingActionButton.small(
              heroTag: 'my_location_fab',
              backgroundColor: Colors.white,
              onPressed: () async {
                try {
                  final currentPosition = await LocationHelper.getCurrentLocation();
                  final controller = await controllerCompleter.future;
                  controller.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(currentPosition.latitude, currentPosition.longitude),
                    ),
                  );
                } catch (e) {
                  showError(context, e.toString());
                }
              },
              child: Icon(Icons.my_location, size: 24.sp, color: Colors.black),
            ),
          ),
          const MapSelectedLocationListener(),
        ],
      ),
      floatingActionButton: BlocBuilder<MapCubit, MapStates>(
        builder: (context, state) {
          if (!cubit.isAdminChecked) {
            return FloatingActionButton(
              onPressed: () {},
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
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top.h,
                left: 16.w,
                right: 16.w,
                bottom: 24.h,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ColorManager.gradientStart, ColorManager.gradientEnd],
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
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ?? 'User'),
                        style: TextStyle(
                          fontSize: 25.sp,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        FirebaseAuth.instance.currentUser?.email ?? 'No email found',
                        style: TextStyle(
                          fontSize: 15.sp,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            BuildDrawerItem(
              icon: Icons.report_problem_outlined,
              title: 'Reported Issues',
              onTap: () => Navigator.popAndPushNamed(context, Routes.userReportsScreen),
            ),
            Divider(height: 32.h, thickness: 1, indent: 16.w, endIndent: 16.w, color: Colors.grey.shade300),
            BuildDrawerItem(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              onTap: () => Navigator.popAndPushNamed(context, Routes.editProfileScreen),
            ),
            Divider(height: 32.h, thickness: 1, indent: 16.w, endIndent: 16.w, color: Colors.grey.shade300),
            BuildDrawerItem(
              icon: Icons.notifications_active_outlined,
              title: 'Notifications',
              onTap: () => Navigator.popAndPushNamed(context, Routes.notificationsScreen),
            ),
            Divider(height: 32.h, thickness: 1, indent: 16.w, endIndent: 16.w, color: Colors.grey.shade300),
            BuildDrawerItem(
              icon: Icons.support_agent,
              title: 'Call Support',
              onTap: () => callSupport(context),
            ),
            Divider(height: 32.h, thickness: 1, indent: 16.w, endIndent: 16.w, color: Colors.grey.shade300),
            BuildDrawerItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () => Navigator.popAndPushNamed(context, Routes.changePasswordScreen),
            ),
            Divider(height: 32.h, thickness: 1, indent: 16.w, endIndent: 16.w, color: Colors.grey.shade300),
            BuildDrawerItem(
              icon: Icons.info_outline,
              title: 'About App',
              onTap: () => showModernAboutDialog(context),
            ),
            Divider(height: 32.h, thickness: 1, indent: 16.w, endIndent: 16.w, color: Colors.grey.shade300),
            BuildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => logOut(context),
            ),
          ],
        ),
      ),
    );
  }
}