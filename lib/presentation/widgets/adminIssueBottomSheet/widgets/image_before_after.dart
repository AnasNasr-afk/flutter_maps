import 'dart:typed_data';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/business_logic/issueCubit/issue_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../helpers/components.dart';

class ImageBeforeAfter extends StatelessWidget {
  final String imagePath;
  final bool hasResolvedImage;
  final Uint8List? resolvedImageBytes;
  final String selectedStatus;
  final bool isImageSaved;
  final VoidCallback onImageCleared;
  final VoidCallback onImagePicked;

  const ImageBeforeAfter({
    super.key,
    required this.imagePath,
    required this.hasResolvedImage,
    required this.resolvedImageBytes,
    required this.selectedStatus,
    required this.isImageSaved,
    required this.onImageCleared,
    required this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = IssueCubit.get(context);
    final file = cubit.resolvedImageFile;
    final isResolved = selectedStatus == 'resolved';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // BEFORE Image
        GestureDetector(
          onTap: () {
            if (imagePath.isNotEmpty) {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.black,
                  insetPadding: EdgeInsets.all(10.w),
                  child: InteractiveViewer(
                    child: buildImage(context, imagePath),
                  ),
                ),
              );
            }
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: SizedBox(
                  height: 120.h,
                  width: 160.w,
                  child: imagePath.isNotEmpty
                      ? buildImage(context, imagePath)
                      : buildErrorImage(),
                ),
              ),
              Positioned(
                top: 0.h,
                left: 3.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Text(
                    'BEFORE',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // AFTER Image
        InkWell(
          onTap: () async {
            if (isImageSaved || hasResolvedImage || file != null) {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.black,
                  insetPadding: EdgeInsets.all(10.w),
                  child: InteractiveViewer(
                    child: file != null
                        ? Image.file(file, fit: BoxFit.contain)
                        : Image.memory(resolvedImageBytes!, fit: BoxFit.contain),
                  ),
                ),
              );
            } else if (isResolved) {
              showAdaptiveActionSheet(
                context: context,
                title: Text(
                  'Avoid uploading sensitive images',
                  style: TextStyle(fontSize: 12.sp),
                ),
                actions: <BottomSheetAction>[
                  BottomSheetAction(
                    title: Text('Take a photo', style: TextStyle(color: Colors.blue, fontSize: 18.sp)),
                    onPressed: (_) async {
                      Navigator.pop(context);
                      await cubit.pickResolvedImage(ImageSource.camera);
                      onImagePicked();
                    },
                  ),
                  BottomSheetAction(
                    title: Text('Choose from gallery', style: TextStyle(color: Colors.blue, fontSize: 18.sp)),
                    onPressed: (_) async {
                      Navigator.pop(context);
                      await cubit.pickResolvedImage(ImageSource.gallery);
                      onImagePicked();
                    },
                  ),
                ],
                cancelAction: CancelAction(
                  title: Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 18.sp)),
                ),
              );
            }
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: SizedBox(
                  height: 120.h,
                  width: 160.w,
                  child: () {
                    if (file != null) {
                      return Image.file(file, fit: BoxFit.cover);
                    } else if (hasResolvedImage && resolvedImageBytes != null) {
                      return Image.memory(resolvedImageBytes!, fit: BoxFit.cover);
                    } else if (isResolved) {
                      return Container(
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: Text(
                          'Tap to add image (Required)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.redAccent,
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        color: Colors.grey[100],
                        alignment: Alignment.center,
                        child: Text(
                          'Change status to "Resolved" to upload image',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black45,
                          ),
                        ),
                      );
                    }
                  }(),
                ),
              ),
              Positioned(
                top: 0.h,
                left: 3.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Text(
                    'AFTER',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (file != null && !isImageSaved)
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: onImageCleared,
                    child: CircleAvatar(
                      radius: 14.r,
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
