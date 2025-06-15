class IssueModel {
  final String userName;
  final String uId;
  final String category;
  final String description;
  final String location;
  final String image;

  IssueModel({
    required this.userName,
    required this.uId,
    required this.category,
    required this.description,
    required this.location,
    required this.image,
  });


  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'uId': uId,
      'category': category,
      'description': description,
      'location': location,
      'image': image,
    };
  }


  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      userName: json['userName'] ?? '',
      uId: json['uId'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
