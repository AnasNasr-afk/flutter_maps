import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IssueCategoryAndDescription extends StatelessWidget {
  final String? category;
  final String? description;

  const IssueCategoryAndDescription({
    super.key,
    required this.category,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final String categoryText = (category == null || category!.isEmpty)
        ? 'Unknown'
        : category![0].toUpperCase() + category!.substring(1);

    final String descriptionText = (description == null || description!.isEmpty)
        ? 'No description provided'
        : description!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryText,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          descriptionText,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black87,
            overflow: TextOverflow.ellipsis,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
