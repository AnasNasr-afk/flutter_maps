// Keep all your imports
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
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
            await context.read<UserReportsCubit>().loadUserReportedIssues(userId);
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
                padding: const EdgeInsets.all(12),
                child: ListView.separated(
                  itemCount: issues.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    final status = issue['status'] ?? 'pending';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Header
                            Row(
                              children: [
                                buildSectionHeader('Category'),
                                const Spacer(),
                                buildStatusPill(status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              issue['category'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 15),
                            ),

                            /// Description
                            const SizedBox(height: 16),
                            buildSectionHeader('Description'),
                            const SizedBox(height: 6),
                            Text(
                              (issue['description']?.toString().trim().isNotEmpty ?? false)
                                  ? issue['description']
                                  : 'No description provided.',
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),

                            /// Attached Image
                            const SizedBox(height: 16),
                            buildSectionHeader('Attached Image'),
                            const SizedBox(height: 6),
                            buildIssueImage(context, issue['image']?.toString()),

                            /// Admin Resolved Image
                            if (issue['adminResolvedImage'] != null) ...[
                              const SizedBox(height: 16),
                              buildSectionHeader('Resolved Image'),
                              const SizedBox(height: 6),
                              buildIssueImage(context, issue['adminResolvedImage']?.toString()),
                            ],

                            /// User Info
                            const SizedBox(height: 16),
                            buildSectionHeader('Submitted By'),
                            const SizedBox(height: 6),
                            Text('Name: ${issue['userName']?.toString().isNotEmpty == true ? issue['userName'] : 'Unknown'}'),
                            Text('Email: ${issue['userEmail']?.toString().isNotEmpty == true ? issue['userEmail'] : 'Unknown'}'),
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
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget buildStatusPill(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: getStatusColor(status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        IssueStatusExtension.fromString(status).label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
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
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Text(
          'Failed to load image',
          style: TextStyle(color: Colors.red),
        ),
      );
    } catch (e) {
      imageWidget = Image.network(
        image,
        height: 200,
        width: double.infinity,
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
            insetPadding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: imageWidget,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageWidget,
      ),
    );
  }
}
