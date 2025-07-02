import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserHeaderWithClose extends StatelessWidget {
  final String name;
  final DateTime createdAt;

  const UserHeaderWithClose({
    super.key,
    required this.name,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name.isEmpty ? 'Unknown' : name,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              timeago.format(createdAt, locale: 'en_short'),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.close, size: 24.w),
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
