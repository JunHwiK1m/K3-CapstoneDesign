import 'package:flutter/material.dart';
import 'diary_write_screen.dart';
import 'store_screen.dart';
import 'records_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class DiaryHomePage extends StatefulWidget {
  const DiaryHomePage({super.key});

  @override
  State<DiaryHomePage> createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage> {
  final List<Map<String, dynamic>> _todos = [
    {'title': '물 3잔 마시기', 'isDone': true},
    {'title': '10분 명상하기', 'isDone': false},
    {'title': '감사 일기 쓰기', 'isDone': false},
  ];

  final TextEditingController _todoController = TextEditingController();

  void _addTodo() {
    final text = _todoController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _todos.add({'title': text, 'isDone': false});
      });
      Future.delayed(Duration.zero, () {
        _todoController.clear();
      });
    }
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = _todos.where((todo) => todo['isDone']).length;
    double successRate = _todos.isEmpty ? 0 : completedCount / _todos.length;

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
                      '안녕! 오늘도 활기찬 하루 보내고 있니?\n내가 널 항상 응원하고 있어 ✨',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                // Mascot Placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pets, // Mascot icon placeholder
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
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
                  '$completedCount / ${_todos.length}',
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
                      value: successRate,
                      minHeight: 12,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withOpacity(0.3),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // To-Do List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
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
                            _todos[index]['title'],
                            style: TextStyle(
                              decoration: _todos[index]['isDone']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: _todos[index]['isDone']
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.5)
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          value: _todos[index]['isDone'],
                          activeColor: Theme.of(context).colorScheme.primary,
                          checkColor: Theme.of(context).colorScheme.surface,
                          onChanged: (bool? value) {
                            setState(() {
                              _todos[index]['isDone'] = value!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
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
                  builder: (context) => const DiaryWriteScreen(),
                ),
              );
            });
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.surface,
          shape: const CircleBorder(), // make it perfectly round
          elevation: 6,
          child: const Icon(Icons.edit, size: 36),
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
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.grey),
                onPressed: () {
                  Future.delayed(Duration.zero, () {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.storefront_outlined, color: Colors.grey),
                onPressed: () {
                  Future.delayed(Duration.zero, () {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StoreScreen(),
                      ),
                    );
                  });
                },
              ),
              // 가운데 80px 크기의 FAB와 양옆 여백을 위해 넉넉히 120px 비워둠
              const SizedBox(width: 120),
              IconButton(
                icon: const Icon(Icons.menu_book_outlined, color: Colors.grey),
                onPressed: () {
                  Future.delayed(Duration.zero, () {
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecordsScreen(),
                      ),
                    );
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.grey),
                onPressed: () {
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
