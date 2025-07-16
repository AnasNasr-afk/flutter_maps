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
import '../presentation/widgets/fade_in_lottie.dart';
import '../presentation/widgets/reportIssueBottomSheet/report_issue_bottom_sheet.dart';
import '../router/routes.dart';
import 'app_strings.dart';
import 'components.dart' as Fluttertoast;

// void showPrivacyPolicyDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) => Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       elevation: 10,
//       backgroundColor: Colors.white,
//       child: Padding(
//         padding: EdgeInsets.all(24.w),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.privacy_tip_outlined,
//                       size: 32.w, color: Colors.orange),
//                   SizedBox(width: 10.w),
//                   Text(
//                     'Privacy Policy',
//                     style: TextStyle(
//                       fontSize: 22.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12.h),
//               const Divider(),
//               SizedBox(height: 12.h),
//               Text(
//                 'Last updated: June 16, 2025\n\n'
//                 'CleanCity respects your privacy and is committed to protecting your personal data.\n\n'
//                 '1. What Data We Collect:\n'
//                 '- Location (for accurate issue reporting)\n'
//                 '- Email (if provided when submitting feedback)\n'
//                 '- Usage data (e.g. how you interact with the app)\n\n'
//                 '2. How We Use It:\n'
//                 '- To show your reports on the map\n'
//                 '- To contact you for feedback or support\n'
//                 '- To improve our app experience\n\n'
//                 '3. Your Rights:\n'
//                 'You can request to delete your data at any time by emailing us.\n\n'
//                 'We never share or sell your data to third parties.\n\n'
//                 '📧 For questions, contact: anas.nasr132003@gmail.com',
//                 style: TextStyle(fontSize: 14.sp, height: 1.4.h),
//               ),
//               SizedBox(height: 20.h),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text(
//                     'OK',
//                     style: TextStyle(
//                       color: Colors.orange,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

void showAppLoadingDialog(
  BuildContext context, {
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

void showModernAboutDialog(BuildContext context) {


  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Colors.black87,
                    child: const Icon(Icons.location_city, color: Colors.white),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'CairoCrew',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Divider(thickness: 1.2, color: Colors.grey[300]),
              SizedBox(height: 16.h),

              /// About Section
              _buildSectionTitle('🌆 About CairoCrew'),
              _buildBodyText(
                'CairoCrew helps residents report urban issues such as waste, damaged roads, or streetlight failures through a simple, location-based interface.',
              ),

              SizedBox(height: 16.h),
              _buildSectionTitle('🤝 Why Your Role Matters'),
              _buildBodyText(
                'Your input enables local authorities to prioritize and fix issues quickly. Together, we make Cairo cleaner and more organized.',
              ),




              /// Terms
              _buildLinkRow(
                icon: Icons.article_outlined,
                label: 'Terms & Conditions',
                color: Colors.blue,
                onTap: () {
                  launchUrl(
                    Uri.parse('https://github.com/AnasNasr-afk/flutter_maps/blob/main/TERMS.md'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),

              SizedBox(height: 16.h),

              /// Version Info
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '📱 Version: 1.0.0',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                ),
              ),

              SizedBox(height: 16.h),

              /// OK Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.black87),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontWeight: FontWeight.bold),
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

Widget _buildSectionTitle(String title) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87),
    ),
  );
}

Widget _buildBodyText(String content) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      content,
      style: TextStyle(fontSize: 13.5.sp, color: Colors.black87, height: 1.4),
    ),
  );
}

Widget _buildLinkRow({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 22.r, color: color),
          SizedBox(width: 10.w),
          Text(
            label,
            style: TextStyle(fontSize: 14.5.sp, color: color, fontWeight: FontWeight.w600),
          ),
        ],
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
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Using the selected Lottie animation
            const FadeInLottieAnimation(),
            SizedBox(height: 20.h),
            Text(
              "Comeback Soon!",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              "Are you sure you want to logout?",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.red.shade300,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Yes, Logout",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
    builder: (context) => AlertDialog(
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
            textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
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

void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );
}

