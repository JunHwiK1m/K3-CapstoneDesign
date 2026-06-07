import 'dart:convert';
import '../config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class StoreScreen extends StatefulWidget {
  final String token;
  const StoreScreen({super.key, required this.token});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  List<dynamic> _items = [];
  List<dynamic> _myItems = [];
  Set<int> _ownedItemIds = {};
  bool _isLoading = true;

  String _selectedFilter = '전체';
  final List<String> _filters = ['전체', 'THEME', 'BADGE', 'PERSONA'];

  // 백엔드의 영문 타입을 한글로 보여주기 위한 헬퍼 맵
  final Map<String, String> _typeToKorean = {
    'THEME': '테마',
    'BADGE': '배지',
    'PERSONA': '페르소나',
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    await Future.wait([_fetchItems(), _fetchMyItems()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchItems() async {
    if (widget.token.isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/items'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) setState(() => _items = body['data'] ?? []);
      }
    } catch (e) {
      debugPrint("Error fetching items: $e");
    }
  }

  Future<void> _fetchMyItems() async {
    if (widget.token.isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/items/my'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final data = body['data'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _myItems = data;
            _ownedItemIds = data.map<int>((e) => e['itemId'] as int).toSet();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching my items: $e");
    }
  }

  Future<void> _purchaseItem(int itemId, String name) async {
    if (widget.token.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/items/$itemId/purchase'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _fetchMyItems(); // Refresh owned items
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name 구매가 완료되었습니다! ✨'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('구매 실패: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error purchasing: $e");
    }
  }

  Future<void> _equipItem(int userItemId, String resourceUrl, String name) async {
    if (widget.token.isEmpty) return;
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/items/user-items/$userItemId/equip'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Change Theme globally
        final prefs = await SharedPreferences.getInstance();
        if (resourceUrl == 'theme_dark' || name == '다크 모드 테마') {
          themeNotifier.value = ThemeMode.dark;
          await prefs.setString('themeMode', 'dark');
        } else {
          themeNotifier.value = ThemeMode.light;
          await prefs.setString('themeMode', 'light');
        }
        _fetchMyItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name 장착 완료! ✨')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('장착 실패: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error equipping: $e");
    }
  }

  IconData _getIconForCategory(String? category) {
    switch (category) {
      case 'THEME': return Icons.nightlight_round;
      case 'BADGE': return Icons.stars;
      case 'PERSONA': return Icons.person;
      default: return Icons.card_giftcard;
    }
  }

  void _showItemDialog(dynamic item, bool isOwned, int? userItemId) {
    final name = item['itemName'] ?? '알 수 없음';
    final price = item['price']?.toString() ?? '0';
    final icon = _getIconForCategory(item['itemType']);
    final int itemId = item['id'];
    final String resourceUrl = item['resourceUrl'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isOwned ? '$name 장착' : '$name 구매',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.8)),
              const SizedBox(height: 16),
              Text(
                isOwned ? '이 테마를 지금 장착하시겠습니까?' : '이 아이템을 $price 포인트에 구매하시겠습니까?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소', style: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.5))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                if (isOwned && userItemId != null) {
                  _equipItem(userItemId, resourceUrl, name);
                } else {
                  _purchaseItem(itemId, name);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isOwned ? '장착하기' : '구매하기'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredItems = _selectedFilter == '전체'
        ? _items
        : _items.where((item) => item['itemType'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('다이어리 상점'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            }
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  '카테고리 필터',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final displayTitle = filter == '전체' ? '전체' : _typeToKorean[filter] ?? filter;
                    return ListTile(
                      title: Text(displayTitle, style: Theme.of(context).textTheme.bodyMedium),
                      trailing: _selectedFilter == filter
                          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                        Navigator.pop(context); // Close the drawer
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 80.0), // Padding for bottom nav
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.85,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final bool isOwned = _ownedItemIds.contains(item['id']);
                bool isEquipped = false;
                int? userItemId;
                if (isOwned) {
                  final ownedItemInfo = _myItems.firstWhere((e) => e['itemId'] == item['id'], orElse: () => null);
                  if (ownedItemInfo != null) {
                    userItemId = ownedItemInfo['userItemId'];
                    isEquipped = ownedItemInfo['isEquipped'] ?? false;
                  }
                }
                final icon = _getIconForCategory(item['itemType']);
                final price = item['price']?.toString() ?? '0';

                return GestureDetector(
                  onTap: () {
                    if (!isOwned) {
                      _showItemDialog(item, false, null);
                    } else if (item['itemType'] == 'THEME' && userItemId != null) {
                      // 테마는 보유 시 장착 가능
                      _showItemDialog(item, true, userItemId);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isEquipped 
                            ? Theme.of(context).colorScheme.primary 
                            : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                        width: isEquipped ? 2.0 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 48,
                          color: isOwned 
                              ? (isEquipped ? Theme.of(context).colorScheme.primary : Colors.grey)
                              : Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['itemName'] ?? '알 수 없음',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isEquipped 
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                : (isOwned ? Colors.grey.withOpacity(0.2) : Theme.of(context).colorScheme.secondary.withOpacity(0.2)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isEquipped ? '장착중' : (isOwned ? '보유중' : '$price 포인트'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isEquipped 
                                  ? Theme.of(context).colorScheme.primary
                                  : (isOwned ? Colors.grey : Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

