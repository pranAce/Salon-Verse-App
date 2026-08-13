class ReviewModel {
  final String id;
  final String salonId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.salonId,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final u = json['user'] ?? json['customer'];
    String uName = 'Customer';
    String uAvatar = '';
    String uId = '';

    if (u is Map) {
      uId = (u['_id'] ?? u['id'] ?? '').toString();
      uName = u['name'] ?? 'Customer';
      uAvatar = u['avatar'] ?? u['imageUrl'] ?? '';
    } else if (u != null) {
      uId = u.toString();
    }

    return ReviewModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      salonId: (json['salonId'] ?? json['salon'])?.toString() ?? '',
      userId: uId.isNotEmpty ? uId : (json['userId']?.toString() ?? ''),
      userName: json['userName'] ?? uName,
      userAvatar: json['userAvatar'] ?? uAvatar,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment'] ?? json['content'] ?? json['feedback'] ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salonId': salonId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}
