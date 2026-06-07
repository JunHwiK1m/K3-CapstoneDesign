import 'dart:convert';
import '../config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final String token;
  const ProfileScreen({super.key, required this.token});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _nickname = "불러오는 중...";
  bool _isLoading = true;

  int _diaryCount = 0;
  int _completedTodoCount = 0;
  int _ownedItemCount = 0;

  final List<String> _categories = ['일기장', '폰트', '테마', '캐릭터'];

  final Map<String, List<Map<String, dynamic>>> _ownedItems = {
    '일기장': [
      {'name': '기본 일기장', 'isApplied': true, 'icon': Icons.book},
    ],
    '폰트': [
      {'name': '기본 고딕', 'isApplied': true, 'icon': Icons.font_download},
    ],
    '테마': [
      {'name': '따뜻한 베이지', 'isApplied': true, 'icon': Icons.palette},
    ],
    '캐릭터': [
      {'name': '기본 나래', 'isApplied': true, 'icon': Icons.emoji_nature},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _fetchProfileData();
    _fetchMyItems();
    _fetchDiaryCount();
    _fetchTodoStats();
  }

  Future<void> _fetchDiaryCount() async {
    final token = widget.token.trim();
    if (token.isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/journals'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> data = body['data'] ?? [];
        
        final Set<String> uniqueDates = {};
        for (var item in data) {
          final createdAt = item['createdAt'];
          if (createdAt != null) {
            String dateStr = '';
            if (createdAt is List && createdAt.length >= 3) {
              dateStr = '${createdAt[0]}-${createdAt[1].toString().padLeft(2, '0')}-${createdAt[2].toString().padLeft(2, '0')}';
            } else {
              dateStr = createdAt.toString().split('T')[0];
            }
            uniqueDates.add(dateStr);
          }
        }
        
        if (mounted) {
          setState(() {
            _diaryCount = uniqueDates.length;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching journals: $e");
    }
  }

  Future<void> _fetchTodoStats() async {
    final token = widget.token.trim();
    if (token.isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/todos/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final data = body['data'];
        if (data != null && mounted) {
          setState(() {
            _completedTodoCount = data['completedCount'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching todo stats: $e");
    }
  }

  Future<void> _fetchProfileData() async {
    final token = widget.token.trim();
    if (token.isEmpty) {
      if (mounted)
        setState(() {
          _nickname = "이름 없음";
          _isLoading = false;
        });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/users/settings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final data = body['data'];
        if (mounted && data != null) {
          setState(() {
            _nickname = data['nickname'] ?? '이름 없음';
            _isLoading = false;
          });
        }
      } else {
        if (mounted)
          setState(() {
            _nickname = "불러오기 실패";
            _isLoading = false;
          });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted)
        setState(() {
          _nickname = "오류 발생";
          _isLoading = false;
        });
    }
  }

  Future<void> _fetchMyItems() async {
    final token = widget.token.trim();
    if (token.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/items/my'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> data = body['data'] ?? [];
        if (mounted) {
          setState(() {
            _ownedItemCount = data.length;
            for (var item in data) {
              final String itemType = item['itemType'] ?? '';
              final String itemName = item['itemName'] ?? '이름 없음';
              final bool isEquipped = item['isEquipped'] ?? false;

              String category = '';
              IconData icon = Icons.star;

              if (itemType == 'PERSONA') {
                category = '캐릭터';
                icon = Icons.emoji_nature;
              } else if (itemType == 'THEME') {
                category = '테마';
                icon = Icons.palette;
              } else {
                continue; // 지원하지 않는 타입은 건너뜀
              }

              // 기존 목록에 같은 이름이 있는지 확인하여 중복 추가 방지
              bool exists = _ownedItems[category]!.any(
                (element) => element['name'] == itemName,
              );
              if (!exists) {
                _ownedItems[category]!.add({
                  'name': itemName,
                  'isApplied': isEquipped,
                  'icon': icon,
                  'userItemId': item['userItemId'], // DB 아이템의 ID
                });
              } else if (isEquipped) {
                // 이미 존재하는 아이템이라면 상태만 갱신 (만약 DB에 중복이 있다면)
                final idx = _ownedItems[category]!.indexWhere(
                  (e) => e['name'] == itemName,
                );
                if (idx != -1) {
                  _ownedItems[category]![idx]['isApplied'] = true;
                  _ownedItems[category]![idx]['userItemId'] =
                      item['userItemId'];
                }
              }

              // 만약 DB에서 가져온 아이템이 장착 상태라면, 기본 아이템(userItemId가 없는 것)의 장착 상태를 해제
              if (isEquipped) {
                for (int i = 0; i < _ownedItems[category]!.length; i++) {
                  if (_ownedItems[category]![i]['userItemId'] == null ||
                      _ownedItems[category]![i]['name'] != itemName) {
                    _ownedItems[category]![i]['isApplied'] = false;
                  }
                }
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching my items: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyItem(String category, int index) async {
    final item = _ownedItems[category]![index];
    final int? newUserItemId = item['userItemId'];

    // 1. 테마 적용 시 글로벌 테마 변경
    if (category == '테마') {
      final prefs = await SharedPreferences.getInstance();
      if (item['name'] == '다크 모드 테마' || item['name'] == 'theme_dark') {
        themeNotifier.value = ThemeMode.dark;
        await prefs.setString('themeMode', 'dark');
      } else {
        themeNotifier.value = ThemeMode.light;
        await prefs.setString('themeMode', 'light');
      }
    }

    // 2. 이전에 장착되어 있던 DB 아이템 찾기 (userItemId가 있는 것)
    final currentlyApplied = _ownedItems[category]!.firstWhere(
      (e) => e['isApplied'] == true && e['userItemId'] != null,
      orElse: () => <String, dynamic>{},
    );

    try {
      if (newUserItemId != null) {
        // 새 DB 아이템 장착 (ItemService가 알아서 기존 아이템을 해제해줌)
        await http.patch(
          Uri.parse(
            '${ApiConfig.baseUrl}/api/items/user-items/$newUserItemId/equip',
          ),
          headers: {'Authorization': 'Bearer ${widget.token}'},
        );
      } else if (currentlyApplied.isNotEmpty) {
        // 기본 아이템(따뜻한 베이지)을 선택했는데, DB 아이템(다크 모드 테마)이 장착되어 있던 경우 -> 명시적으로 장착 해제
        int oldUserItemId = currentlyApplied['userItemId'];
        await http.patch(
          Uri.parse(
            '${ApiConfig.baseUrl}/api/items/user-items/$oldUserItemId/unequip',
          ),
          headers: {'Authorization': 'Bearer ${widget.token}'},
        );
      }
    } catch (e) {
      debugPrint('Error applying/unequipping item: $e');
    }

    setState(() {
      // UI 상에서 카테고리 내 모든 아이템 적용 해제 후 선택한 것만 적용
      for (var element in _ownedItems[category]!) {
        element['isApplied'] = false;
      }
      _ownedItems[category]![index]['isApplied'] = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item['name']}이(가) 적용되었습니다.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('내 프로필'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(child: _buildProfileHeader(context)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: _categories
                      .map((category) => Tab(text: category))
                      .toList(),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _categories.map((category) {
            final items = _ownedItems[category] ?? [];
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isApplied = item['isApplied'] as bool;

                return Card(
                  elevation: isApplied ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isApplied
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'],
                        size: 48,
                        color: isApplied
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item['name'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isApplied
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isApplied
                            ? null
                            : () => _applyItem(category, index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isApplied
                              ? Colors.grey.shade300
                              : Theme.of(context).colorScheme.primary,
                          foregroundColor: isApplied
                              ? Colors.black54
                              : Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                        ),
                        child: Text(isApplied ? '적용됨' : '적용하기'),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            child: Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  _nickname,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 24),
                ),
          const SizedBox(height: 8),
          Text(
            '나를 알아가는 여정, $_diaryCount일째',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('작성한 일기', '$_diaryCount', context),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.5),
                ),
                _buildStatColumn('달성한 목표', '$_completedTodoCount', context),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.5),
                ),
                _buildStatColumn('보유 아이템', '$_ownedItemCount', context),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count, BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(
        context,
      ).colorScheme.surface, // Background to prevent transparency on scroll
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
