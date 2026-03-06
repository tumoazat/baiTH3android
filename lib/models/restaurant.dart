class Restaurant {
  final String id;
  final String name;
  final double rating;
  final String category;
  final String address;
  final String imageUrl;
  final String cuisine;
  final String description;
  final String phone;
  final String openTime;

  const Restaurant({
    required this.id,
    required this.name,
    required this.rating,
    required this.category,
    required this.address,
    required this.imageUrl,
    required this.cuisine,
    required this.description,
    required this.phone,
    required this.openTime,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      rating: (json['rating'] ?? json['stars'] ?? 0).toDouble(),
      category: json['category']?.toString() ?? json['type']?.toString() ?? '',
      address: json['address']?.toString() ?? json['location']?.toString() ?? '',
      imageUrl: json['image']?.toString() ??
          json['thumbnail']?.toString() ??
          json['imageUrl']?.toString() ??
          '',
      cuisine: json['cuisine']?.toString() ?? json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      openTime: json['openTime']?.toString() ??
          json['open_time']?.toString() ??
          '08:00 - 22:00',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rating': rating,
        'category': category,
        'address': address,
        'imageUrl': imageUrl,
        'cuisine': cuisine,
        'description': description,
        'phone': phone,
        'openTime': openTime,
      };
}
