import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../helpers/components.dart'; // ⬅️ Import where getStatusColor() is defined

class MapLegendWindow extends StatelessWidget {
  const MapLegendWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Map<String, Color> statusColors = {
      'Search Marker': Colors.deepPurple, // default marker
      'Pending': getStatusColor('pending'),
      'In Progress': getStatusColor('inProgress'),
      'Resolved': getStatusColor('resolved'),
      'Rejected': getStatusColor('rejected'),
    };

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.white24 : Colors.black26,
            blurRadius: 6.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: statusColors.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Row(
              children: [
                Container(
                  width: 14.w,
                  height: 14.h,
                  margin: EdgeInsets.only(top: 2.h),
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
