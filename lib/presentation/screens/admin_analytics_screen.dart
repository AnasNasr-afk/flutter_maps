import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/helpers/components.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../helpers/color_manager.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStats();
  }

  Future<Map<String, dynamic>> _fetchStats() async {
    final snapshot = await FirebaseFirestore.instance.collection('issues').get();

    final statusCounts = <String, int>{};
    final categoryCounts = <String, int>{};

    for (final doc in snapshot.docs) {
      final status = doc['status'] ?? 'unknown';
      final category = doc['category'] ?? 'unknown';

      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    return {
      'statusCounts': statusCounts,
      'categoryCounts': categoryCounts,
      'total': snapshot.size,
    };
  }

  Future<void> _refreshData() async {
    setState(() {
      _statsFuture = _fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ColorManager.gradientStart, ColorManager.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Admin Analytics',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22.sp,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              )
            );
          }

          final data = snapshot.data ?? {};
          final statusCounts = data['statusCounts'] as Map<String, int>;
          final categoryCounts = data['categoryCounts'] as Map<String, int>;
          final total = data['total'] ?? 0;

          return RefreshIndicator(
            backgroundColor: Colors.white,
            color: ColorManager.mainBlue,
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCard(total, statusCounts),
                  SizedBox(height: 20.h),
                  _buildChartCard('Issue Status Overview', statusCounts, Colors.deepPurple),
                  SizedBox(height: 24.h),
                  _buildChartCard('Issue Categories', categoryCounts, Colors.teal),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(int total, Map<String, int> statusCounts) {
    final pending = statusCounts['pending'] ?? 0;
    final inProgress = statusCounts['inProgress'] ?? 0;
    final resolved = statusCounts['resolved'] ?? 0;
    final rejected = statusCounts['rejected'] ?? 0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Total Issues: $total',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _buildStatusRow('Pending', pending, Colors.orange),
          _buildStatusRow('In Progress', inProgress, Colors.blue),
          _buildStatusRow('Resolved', resolved, Colors.green),
          _buildStatusRow('Rejected', rejected, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Map<String, int> dataMap, Color barColor) {
    final keys = dataMap.keys.toList();
    final values = dataMap.values.map((e) => e.toDouble()).toList();
    final maxY = (values.isEmpty ? 0 : values.reduce(max)) + 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: barColor),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 220.h,
            child: BarChart(
              BarChartData(
                maxY: maxY.toDouble(),
                barGroups: List.generate(
                  dataMap.length,
                      (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: dataMap[keys[i]]!.toDouble(),
                        color: barColor,
                        width: 18.w,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6.r),
                          topRight: Radius.circular(6.r),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY.toDouble(),
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28.w,
                      getTitlesWidget: (value, _) => Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey[700]),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < keys.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 6.h),
                            child: Text(
                              keys[index],
                              style: TextStyle(fontSize: 10.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
