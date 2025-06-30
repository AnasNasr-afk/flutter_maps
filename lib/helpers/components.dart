import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/helpers/shared_pref_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../business_logic/issueCubit/issue_cubit.dart';
import '../business_logic/mapCubit/map_cubit.dart';
import '../presentation/widgets/report_issue_bottom_sheet.dart';
import '../router/routes.dart';
import 'app_strings.dart';

void showPrivacyPolicyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) =>
        Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.privacy_tip_outlined,
                          size: 32.w, color: Colors.orange),
                      SizedBox(width: 10.w),
                      Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const Divider(),
                  SizedBox(height: 12.h),
                  Text(
                    'Last updated: June 16, 2025\n\n'
                        'CleanCity respects your privacy and is committed to protecting your personal data.\n\n'
                        '1. What Data We Collect:\n'
                        '- Location (for accurate issue reporting)\n'
                        '- Email (if provided when submitting feedback)\n'
                        '- Usage data (e.g. how you interact with the app)\n\n'
                        '2. How We Use It:\n'
                        '- To show your reports on the map\n'
                        '- To contact you for feedback or support\n'
                        '- To improve our app experience\n\n'
                        '3. Your Rights:\n'
                        'You can request to delete your data at any time by emailing us.\n\n'
                        'We never share or sell your data to third parties.\n\n'
                        '📧 For questions, contact: anas.nasr132003@gmail.com',
                    style: TextStyle(fontSize: 14.sp, height: 1.4.h),
                  ),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}
void showAppLoadingDialog(BuildContext context, {
  Color color = Colors.blueAccent,
  double? size,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: LoadingAnimationWidget.inkDrop(
        color: color,
        size: size ?? 55.sp,
      ),
    ),
  );
}

/// Closes the loading dialog if it's open.
void hideAppLoadingDialog(BuildContext context) {
  if (Navigator.canPop(context)) Navigator.of(context).pop();
}
void showReportBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (bottomSheetContext) =>
        BlocProvider.value(
          value: BlocProvider.of<MapCubit>(context),
          // ✅ Pass the existing MapCubit
          child: BlocProvider(
            create: (_) => IssueCubit(),
            child: const ReportIssueBottomSheet(),
          ),
        ),
  );
}

void showModernAboutDialog(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  showDialog(
    context: context,
    builder: (context) =>
        Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cleaning_services, size: 32.w,
                        color: Colors.orange),
                    SizedBox(width: 10.w),
                    Text(
                      'Clean City',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                const Divider(),
                SizedBox(height: 12.h),
                Text(
                  '🌍 Community-Powered Reporting',
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6.h),
                Text(
                  'CleanCity helps citizens easily report garbage, potholes, broken lights, and other city issues using their current location.',
                  style: TextStyle(fontSize: 14.sp, height: 1.4.h),
                ),
                SizedBox(height: 16.h),
                Text(
                  '🤝 How You Help',
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 6.h),
                Text(
                  'By submitting reports, you contribute to a cleaner, safer, and more organized city. Every report counts.',
                  style: TextStyle(fontSize: 14.sp, height: 1.4.h),
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () async {
                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: 'anas.nasr132003@gmail.com',
                      queryParameters: {'subject': 'CleanCity Support'},
                    );

                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    } else {
                      // fallback if mail app is not available
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text(
                                'No email app found on this device.')),
                      );
                    }
                  },
                  child: Text(
                    '📧 Contact Us: anas.nasr132003@gmail.com',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    showPrivacyPolicyDialog(context);
                  },
                  child: Text(
                    '🔒 View our Privacy Policy',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  '📱 Version: 1.0.0',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}

void callSupport(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final Uri phoneUri = Uri(scheme: 'tel', path: '+201024793905');

  if (await canLaunchUrl(phoneUri)) {
    Navigator.pop(context);
    await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
  } else {
    messenger.showSnackBar(
      const SnackBar(content: Text('No dialer app found on this device.')),
    );
  }
}

