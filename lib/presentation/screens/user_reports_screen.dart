import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business_logic/userReportsCubit/user_reports_cubit.dart';
import '../../business_logic/userReportsCubit/user_reports_states.dart';

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
      Future.microtask(() =>
          context.read<UserReportsCubit>().loadUserReportedIssues(userId!));
    }
  }
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
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
    await context
        .read<UserReportsCubit>()
        .loadUserReportedIssues(userId!);
    },
        child: BlocBuilder<UserReportsCubit, UserReportsStates>(
          builder: (context, state) {
            if (state is UserReportsLoadedState) {
              final issues = state.issues;

              if (issues.isEmpty) {
                return const Center(child: Text('No reports found.'));
              }

              return Padding(
                padding: const EdgeInsets.all(20),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: issues.length,
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      color: Colors.grey[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Leading Icon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.warning_amber_rounded,
                                  color: Colors.deepOrange, size: 30),
                            ),

                            const SizedBox(width: 16),

                            // Main content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Category title
                                  Text(
                                    issue['category'] ?? 'Unknown Issue',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  // Description
                                  Text(
                                    issue['description'] ?? 'No description provided.',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Status badge
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(issue['status'] ?? 'Pending'),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      issue['status']?.toUpperCase() ?? 'PENDING',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Trailing arrow
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                // Navigate to detail view
                              },
                            ),
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
}
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'resolved':
      return Colors.green;
    case 'in progress':
      return Colors.blue;
    case 'rejected':
      return Colors.redAccent;
    default:
      return Colors.orange;
  }
}
