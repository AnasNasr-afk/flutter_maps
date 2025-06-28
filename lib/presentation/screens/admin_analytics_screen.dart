import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.amber, Colors.orange],
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
            title: Text(
              '📊 Admin Analytics',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          final statusCounts = data['statusCounts'] as Map<String, int>;
          final categoryCounts = data['categoryCounts'] as Map<String, int>;
          final total = data['total'] ?? 0;

          return SingleChildScrollView(
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
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(int total, Map<String, int> statusCounts) {
    final pending = statusCounts['pending'] ?? 0;
    final inProgress = statusCounts['inProgress'] ?? 0;
    final resolved = statusCounts['resolved'] ?? 0;

    return Container(
      padding: EdgeInsets.all(16.w),
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
        children: [
          _buildStatRow('Total Issues', total, Colors.orange),
          Divider(thickness: 1.h),
          _buildStatRow('Pending', pending, Colors.redAccent),
          _buildStatRow('In Progress', inProgress, Colors.amber),
          _buildStatRow('Resolved', resolved, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(Icons.circle, size: 12.sp, color: color),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(fontSize: 14.sp)),
          const Spacer(),
          Text(
            count.toString(),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
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
          Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
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
                        width: 14.w,
                        borderRadius: BorderRadius.circular(4.r),
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
                      reservedSize: 30.w,
                      getTitlesWidget: (value, _) {
                        if (value % 1 == 0) {
                          return Padding(
                            padding: EdgeInsets.only(right: 4.w),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 10.sp),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
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
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                keys[index],
                                style: TextStyle(fontSize: 10.sp),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),

                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 0.5.w,
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
