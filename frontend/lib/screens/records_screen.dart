import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  // Join Date -> limit firstDay of calendar
  final DateTime _joinDate = DateTime(2026, 4, 15); // mock join date

  // Mock diary data where key is Date
  final Map<DateTime, Map<String, dynamic>> _diaries = {
    DateTime(2026, 5, 2): {
      'emotion': '✨',
      'content': '오랜만에 만난 친구들과의 대화에서 많은 영감을 얻었다. 새로운 취미를 시작해볼까 하는 생각에 마음이 설렌다.',
      'score': 85,
    },
    DateTime(2026, 5, 4): {
      'emotion': '☁️',
      'content': '비가 오는 날. 창밖으로 떨어지는 빗방울 소리를 들으며 책을 읽었다. 복잡했던 마음이 조금씩 차분해지는 기분이다.',
      'score': 60,
    },
    DateTime(2026, 5, 5): {
      'emotion': '🌿',
      'content': '오늘 하루는 참 따뜻했다. 길을 걷다 우연히 발견한 작은 카페에서 향긋한 커피를 마시며 여유를 즐겼다.',
      'score': 92,
    },
  };

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // Helper to normalize datetime for map key matching
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    final normalizedSelected = _selectedDay != null ? _normalizeDate(_selectedDay!) : null;
    final selectedDiary = normalizedSelected != null ? _diaries[normalizedSelected] : null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('나의 기록'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Calendar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
              ),
              child: TableCalendar(
                firstDay: _joinDate,
                lastDay: DateTime.now().add(const Duration(days: 30)), // up to next month
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.primary),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  weekendTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.6)),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final normalizedDay = _normalizeDate(day);
                    if (_diaries.containsKey(normalizedDay)) {
                      return Positioned(
                        bottom: 4,
                        child: Text(
                          _diaries[normalizedDay]!['emotion'],
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Diary Content Area for the selected day
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: selectedDiary != null
                  ? _buildDiaryCard(selectedDiary)
                  : _buildEmptyCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryCard(Map<String, dynamic> diary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedDay!.month}월 ${_selectedDay!.day}일의 일기',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '감정 점수: ${diary['score']}점',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                diary['content'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              '작성된 일기가 없습니다.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
