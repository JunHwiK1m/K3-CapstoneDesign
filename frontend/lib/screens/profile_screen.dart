import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  final List<String> _categories = ['일기장', '폰트', '테마', '캐릭터'];

  final Map<String, List<Map<String, dynamic>>> _ownedItems = {
    '일기장': [
      {'name': '기본 일기장', 'isApplied': true, 'icon': Icons.book},
      {'name': '밤하늘 일기장', 'isApplied': false, 'icon': Icons.nightlight_round},
      {'name': '벚꽃 일기장', 'isApplied': false, 'icon': Icons.local_florist},
    ],
    '폰트': [
      {'name': '기본 고딕', 'isApplied': true, 'icon': Icons.font_download},
      {'name': '손글씨체', 'isApplied': false, 'icon': Icons.draw},
      {'name': '타자기체', 'isApplied': false, 'icon': Icons.keyboard},
    ],
    '테마': [
      {'name': '따뜻한 베이지', 'isApplied': true, 'icon': Icons.palette},
      {'name': '다크 모드', 'isApplied': false, 'icon': Icons.dark_mode},
      {'name': '파스텔 핑크', 'isApplied': false, 'icon': Icons.format_paint},
    ],
    '캐릭터': [
      {'name': '기본 강아지', 'isApplied': true, 'icon': Icons.pets},
      {'name': '안경 쓴 고양이', 'isApplied': false, 'icon': Icons.smart_toy},
      {'name': '마법사 토끼', 'isApplied': false, 'icon': Icons.auto_fix_high},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _fetchProfileData();
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
        Uri.parse('http://10.0.2.2:8080/api/users/settings'),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyItem(String category, int index) {
    setState(() {
      // 해당 카테고리의 모든 아이템 적용 해제
      for (var item in _ownedItems[category]!) {
        item['isApplied'] = false;
      }
      // 선택한 아이템만 적용
      _ownedItems[category]![index]['isApplied'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_ownedItems[category]![index]['name']}이(가) 적용되었습니다.'),
        duration: const Duration(seconds: 2),
      ),
    );
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
            '나를 알아가는 여정, 12일째',
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
                _buildStatColumn('작성한 일기', '12', context),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.5),
                ),
                _buildStatColumn('달성한 목표', '34', context),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.5),
                ),
                _buildStatColumn('보유 아이템', '12', context),
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
