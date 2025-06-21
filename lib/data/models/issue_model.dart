import 'package:flutter/material.dart';

enum IssueStatus { pending, inProgress, resolved, rejected }

extension IssueStatusExtension on IssueStatus {
  String get label {
    switch (this) {
      case IssueStatus.pending:
        return 'Pending';
      case IssueStatus.inProgress:
        return 'In Progress';
      case IssueStatus.resolved:
        return 'Resolved';
      case IssueStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case IssueStatus.pending:
        return Colors.orange;
      case IssueStatus.inProgress:
        return Colors.blue;
      case IssueStatus.resolved:
        return Colors.green;
      case IssueStatus.rejected:
        return Colors.redAccent;
    }
  }

  static IssueStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'inprogress':
        return IssueStatus.inProgress;
      case 'resolved':
        return IssueStatus.resolved;
      case 'rejected':
        return IssueStatus.rejected;
      default:
        return IssueStatus.pending;
    }
  }
}

class IssueModel {
  final String userName;
  final String uId;
  final String category;
  final String description;
  final String location;
  final String image;
  final String userEmail;
  final IssueStatus status;
  final String? adminResolutionImage; // Added for admin image

  IssueModel({
    required this.userName,
    required this.uId,
    required this.category,
    required this.description,
    required this.location,
    required this.image,
    required this.userEmail,
    required this.status,
    this.adminResolutionImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'uId': uId,
      'category': category,
      'description': description,
      'location': location,
      'image': image,
      'userEmail': userEmail,
      'status': status.name,
      if (adminResolutionImage != null) 'adminResolutionImage': adminResolutionImage,
    };
  }

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      userName: json['userName'],
      uId: json['uId'],
      category: json['category'],
      description: json['description'],
      location: json['location'],
      image: json['image'],
      userEmail: json['userEmail'],
      status: IssueStatusExtension.fromString(json['status']),
      adminResolutionImage: json['adminResolutionImage'],
    );
  }
}