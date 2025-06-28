import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../business_logic/userReportsCubit/user_reports_cubit.dart';
import '../../business_logic/userReportsCubit/user_reports_states.dart';
import '../../data/models/issue_model.dart';
import '../../business_logic/mapCubit/map_cubit.dart'; // <-- import your MapCubit

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
  // @override
  // void dispose() {
  //   context.read<MapCubit>().refreshMarkers();
  //   super.dispose();
  // }

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
              'Reported Issues',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: BlocBuilder<UserReportsCubit, UserReportsStates>(
        builder: (context, state) {
          if (state is UserReportsLoadingState || state is UserReportsInitialState) {
            return const Center(child: CircularProgressIndicator());
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
                            Text(issue['category'] ?? 'Unknown', style: TextStyle(fontSize: 15.sp)),
                            SizedBox(height: 16.h),
                            buildSectionHeader('Description'),
                            SizedBox(height: 6.h),
                            Text(
                              (issue['description']?.toString().trim().isNotEmpty ?? false)
                                  ? issue['description']
                                  : 'No description provided.',
                              style: TextStyle(fontSize: 14.sp, height: 1.4.h),
                            ),
                            SizedBox(height: 16.h),
                            buildSectionHeader('Attached Image'),
                            SizedBox(height: 6.h),
                            buildIssueImage(context, issue['image']?.toString()),
                            if (issue['adminResolvedImage'] != null && issue['adminResolvedImage'].toString().isNotEmpty) ...[
                              SizedBox(height: 16.h),
                              buildSectionHeader('Resolved Image'),
                              SizedBox(height: 6.h),
                              buildIssueImage(context, issue['adminResolvedImage']?.toString()),
                            ],
                            SizedBox(height: 16.h),
                            buildSectionHeader('Submitted By'),
                            SizedBox(height: 6.h),
                            Text('Name: ${issue['userName'] ?? 'Unknown'}'),
                            Text('Email: ${issue['userEmail'] ?? 'Unknown'}'),
                            if (isAdmin) ...[
                              SizedBox(height: 16.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      // Show confirm dialog before deleting
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: const Text('Confirm Deletion'),
                                          content: const Text('Are you sure you want to delete this issue? This action cannot be undone.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Cancel' , style: TextStyle(color: Colors.grey),),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              onPressed: ()  {
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text('Delete' , style: TextStyle(color: Colors.white)),
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
                                        // Update map markers after deletion
                                        context.read<MapCubit>().refreshMarkers();
                                      }
                                    },
                                  )
                                ],
                              )
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
          return const SizedBox(); // fallback
        },
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