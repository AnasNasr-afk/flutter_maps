// Keep all your imports
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../business_logic/userReportsCubit/user_reports_cubit.dart';
import '../../business_logic/userReportsCubit/user_reports_states.dart';
import '../../data/models/issue_model.dart';

class UserReportsScreen extends StatefulWidget {
  const UserReportsScreen({super.key});

  @override
  State<UserReportsScreen> createState() => _UserReportsScreenState();
}

class _UserReportsScreenState extends State<UserReportsScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UserReportsCubit>().loadUserReportedIssues(userId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
            title: const Text(
              'My Reports',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (userId != null) {
            await context
                .read<UserReportsCubit>()
                .loadUserReportedIssues(userId);
          }
        },
        child: BlocBuilder<UserReportsCubit, UserReportsStates>(
          builder: (context, state) {
            if (state is UserReportsLoadedState) {
              final issues = state.issues;

              if (issues.isEmpty) {
                return const Center(child: Text('No reports found.'));
              }

              return Padding(
                padding: EdgeInsets.all(12.w),
                child: ListView.separated(
                  itemCount: issues.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    final status = issue['status'] ?? 'pending';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      elevation: 4,
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                buildSectionHeader('Category'),
                                const Spacer(),
                                buildStatusPill(status),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              issue['category'] ?? 'Unknown',
                              style: TextStyle(fontSize: 15.sp),
                            ),

                            /// Description
                            SizedBox(height: 16.h),
                            buildSectionHeader('Description'),
                            SizedBox(height: 6.h),
                            Text(
                              (issue['description']
                                          ?.toString()
                                          .trim()
                                          .isNotEmpty ??
                                      false)
                                  ? issue['description']
                                  : 'No description provided.',
                              style: TextStyle(fontSize: 14.sp, height: 1.4.h),
                            ),

                            /// Attached Image
                            SizedBox(height: 16.h),
                            buildSectionHeader('Attached Image'),
                            SizedBox(height: 6.h),
                            buildIssueImage(
                                context, issue['image']?.toString()),

                            /// Admin Resolved Image
                            if (issue['adminResolvedImage'] != null) ...[
                              SizedBox(height: 16.h),
                              buildSectionHeader('Resolved Image'),
                              SizedBox(height: 6.h),
                              buildIssueImage(context,
                                  issue['adminResolvedImage']?.toString()),
                            ],

                            /// User Info
                            SizedBox(height: 16.h),
                            buildSectionHeader('Submitted By'),
                            SizedBox(height: 6.h),
                            Text(
                                'Name: ${issue['userName']?.toString().isNotEmpty == true ? issue['userName'] : 'Unknown'}'),
                            Text(
                                'Email: ${issue['userEmail']?.toString().isNotEmpty == true ? issue['userEmail'] : 'Unknown'}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is UserReportsErrorState) {
              return const Center(child: Text('Failed to load reports.'));
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
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
      return const Text(
        'No image available',
        style: TextStyle(color: Colors.grey),
      );
    }

    Widget imageWidget;

    try {
      final bytes = base64Decode(image);
      imageWidget = Image.memory(
        bytes,
        height: 200.h,
        width: double.infinity.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Text(
          'Failed to load image',
          style: TextStyle(color: Colors.red),
        ),
      );
    } catch (e) {
      imageWidget = Image.network(
        image,
        height: 200.h,
        width: double.infinity.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Text(
          'Failed to load image',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(12.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
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
}
