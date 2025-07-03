import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/helpers/components.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../business_logic/userReportsCubit/user_reports_cubit.dart';
import '../../business_logic/userReportsCubit/user_reports_states.dart';
import '../../business_logic/mapCubit/map_cubit.dart';
import '../../data/models/issue_model.dart';
import '../../helpers/color_manager.dart';

class UserReportsScreen extends StatefulWidget {
  const UserReportsScreen({super.key});

  @override
  State<UserReportsScreen> createState() => _UserReportsScreenState();
}

class _UserReportsScreenState extends State<UserReportsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      context.read<UserReportsCubit>().initializeReports(user!.uid);
    }
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
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Reported Issues',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: BlocBuilder<UserReportsCubit, UserReportsStates>(
        builder: (context, state) {
          if (state is UserReportsLoadingState || state is UserReportsInitialState) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue,));
          }
          if (state is UserReportsErrorState) {
            return Center(child: Text(state.message ?? 'Failed to load reports.'));
          }
          if (state is UserReportsLoadedState) {
            final issues = state.issues;
            final isAdmin = state.isAdmin;

            return RefreshIndicator(
              onRefresh: () async {
                if (user != null) {
                  await context.read<UserReportsCubit>().refreshReports(user!.uid, isAdmin);
                }
              },
              child: issues.isEmpty
                  ? const Center(child: Text('No reports found.'))
                  : Padding(
                padding: EdgeInsets.all(12.w),
                child: ListView.separated(
                  itemCount: issues.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    final status = issue['status'] ?? 'pending';

                    /// Time Handling
                    final rawTimestamp = issue['timestamp'];
                    DateTime? createdAt;
                    if (rawTimestamp is Timestamp) {
                      createdAt = rawTimestamp.toDate();
                    } else if (rawTimestamp is String) {
                      try {
                        createdAt = DateTime.parse(rawTimestamp);
                      } catch (_) {}
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Header
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  issue['category'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              buildStatusPill(status),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          if (createdAt != null)
                            Text(
                              'Reported ${formatDate(createdAt)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          SizedBox(height: 12.h),

                          /// Description
                          Text(
                            issue['description']?.toString().trim().isNotEmpty ?? false
                                ? issue['description']
                                : 'No description provided.',
                            style: TextStyle(fontSize: 14.sp, height: 1.4),
                          ),

                          /// Image Before
                          if (issue['image'] != null && issue['image'].toString().isNotEmpty)
                            ...[
                              SizedBox(height: 12.h),
                              Text('Attached Image', style: _sectionHeaderStyle()),
                              SizedBox(height: 8.h),
                              buildIssueImage(context, issue['image']),
                            ],

                          /// Image After
                          if (issue['adminResolvedImage'] != null &&
                              issue['adminResolvedImage'].toString().isNotEmpty)
                            ...[
                              SizedBox(height: 12.h),
                              Text('Resolved Image', style: _sectionHeaderStyle()),
                              SizedBox(height: 8.h),
                              buildIssueImage(context, issue['adminResolvedImage']),
                            ],

                          /// User info
                          SizedBox(height: 12.h),
                          Text('Submitted by', style: _sectionHeaderStyle()),
                          SizedBox(height: 4.h),
                          Text(
                            issue['userName'] ?? 'Unknown',
                            style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                          ),
                          Text(
                            issue['userEmail'] ?? 'Unknown',
                            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                          ),

                          /// Admin Controls
                          if (isAdmin) ...[
                            SizedBox(height: 12.h),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm Deletion'),
                                      content: const Text(
                                          'Are you sure you want to delete this issue?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await context.read<UserReportsCubit>().deleteIssue(
                                      issue['id'],
                                      user!.uid,
                                      isAdmin,
                                    );
                                    context.read<MapCubit>().refreshMarkers();
                                  }
                                },
                              ),
                            )
                          ]
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget buildStatusPill(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: getStatusColor(status),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        IssueStatusExtension.fromString(status).label,
        style: TextStyle(color: Colors.white, fontSize: 12.sp),
      ),
    );
  }

  Color getStatusColor(String status) {
    return IssueStatusExtension.fromString(status).color;
  }

  Widget buildIssueImage(BuildContext context, String? image) {
    if (image == null || image.isEmpty) {
      return const Text('No image available', style: TextStyle(color: Colors.grey));
    }

    Widget imageWidget;
    try {
      final bytes = base64Decode(image);
      imageWidget = Image.memory(
        bytes,
        height: 180.h,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } catch (_) {
      imageWidget = Image.network(
        image,
        height: 180.h,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: imageWidget,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: imageWidget,
      ),
    );
  }

  String formatDate(DateTime time) {
    return '${time.day.toString().padLeft(2, '0')}/'
        '${time.month.toString().padLeft(2, '0')}/'
        '${time.year} ${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  TextStyle _sectionHeaderStyle() => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
}
