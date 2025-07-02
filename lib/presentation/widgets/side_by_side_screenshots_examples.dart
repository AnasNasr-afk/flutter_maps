import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_maps/presentation/widgets/side_by_side_screenshots.dart';

/// This file demonstrates different usage patterns for the SideBySideScreenshots widget
/// showing how it can be integrated into various parts of the application.

class SideBySideScreenshotsUsageExamples {
  
  /// Example 1: Basic usage in a simple container
  static Widget basicUsage() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const SideBySideScreenshots(),
    );
  }

  /// Example 2: Usage in a dialog for modal display
  static void showInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Compare Screenshots',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              const SideBySideScreenshots(),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Example 3: Usage in a bottom sheet
  static void showInBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Screenshot Comparison',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            const Expanded(
              child: SingleChildScrollView(
                child: SideBySideScreenshots(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Example 4: Usage in a Card widget for list view
  static Widget inCard({String? title}) {
    return Card(
      margin: EdgeInsets.all(8.w),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
            ],
            const SideBySideScreenshots(),
          ],
        ),
      ),
    );
  }

  /// Example 5: Usage in an ExpansionTile for collapsible content
  static Widget inExpansionTile() {
    return ExpansionTile(
      title: Text(
        'View Screenshot Comparison',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: const Icon(Icons.compare_arrows, color: Colors.orange),
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: const SideBySideScreenshots(),
        ),
      ],
    );
  }

  /// Example 6: Usage in a TabView for multiple comparisons
  static Widget inTabView() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(
                child: Text(
                  'Comparison 1',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
              Tab(
                child: Text(
                  'Comparison 2',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 400.h,
            child: const TabBarView(
              children: [
                SideBySideScreenshots(),
                SideBySideScreenshots(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Example 7: Usage with custom wrapper and actions
  static Widget withActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Screenshot Analysis',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.blue),
                    onPressed: () {
                      // Share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sharing screenshots...')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.green),
                    onPressed: () {
                      // Download functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading screenshots...')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const SideBySideScreenshots(),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showInDialog(context);
                  },
                  icon: const Icon(Icons.fullscreen),
                  label: const Text('Full View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showInBottomSheet(context);
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}