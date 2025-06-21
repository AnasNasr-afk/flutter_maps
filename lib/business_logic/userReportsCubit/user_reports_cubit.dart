import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/userReportsCubit/user_reports_states.dart';


class UserReportsCubit extends Cubit<UserReportsStates>{

  UserReportsCubit() : super(UserReportsInitialState());

  static UserReportsCubit get(context) => BlocProvider.of(context);

  Future<void> loadUserReportedIssues(String userId) async {
    debugPrint('[ReportedIssues] 🔄 Fetching user-reported issues...');

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('issues')
          .where('uId', isEqualTo: userId)
          .get();

      final List<Map<String, dynamic>> userIssues = [];

      debugPrint('[ReportedIssues] 📦 Total user issues: ${snapshot.docs.length}');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('category') && data.containsKey('location')) {
          final location = data['location'];
          final parts = location.toString().split(',');

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
        } else {
          debugPrint('[ReportedIssues] ⚠️ Skipped: Missing category or location');
        }
      }



      emit(UserReportsLoadedState(userIssues));
    } catch (e) {
      debugPrint('[ReportedIssues] ❌ Failed to fetch: $e');
      emit(UserReportsErrorState());
    }
  }

}