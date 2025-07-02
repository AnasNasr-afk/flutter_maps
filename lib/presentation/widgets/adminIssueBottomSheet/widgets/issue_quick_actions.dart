import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class IssueQuickActions extends StatelessWidget {
  final String email;
  final String location;
  final String docId;
  final String selectedStatus;
  final bool isFinalized;
  final bool isSaving;
  final bool hasResolvedImage;
  final bool isImageSaved;
  final dynamic resolvedImageFile;
  final Future<void> Function({
  required String docId,
  required String status,
  dynamic adminImage,
  }) onSave;

  const IssueQuickActions({
    super.key,
    required this.email,
    required this.location,
    required this.docId,
    required this.selectedStatus,
    required this.isFinalized,
    required this.isSaving,
    required this.hasResolvedImage,
    required this.resolvedImageFile,
    required this.isImageSaved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: 'Contact Reporter',
          child: OutlinedButton(
            onPressed: () => launchUrl(Uri.parse('mailto:$email')),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r)),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Icon(Icons.mail_outline, size: 20.w, color: Colors.black87),
          ),
        ),
        SizedBox(width: 8.w),
        Tooltip(
          message: 'Open in Google Maps',
          child: OutlinedButton(
            onPressed: () async {
              if (location.isEmpty || !location.contains(',')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid location')),
                );
                return;
              }

              final parts = location.split(',');
              final lat = parts[0].trim();
              final lng = parts[1].trim();
              final googleMapsUrl = Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=$lat,$lng');

              if (await canLaunchUrl(googleMapsUrl)) {
                await launchUrl(googleMapsUrl,
                    mode: LaunchMode.externalApplication);
              } else {
                debugPrint('❌ Could not launch Google Maps');
              }
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r)),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Icon(Icons.directions_outlined,
                size: 20.w, color: Colors.blue),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (isSaving || isFinalized)
                ? null
                : () async {
              if (selectedStatus == 'resolved' &&
                  !hasResolvedImage &&
                  resolvedImageFile == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please add a resolved image')),
                );
                return;
              }

              await onSave(
                docId: docId,
                status: selectedStatus,
                adminImage: selectedStatus == 'resolved'
                    ? resolvedImageFile
                    : null,
              );
            },
            icon: isSaving
                ? SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            )
                : Icon(Icons.save_outlined, size: 20.w),
            label: const Text('Save Status'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
