import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meal.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/translation_provider.dart';
import '../../services/api/meal_api_service.dart';
import '../../services/translation_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../utils/constants.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;
  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final MealApiService _service = MealApiService();
  Meal? _meal;
  bool _isLoading = true;
  String _errorMessage = '';
  String? _instructionsVi; // Tiếng Việt
  String? _instructionsEn; // Tiếng Anh (gốc từ API)
  bool _isTranslating = false; // Loading state cho translation

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final meal = await _service.fetchMealDetail(widget.mealId);
      if (mounted) {
        setState(() {
          _meal = meal;
          _instructionsEn = meal?.instructions; // API trả về tiếng Anh
        });
        // Dịch sang Tiếng Việt tự động khi load chi tiết
        if (meal != null && meal.instructions.isNotEmpty) {
          _translateInstructionsToVietnamese(meal.instructions);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _translateInstructionsToVietnamese(String instructions) async {
    if (_instructionsVi != null) return; // Đã dịch rồi
    
    setState(() => _isTranslating = true);
    try {
      final translated =
          await TranslationService.translateToVietnamese(instructions);
      if (mounted) {
        setState(() {
          _instructionsVi = translated;
          _isTranslating = false;
        });
      }
    } catch (e) {
      print('Translation error: $e');
      // Fallback: Sử dụng tiếng Anh nếu dịch thất bại
      if (mounted) {
        setState(() => _isTranslating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final favProv = context.watch<FavoritesProvider>();
    final transProv = context.watch<TranslationProvider>();
    final isFav = _meal != null && favProv.isFavorite(_meal!.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Scaffold(body: LoadingWidget(message: 'Đang tải...'))
          : _errorMessage.isNotEmpty
              ? Scaffold(
                  appBar: AppBar(backgroundColor: Colors.orange),
                  body: AppErrorWidget(
                    message: _errorMessage,
                    onRetry: _fetchDetail,
                  ),
                )
              : _meal == null
                  ? const Scaffold(
                      body: Center(child: Text('Không tìm thấy món ăn.')))
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 280,
                          pinned: true,
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          flexibleSpace: FlexibleSpaceBar(
                            title: Text(
                              _meal!.name,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            background: _meal!.thumbnailUrl.isNotEmpty
                                ? Image.network(
                                    _meal!.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(color: Colors.orange[100]),
                                  )
                                : Container(color: Colors.orange[100]),
                          ),
                          actions: [
                            IconButton(
                              icon: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (!auth.isLoggedIn) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Đăng nhập để lưu yêu thích!')),
                                  );
                                  return;
                                }
                                if (isFav) {
                                  final fav = favProv.getFavorite(_meal!.id);
                                  if (fav != null) {
                                    favProv.removeFavorite(fav.id);
                                  }
                                } else {
                                  favProv.addFavorite(
                                    userId: auth.user!.uid,
                                    itemId: _meal!.id,
                                    itemType: AppConstants.typeMeal,
                                    itemName: _meal!.name,
                                    itemImageUrl: _meal!.thumbnailUrl,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (_meal!.category.isNotEmpty)
                                      Chip(
                                        label: Text(_meal!.category),
                                        backgroundColor: Colors.orange[100],
                                      ),
                                    const SizedBox(width: 8),
                                    if (_meal!.area.isNotEmpty)
                                      Chip(
                                        label: Text(_meal!.area),
                                        backgroundColor: Colors.blue[100],
                                      ),
                                  ],
                                ),
                                if (_meal!.tags.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tags: ${_meal!.tags}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                                const Divider(height: 24),
                                const Text(
                                  'Nguyên liệu',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ..._meal!.ingredients
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final i = entry.key;
                                  final ingredient = entry.value;
                                  final measure = i < _meal!.measures.length
                                      ? _meal!.measures[i]
                                      : '';
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.fiber_manual_record,
                                            size: 8, color: Colors.orange),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Consumer<TranslationProvider>(
                                            builder: (context, transProv, _) {
                                              final displayIngredient = transProv
                                                      .isEnglish
                                                  ? (transProv.getDisplayText(
                                                      ingredient))
                                                  : ingredient;
                                              return Text(
                                                measure.isNotEmpty
                                                    ? '$measure $displayIngredient'
                                                    : displayIngredient,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Hướng dẫn nấu ăn',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: [
                                        if (_isTranslating)
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        else if (_instructionsVi != null &&
                                            _instructionsEn != null)
                                          SegmentedButton<bool>(
                                            segments: const [
                                              ButtonSegment(
                                                  label: Text('VI'),
                                                  value: false),
                                              ButtonSegment(
                                                  label: Text('EN'),
                                                  value: true),
                                            ],
                                            selected: {transProv.isEnglish},
                                            onSelectionChanged: (Set<bool> s) {
                                              transProv.toggleLanguage();
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  transProv.isEnglish
                                      ? (_instructionsEn ?? _meal!.instructions)
                                      : (_instructionsVi ?? _meal!.instructions),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.6),
                                ),
                                if (_isTranslating)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Đang dịch sang Tiếng Việt...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
