import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_maps/helpers/app_strings.dart';
import 'package:flutter_maps/helpers/shared_pref_helper.dart';
import 'package:flutter_maps/router/app_router.dart';
import 'package:flutter_maps/router/routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'helpers/message_config.dart';


import 'package:firebase_messaging/firebase_messaging.dart';


import 'dart:io';




void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(MessageConfig.firebaseMessagingBackgroundHandler);
  await MessageConfig.initFirebaseMessaging();
  String? token;
  if (Platform.isAndroid) {
    token = await FirebaseMessaging.instance.getToken();
    debugPrint('📱 Android FCM Token: $token');
  } else if (Platform.isIOS) {
    await Future.delayed(const Duration(seconds: 3));
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();

    if (apnsToken != null) {
      token = await FirebaseMessaging.instance.getToken();
      debugPrint('🍎 iOS FCM Token: $token');
    } else {
      ('⚠️ iOS APNs token not yet set');
    }
  }
  final String userToken = await SharedPrefHelper.getString(userId);
  final bool isLoggedIn = userToken.isNotEmpty;

  // 🚀 Run the app
  runApp(MapsApp(
    appRouter: AppRouter(),
    isLoggedIn: isLoggedIn,
  ));
}





class MapsApp extends StatelessWidget {
  final AppRouter appRouter;
  final bool isLoggedIn;

  const MapsApp({
    super.key,
    required this.appRouter,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
      designSize: const Size(375,812),
      minTextAdapt: true,
      child: MaterialApp(

        title: 'Flutter Maps',
        debugShowCheckedModeBanner: false,
        initialRoute: isLoggedIn ? Routes.mapScreen : Routes.onboardingScreen,
        onGenerateRoute: appRouter.generateRoutes,
      ),
    );
  }
}
