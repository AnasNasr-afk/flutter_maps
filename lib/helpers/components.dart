import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/helpers/shared_pref_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../business_logic/issueCubit/issue_cubit.dart';
import '../business_logic/mapCubit/map_cubit.dart';
import '../presentation/widgets/report_issue_bottom_sheet.dart';
import '../router/routes.dart';
import 'app_strings.dart';

void showPrivacyPolicyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.privacy_tip_outlined,
                      size: 32, color: Colors.orange),
                  SizedBox(width: 10),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
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
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 20),
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

void showReportBottomSheet(BuildContext context) {
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
// void showReportBottomSheet(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (bottomSheetContext) => BlocProvider.value(
//       value: BlocProvider.of<MapCubit>(context),
//       // ✅ Pass the existing MapCubit
//       child: BlocProvider(
//         create: (_) => IssueCubit(),
//         child: const ReportIssueBottomSheet(),
//       ),
//     ),
//   );
// }

void showModernAboutDialog(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cleaning_services, size: 32, color: Colors.orange),
                SizedBox(width: 10),
                Text(
                  'Clean City',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              '🌍 Community-Powered Reporting',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'CleanCity helps citizens easily report garbage, potholes, broken lights, and other city issues using their current location.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Text(
              '🤝 How You Help',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'By submitting reports, you contribute to a cleaner, safer, and more organized city. Every report counts.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 16),
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
                        content: Text('No email app found on this device.')),
                  );
                }
              },
              child: const Text(
                '📧 Contact Us: anas.nasr132003@gmail.com',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                showPrivacyPolicyDialog(context);
              },
              child: const Text(
                '🔒 View our Privacy Policy',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '📱 Version: 1.0.0',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
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
    await launchUrl(phoneUri);
  } else {
    messenger.showSnackBar(
      const SnackBar(content: Text('No email app found on this device.')),
    );
  }
}

void logOut(BuildContext context) async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // prevent dismiss on outside tap
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      title: const Text(
        'Confirm Logout',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      content: const Text(
        'Are you sure you want to logout?',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
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

// Widget buildHandle() {
//   return Center(
//     child: Container(
//       width: 48,
//       height: 5,
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade300.withValues(alpha: 0.8),
//         borderRadius: BorderRadius.circular(10),
//       ),
//     ),
//   );
// }
Widget buildHandle() {
  return Center(
    child: Container(
      width: 40,
      height: 5,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}



// Widget buildSection(
//     BuildContext context, {
//       required String title,
//       required IconData icon,
//       Color? iconColor,
//       required Animation<double> animation,
//       required Widget child,
//     }) {
//   return FadeTransition(
//     opacity: animation,
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, color: iconColor ?? Colors.black54, size: 20),
//             const SizedBox(width: 8),
//             Text(
//               title,
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         child,
//         const SizedBox(height: 16),
//       ],
//     ),
//   );
// }
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
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
                Icon(icon, color: iconColor ?? Colors.black54, size: 20),
                const SizedBox(width: 8),
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
          const SizedBox(height: 10),
          child,
        ],
      ),
    ),
  );
}



// Widget buildImage(BuildContext context, String path) {
//   final bool isNetwork = path.startsWith('http');
//
//   final imageWidget = isNetwork
//       ? Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => buildErrorImage())
//       : File(path).existsSync()
//       ? Image.file(File(path), fit: BoxFit.cover)
//       : buildErrorImage();
//
//   return GestureDetector(
//     onTap: () {
//       showDialog(
//         context: context,
//         builder: (context) => Dialog(
//           backgroundColor: Colors.transparent,
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: imageWidget,
//           ),
//         ),
//       );
//     },
//     child: Hero(
//       tag: path,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: SizedBox(
//           height: 220,
//           width: double.infinity,
//           child: imageWidget,
//         ),
//       ),
//     ),
//   );
// }
Widget buildImage(BuildContext context, String imagePath) {
  try {
    final bytes = base64Decode(imagePath);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.memory(
        bytes,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => buildErrorImage(),
      ),
    );
  } catch (e) {
    // Fallback for old URL-based images
    return Image.network(
      imagePath,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => buildErrorImage(),
    );
  }
}



// Widget buildErrorImage() {
//   return Container(
//     height: 220,
//     width: double.infinity,
//     alignment: Alignment.center,
//     decoration: BoxDecoration(
//       color: Colors.grey[300],
//       borderRadius: BorderRadius.circular(16),
//     ),
//     child: const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
//   );
// }
Widget buildErrorImage() {
  return Container(
    height: 220,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Center(
      child: Text(
        'Select an image',
        style: TextStyle(color: Colors.grey),
      ),
    ),
  );
}

// Widget buildStatusPill(String status) {
//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//     decoration: BoxDecoration(
//       color: getStatusColor(status),
//       borderRadius: BorderRadius.circular(16),
//     ),
//     child: Text(
//       IssueStatusExtension.fromString(status).label,
//       style: const TextStyle(color: Colors.white, fontSize: 12),
//     ),
//   );
// }
Widget buildStatusPill(String status) {
  final color = getStatusColor(status);
  return AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(getStatusIcon(status), color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          status[0].toUpperCase() + status.substring(1),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.8,
          ),
        ),
      ],
    ),
  );
}




Widget buildSectionHeader(String title) {
  return Row(
    children: [
      Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 16)),
    ],
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


bool hasValidImage(String? url) => url != null && url.trim().isNotEmpty;

Widget buildIssueImage(String? imagePath) {
  if (imagePath == null || imagePath.trim().isEmpty) {
    return _placeholderImageWidget();
  }

  final isNetwork = imagePath.startsWith('http');

  if (isNetwork) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _brokenImageWidget();
        },
      ),
    );
  } else {
    final file = File(imagePath);
    if (!file.existsSync()) {
      return _brokenImageWidget();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _brokenImageWidget();
        },
      ),
    );
  }
}

Widget _placeholderImageWidget() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, size: 40),
    );

Widget _brokenImageWidget() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
    );
