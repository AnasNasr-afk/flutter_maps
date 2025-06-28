import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'user_reports_states.dart';

class UserReportsCubit extends Cubit<UserReportsStates> {
  UserReportsCubit() : super(UserReportsInitialState());

  static UserReportsCubit get(context) => BlocProvider.of(context);

  Future<void> initializeReports(String userId) async {
    emit(UserReportsLoadingState());
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final isAdmin = doc.exists && doc.data()?['role'] == 'admin';
      if (isAdmin) {
        await _loadAllReportedIssues(isAdmin: true);
      } else {
        await _loadUserReportedIssues(userId, isAdmin: false);
      }
    } catch (e) {
      debugPrint('[InitializeReports] ❌ $e');
      emit(UserReportsErrorState(message: 'Failed to initialize reports.'));
    }
  }

  Future<void> refreshReports(String userId, bool isAdmin) async {
    emit(UserReportsLoadingState());
    if (isAdmin) {
      await _loadAllReportedIssues(isAdmin: true);
    } else {
      await _loadUserReportedIssues(userId, isAdmin: false);
    }
  }

  Future<void> _loadUserReportedIssues(String userId, {required bool isAdmin}) async {
    debugPrint('[ReportedIssues] 🔄 Fetching user-reported issues...');
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('issues')
          .where('uId', isEqualTo: userId)
          .get();

      final List<Map<String, dynamic>> userIssues = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final location = data['location']?.toString();

        if (data.containsKey('category') && location != null) {
          final parts = location.split(',');
          if (parts.length == 2) {
            final lat = double.tryParse(parts[0]);
            final lng = double.tryParse(parts[1]);
            if (lat != null && lng != null) {
              userIssues.add({
                'id': doc.id,
                'category': data['category'],
                'image': data['image'],
                'status': data['status'],
                'userName': data['userName'],
                'userEmail': data['userEmail'],
                'lat': lat,
                'lng': lng,
                'description': data['description'] ?? '',
                'adminResolvedImage': data['adminResolvedImage'] ?? '',
              });
            }
          }
        }
      }
      emit(UserReportsLoadedState(issues: userIssues, isAdmin: isAdmin));
    } catch (e) {
      debugPrint('[ReportedIssues] ❌ Failed to fetch: $e');
      emit(UserReportsErrorState(message: 'Failed to fetch user reports.'));
    }
  }

  Future<void> _loadAllReportedIssues({required bool isAdmin}) async {
    debugPrint('[AllIssues] 🔄 Fetching all reported issues...');
    try {
      final snapshot = await FirebaseFirestore.instance.collection('issues').get();
      final List<Map<String, dynamic>> allIssues = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final location = data['location']?.toString();

        if (data.containsKey('category') && location != null) {
          final parts = location.split(',');
          if (parts.length == 2) {
            final lat = double.tryParse(parts[0]);
            final lng = double.tryParse(parts[1]);
            if (lat != null && lng != null) {
              allIssues.add({
                'id': doc.id,
                'category': data['category'],
                'image': data['image'],
                'status': data['status'],
                'userName': data['userName'],
                'userEmail': data['userEmail'],
                'lat': lat,
                'lng': lng,
                'description': data['description'] ?? '',
                'adminResolvedImage': data['adminResolvedImage'] ?? '',
              });
            }
          }
        }
      }
      emit(UserReportsLoadedState(issues: allIssues, isAdmin: isAdmin));
    } catch (e) {
      debugPrint('[AllIssues] ❌ Failed to fetch: $e');
      emit(UserReportsErrorState(message: 'Failed to fetch all reports.'));
    }
  }

  Future<void> deleteIssue(String issueId, String userId, bool isAdmin) async {
    try {
      await FirebaseFirestore.instance.collection('issues').doc(issueId).delete();
      debugPrint('🗑️ Issue $issueId deleted');
      if (isAdmin) {
        await _loadAllReportedIssues(isAdmin: isAdmin);
      } else {
        await _loadUserReportedIssues(userId, isAdmin: isAdmin);
      }
    } catch (e) {
      debugPrint('❌ Failed to delete issue: $e');
      emit(UserReportsErrorState(message: 'Failed to delete issue.'));
    }
  }
}