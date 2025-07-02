import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SideBySideScreenshots extends StatelessWidget {
  const SideBySideScreenshots({super.key});

  // URLs for the before and after images
  static const String beforeImageUrl = 'https://github.com/user-attachments/assets/2f2c8d59-2420-4e0d-9343-e1ca4014cadc';
  static const String afterImageUrl = 'https://github.com/user-attachments/assets/8c807979-d289-4743-b432-d44cfc93c423';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // Before Image
          Expanded(
            child: _buildImageContainer(
              context: context,
              imageUrl: beforeImageUrl,
              label: 'Before',
            ),
          ),
          SizedBox(width: 16.w),
          // After Image
          Expanded(
            child: _buildImageContainer(
              context: context,
              imageUrl: afterImageUrl,
              label: 'After',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer({
    required BuildContext context,
    required String imageUrl,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: AspectRatio(
            aspectRatio: 1.0, // This ensures equal width and height
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.orange,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 32.w,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Failed to load image',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}