void logOut(BuildContext context) async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r)),
          backgroundColor: Colors.white,
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black87,
            ),
          ),
          actionsPadding: EdgeInsets.only(right: 16.w, bottom: 12.h),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
  );

  if (shouldLogout == true) {
    await FirebaseAuth.instance.signOut();
    await SharedPrefHelper.removeData(userId);

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.loginScreen,
          (route) => false,
    );
  }
}

Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
          contentPadding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 0),
          actionsPadding: EdgeInsets.only(right: 16.w, bottom: 12.h),

          title: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                foregroundColor: Colors.black54,
                textStyle: TextStyle(fontSize: 14.sp),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                foregroundColor: Colors.blueAccent,
                textStyle: TextStyle(
                    fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
  );
}

Future<void> showDeleteAccountDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.amber),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Delete Account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: const Text(
        'Are you sure you want to delete your account?\nThis action is irreversible!',
        style: TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
        await SharedPrefHelper.removeData('userId');
      }

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.loginScreen, (_) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: ${e.toString()}')),
      );
    }
  }
}

IconData getStatusIcon(String status) {
switch (status.toLowerCase()) {
case 'resolved':
return Icons.check_circle_outline;
case 'inprogress':
return Icons.hourglass_empty;
case 'rejected':
return Icons.cancel_outlined;
case 'pending':
default:
return Icons.pending_outlined;
}
}

Widget buildHandle() {
return Center(
child: Container(
width: 40.w,
height: 5.h,
margin: EdgeInsets.only(bottom: 16.h),
decoration: BoxDecoration(
color: Colors.grey[400],
borderRadius: BorderRadius.circular(8.r),
),
),
);
}

Widget buildSection(
BuildContext context, {
required String title,
required Widget child,
IconData? icon,
Color? iconColor,
required Animation<double> animation,
}) {
return FadeTransition(
opacity: animation,
child: Container(
margin: EdgeInsets.symmetric(vertical: 8.h),
padding: EdgeInsets.all(16.w),
decoration: BoxDecoration(
color: Colors.white.withValues(alpha: 0.9),
borderRadius: BorderRadius.circular(16.r),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: 0.08),
blurRadius: 12,
offset: const Offset(0, 4),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
if (icon != null) ...[
Icon(icon, color: iconColor ?? Colors.black54, size: 20.w),
SizedBox(width: 8.w),
],
Expanded(
child: Text(
title,
style: Theme.of(context).textTheme.titleMedium?.copyWith(
fontWeight: FontWeight.w700,
color: Colors.black87,
),
),
),
],
),
SizedBox(height: 10.h),
child,
],
),
),
);
}

Widget buildImage(BuildContext context, String imagePath) {
try {
final bytes = base64Decode(imagePath);
return ClipRRect(
borderRadius: BorderRadius.circular(16.r),
child: Image.memory(
bytes,
height: 220.h,
width: double.infinity.w,
fit: BoxFit.cover,
errorBuilder: (context, error, stackTrace) => buildErrorImage(),
),
);
} catch (e) {
return Image.network(
imagePath,
height: 220.h,
width: double.infinity.w,
fit: BoxFit.cover,
errorBuilder: (context, error, stackTrace) => buildErrorImage(),
);
}
}

Widget buildErrorImage() {
return Container(
height: 220.h,
width: double.infinity.w,
decoration: BoxDecoration(
color: Colors.grey.shade200,
borderRadius: BorderRadius.circular(16.r),
),
child: const Center(
child: Text(
'Select an image',
style: TextStyle(color: Colors.grey),
),
),
);
}

Widget buildStatusPill(String status) {
final color = getStatusColor(status);
return AnimatedContainer(
duration: const Duration(milliseconds: 400),
padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.3)],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.circular(20.r),
border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5.w),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(getStatusIcon(status), color: color, size: 18.w),
SizedBox(width: 8.h),
Text(
status[0].toUpperCase() + status.substring(1),
style: TextStyle(
color: color,
fontWeight: FontWeight.w700,
fontSize: 14.sp,
letterSpacing: 0.8,
),
),
],
),
);
}

Color getStatusColor(String status) {
switch (status.toLowerCase()) {
case 'resolved':
return Colors.green.shade600;
case 'inprogress':
return Colors.blue.shade600;
case 'rejected':
return Colors.redAccent.shade400;
case 'pending':
return Colors.orange.shade600;
default:
return Colors.grey.shade600;
}
}
