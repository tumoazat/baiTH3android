import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/restaurant.dart';
import '../../utils/constants.dart';

class RestaurantApiService {
  static const Duration _timeout = Duration(seconds: 10);

  Future<List<Restaurant>> fetchRestaurants() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConstants.restaurantBaseUrl}/restaurants'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is List) {
          return data
              .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        if (data is Map && data.containsKey('data')) {
          final list = data['data'] as List;
          return list
              .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      throw Exception('Lỗi kết nối: ${response.statusCode}');
    } catch (_) {
      return _mockRestaurants();
    }
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    final all = await fetchRestaurants();
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all
        .where((r) =>
            r.name.toLowerCase().contains(q) ||
            r.cuisine.toLowerCase().contains(q) ||
            r.category.toLowerCase().contains(q))
        .toList();
  }

  List<Restaurant> _mockRestaurants() {
    return [
      const Restaurant(
        id: '1',
        name: 'Phở Hà Nội 1946',
        rating: 4.8,
        category: 'Ẩm thực Việt',
        address: '25 Hàng Than, Hoàn Kiếm, Hà Nội',
        imageUrl:
            'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=400',
        cuisine: 'Việt Nam',
        description:
            'Quán phở truyền thống với hơn 70 năm lịch sử, nước dùng ninh từ xương bò trong 12 giờ.',
        phone: '024 3826 0123',
        openTime: '05:30 - 22:00',
      ),
      const Restaurant(
        id: '2',
        name: 'Bún Bò Huế Cô Hà',
        rating: 4.6,
        category: 'Ẩm thực Miền Trung',
        address: '12 Lê Lợi, Hải Châu, Đà Nẵng',
        imageUrl:
            'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400',
        cuisine: 'Việt Nam',
        description:
            'Bún bò Huế đậm đà hương vị cố đô, cay nồng đặc trưng miền Trung.',
        phone: '0236 3812 456',
        openTime: '06:00 - 21:00',
      ),
      const Restaurant(
        id: '3',
        name: 'Cơm Tấm Sài Gòn',
        rating: 4.5,
        category: 'Ẩm thực Miền Nam',
        address: '78 Võ Văn Tần, Quận 3, TP.HCM',
        imageUrl:
            'https://images.unsplash.com/photo-1547592180-85f173990554?w=400',
        cuisine: 'Việt Nam',
        description:
            'Cơm tấm sườn bì chả nổi tiếng Sài Gòn, phục vụ từ sáng sớm.',
        phone: '028 3930 2233',
        openTime: '05:00 - 23:00',
      ),
      const Restaurant(
        id: '4',
        name: 'Dimsum House',
        rating: 4.4,
        category: 'Ẩm thực Trung Hoa',
        address: '56 Nguyễn Trãi, Quận 5, TP.HCM',
        imageUrl:
            'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400',
        cuisine: 'Trung Hoa',
        description:
            'Nhà hàng dimsum chính gốc Hồng Kông với hơn 50 loại dimsum.',
        phone: '028 3855 9988',
        openTime: '07:00 - 22:00',
      ),
      const Restaurant(
        id: '5',
        name: 'Pizza Roma',
        rating: 4.3,
        category: 'Ẩm thực Ý',
        address: '15 Bà Triệu, Hai Bà Trưng, Hà Nội',
        imageUrl:
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
        cuisine: 'Ý',
        description:
            'Pizza nướng lò củi kiểu Napoli truyền thống, nguyên liệu nhập khẩu.',
        phone: '024 3943 8877',
        openTime: '10:00 - 22:30',
      ),
      const Restaurant(
        id: '6',
        name: 'Sushi Hanami',
        rating: 4.7,
        category: 'Ẩm thực Nhật',
        address: '30 Lê Thánh Tôn, Quận 1, TP.HCM',
        imageUrl:
            'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=400',
        cuisine: 'Nhật Bản',
        description:
            'Sushi và sashimi tươi sống hàng ngày, phong cách Omakase.',
        phone: '028 3827 4455',
        openTime: '11:00 - 22:00',
      ),
      const Restaurant(
        id: '7',
        name: 'Lẩu Thái Siam',
        rating: 4.2,
        category: 'Ẩm thực Thái',
        address: '88 Huỳnh Thúc Kháng, Đống Đa, Hà Nội',
        imageUrl:
            'https://images.unsplash.com/photo-1562802378-063ec186a863?w=400',
        cuisine: 'Thái Lan',
        description: 'Lẩu Thái cay xé miệng với nước dùng tom yum đặc trưng.',
        phone: '024 3736 2211',
        openTime: '10:30 - 23:00',
      ),
      const Restaurant(
        id: '8',
        name: 'Bánh Mì Phượng',
        rating: 4.9,
        category: 'Ẩm thực Việt',
        address: '2B Phan Chu Trinh, Hội An, Quảng Nam',
        imageUrl:
            'https://images.unsplash.com/photo-1509722747041-616f39b57569?w=400',
        cuisine: 'Việt Nam',
        description:
            'Bánh mì nổi tiếng nhất Hội An, được Anthony Bourdain ca ngợi.',
        phone: '0235 3861 603',
        openTime: '06:30 - 21:30',
      ),
    ];
  }
}
