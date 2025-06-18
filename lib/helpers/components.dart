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
                  Icon(Icons.privacy_tip_outlined, size: 32, color: Colors.orange),
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

void showModernAboutDialog(BuildContext context) {
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
                  ScaffoldMessenger.of(context).showSnackBar(
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
  final Uri phoneUri = Uri(scheme: 'tel', path: '+201024793905');
  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cannot place a call on this device.')),
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
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.loginScreen,
          (route) => false,
    );
  }
}


