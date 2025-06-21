class IssueModel {
  final String userName;
  final String userEmail; // ✅ NEW
  final String uId;
  final String category;
  final String description;
  final String location;
  final String image;
  final String status; // ✅ NEW

  IssueModel({
    required this.userName,
    required this.userEmail, // ✅ NEW
    required this.uId,
    required this.category,
    required this.description,
    required this.location,
    required this.image,
    required this.status, // ✅ NEW
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'userEmail': userEmail, // ✅ NEW
      'uId': uId,
      'category': category,
      'description': description,
      'location': location,
      'image': image,
      'status': status, // ✅ NEW
    };
  }

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '', // ✅ NEW
      uId: json['uId'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? 'Pending', // ✅ NEW (default fallback)
    );
  }
}
