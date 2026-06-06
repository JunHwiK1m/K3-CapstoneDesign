import 'dart:convert';
import '../config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'diary_write_screen.dart';
import 'store_screen.dart';
import 'records_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../widgets/bouncing_mascot.dart';
class DiaryHomePage extends StatefulWidget {
  final String? initialToken;
  const DiaryHomePage({super.key, this.initialToken});

  @override
  State<DiaryHomePage> createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage> {
  List<dynamic> _todos = [];
  double _successRate = 0.0;
  int _completedCount = 0;
  int _totalCount = 0;
  bool _isLoading = true;
  String _feedbackMessage = '오늘 하루도 화이팅! 🌱';

  final TextEditingController _todoController = TextEditingController();
  late final TextEditingController _tempTokenController;

  @override
  void initState() {
    super.initState();
    _tempTokenController = TextEditingController(
      text: widget.initialToken ?? '',
    );
    if (_tempTokenController.text.isNotEmpty) {
      _fetchData();
    } else {
      _isLoading = false;
    }
  }

  void _fetchData() {
    setState(() => _isLoading = true);
    Future.wait([_fetchTodos(), _fetchTodoStats()]).whenComplete(() {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Future<void> _fetchTodos() async {
    final token = _tempTokenController.text.trim();
    if (token.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/todos'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _todos = body['data'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching todos: $e");
    }
  }

  Future<void> _fetchTodoStats() async {
    final token = _tempTokenController.text.trim();
    if (token.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/todos/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final data = body['data'];
        if (mounted && data != null) {
          setState(() {
            _totalCount = data['totalCount'] ?? 0;
            _completedCount = data['completedCount'] ?? 0;
            _successRate = data['completionRate']?.toDouble() ?? 0.0;
            _feedbackMessage = data['feedbackMessage'] ?? '오늘 하루도 화이팅! 🌱';
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching todo stats: $e");
    }
  }

  Future<void> _addTodo() async {
    final text = _todoController.text.trim();
    final token = _tempTokenController.text.trim();
    if (text.isEmpty || token.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/todos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'taskName': text}),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _todoController.clear();
        _fetchData(); // Refresh list and stats
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('할 일 추가 실패: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error adding todo: $e");
    }
  }

  Future<void> _completeTodo(int todoId, int index) async {
    final token = _tempTokenController.text.trim();
    if (token.isEmpty) return;

    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/api/todos/$todoId/complete'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _fetchTodoStats(); // Refresh stats (list is already optimistically updated)
      } else {
        // Revert optimistic update on failure
        if (mounted) {
          setState(() {
            _todos[index]['isCompleted'] = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('할 일 완료 처리 실패: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error completing todo: $e");
      // Revert optimistic update on failure
      if (mounted) {
        setState(() {
          _todos[index]['isCompleted'] = false;
        });
      }
    }
  }

  Future<void> _deleteTodo(int todoId) async {
    final token = _tempTokenController.text.trim();
    if (token.isEmpty) return;

    // Optimistically remove from list
    int indexToRemove = _todos.indexWhere((todo) => todo['id'] == todoId);
    Map<String, dynamic>? removedTodo;
    if (indexToRemove != -1) {
      setState(() {
        removedTodo = _todos.removeAt(indexToRemove);
      });
    }

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/todos/$todoId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _fetchTodoStats(); // Refresh stats
      } else {
        // Revert on failure
        if (mounted && removedTodo != null && indexToRemove != -1) {
          setState(() {
            _todos.insert(indexToRemove, removedTodo!);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('할 일 삭제 실패: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error deleting todo: $e");
      if (mounted && removedTodo != null && indexToRemove != -1) {
        setState(() {
          _todos.insert(indexToRemove, removedTodo!);
        });
      }
    }
  }

  @override
  void dispose() {
    _todoController.dispose();
    _tempTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('My AI Diary'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Top Section: Mascot Character Bubble
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16, right: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      _feedbackMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                // Mascot Image
                const BouncingMascot(),
              ],
            ),
            const SizedBox(height: 40),

            // Middle Section: Today's To-Do and Gauge
            // Middle Section: Today's To-Do and Gauge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '오늘의 목표 달성률',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '$_completedCount / $_totalCount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  // Linear Gauge
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _successRate,
                      minHeight: 12,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.3),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // To-Do List
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (_todos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('오늘의 목표가 없습니다.\n아래에서 새로운 목표를 추가해보세요!'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _todos.length,
                      itemBuilder: (context, index) {
                        final todo = _todos[index];
                        final bool isDone = todo['isCompleted'] ?? false;
                        final String title = todo['taskName'] ?? '';
                        final int id = todo['id'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CheckboxListTile(
                            title: Text(
                              title,
                              style: TextStyle(
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isDone
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.5)
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            value: isDone,
                            activeColor: Theme.of(context).colorScheme.primary,
                            checkColor: Theme.of(context).colorScheme.surface,
                            onChanged: (bool? value) {
                              if (value == true && !isDone) {
                                // Optimistic UI update
                                setState(() {
                                  _todos[index]['isCompleted'] = true;
                                });
                                _completeTodo(id, index);
                              } else if (value == false && isDone) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('이미 완료된 목표는 취소할 수 없습니다.'),
                                  ),
                                );
                              }
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 0,
                            ),
                            secondary: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.grey,
                              ),
                              onPressed: () => _deleteTodo(id),
                            ),
                          ),
                        );
                      },
                    ),

                  // Add New To-Do Input
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _todoController,
                          decoration: InputDecoration(
                            hintText: '새로운 목표 추가하기',
                            hintStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.5),
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary.withOpacity(0.2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          onSubmitted: (value) => _addTodo(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: _addTodo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Section: Custom Navigation Bar
      floatingActionButtonLocation: const _LoweredBigFabLocation(),
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {
            Future.delayed(Duration.zero, () {
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DiaryWriteScreen(token: _tempTokenController.text),
                ),
              );
            });
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.surface,
          shape: const CircleBorder(), // make it perfectly round
          elevation: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.edit, size: 28),
              SizedBox(height: 2),
              Text(
                '일기 작성',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.person_outline,
                label: '프로필',
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(token: _tempTokenController.text),
                      ),
                    );
                  });
                },
              ),
              _buildNavItem(
                icon: Icons.storefront_outlined,
                label: '상점',
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoreScreen(token: _tempTokenController.text),
                      ),
                    );
                  });
                },
              ),
              // 가운데 80px 크기의 FAB와 양옆 여백을 위해 넉넉히 120px 비워둠
              const SizedBox(width: 120),
              _buildNavItem(
                icon: Icons.menu_book_outlined,
                label: '기록',
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecordsScreen(token: _tempTokenController.text),
                      ),
                    );
                  });
                },
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                label: '설정',
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoweredBigFabLocation extends FloatingActionButtonLocation {
  const _LoweredBigFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset offset = FloatingActionButtonLocation.centerDocked.getOffset(
      scaffoldGeometry,
    );
    // 버튼을 40픽셀 아래로 내려서 화면 하단에 살짝 잘리도록(묻히도록) 배치
    return Offset(offset.dx, offset.dy + 50.0);
  }
}
