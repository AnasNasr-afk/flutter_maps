import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChangeStatusSlider extends StatelessWidget {
  final String selectedStatus;
  final List<String> statusOptions;
  final bool isFinalized;
  final Color Function(String) getStatusColor;
  final void Function(String) onStatusChanged;

  const ChangeStatusSlider({
    super.key,
    required this.selectedStatus,
    required this.statusOptions,
    required this.isFinalized,
    required this.getStatusColor,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Change Status',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        CupertinoSlidingSegmentedControl<String>(
          groupValue: selectedStatus,
          backgroundColor: Colors.grey.shade200,
          thumbColor: getStatusColor(selectedStatus),
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 1.w),
          children: {
            for (var status in statusOptions)
              status: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: status == selectedStatus
                        ? Colors.white
                        : getStatusColor(status),
                  ),
                ),
              ),
          },
          onValueChanged: isFinalized
              ? (s){}
              : (String? value) {
            if (value != null) {
              onStatusChanged(value); // Let parent handle state update
            }
          },
        ),
      ],
    );
  }
}
