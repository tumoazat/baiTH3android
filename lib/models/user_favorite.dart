class UserFavorite {
  final String id;
  final String userId;
  final String itemId;
  final String itemType;
  final String itemName;
  final String itemImageUrl;
  final DateTime createdAt;

  const UserFavorite({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemType,
    required this.itemName,
    required this.itemImageUrl,
    required this.createdAt,
  });

  factory UserFavorite.fromJson(Map<String, dynamic> json, String docId) {
    return UserFavorite(
      id: docId,
      userId: json['userId']?.toString() ?? '',
      itemId: json['itemId']?.toString() ?? '',
      itemType: json['itemType']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? '',
      itemImageUrl: json['itemImageUrl']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'itemId': itemId,
        'itemType': itemType,
        'itemName': itemName,
        'itemImageUrl': itemImageUrl,
        'createdAt': createdAt.toIso8601String(),
      };
}
