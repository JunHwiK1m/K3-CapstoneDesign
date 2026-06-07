import 'dart:convert';
import '../config.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

class RecordsScreen extends StatefulWidget {
  final String token;
  const RecordsScreen({super.key, required this.token});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  // Join Date -> limit firstDay of calendar
  final DateTime _joinDate = DateTime(2025, 1, 1);

  // Map diary data where key is Date
  final Map<DateTime, Map<String, dynamic>> _diaries = {};
  bool _isLoading = true;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchJournals();
  }

  DateTime _parseDate(dynamic createdAtRaw) {
    if (createdAtRaw == null) return DateTime.now();
    if (createdAtRaw is String) {
      return DateTime.parse(createdAtRaw);
    } else if (createdAtRaw is List) {
      return DateTime(
        createdAtRaw.isNotEmpty ? createdAtRaw[0] : 2026,
        createdAtRaw.length > 1 ? createdAtRaw[1] : 1,
        createdAtRaw.length > 2 ? createdAtRaw[2] : 1,
        createdAtRaw.length > 3 ? createdAtRaw[3] : 0,
        createdAtRaw.length > 4 ? createdAtRaw[4] : 0,
        createdAtRaw.length > 5 ? createdAtRaw[5] : 0,
      );
    }
    return DateTime.now();
  }

  Future<void> _fetchJournals() async {
    final token = widget.token.trim();
    if (token.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/journals'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> data = body['data'] ?? [];

        if (mounted) {
          setState(() {
            _diaries.clear();
            for (var item in data) {
              final DateTime createdAt = _parseDate(item['createdAt']);
              final DateTime normalizedDate = _normalizeDate(createdAt);

              // 서버에서 최신순(내림차순)으로 오므로, 첫 번째로 만나는 데이터가 가장 최신입니다.
              // 따라서 이미 해당 날짜의 데이터가 있다면 덮어쓰지 않고 무시합니다.
              if (!_diaries.containsKey(normalizedDate)) {
                _diaries[normalizedDate] = {
                  'id': item['id'],
                  'content': item['content'] ?? '내용 없음',
                  'analysisStatus': item['analysisStatus'] ?? 'PENDING',
                  'emotion': 'assets/imgs/m_normal.png', // 기본값
                  'score': 0, // 기본값
                  'imageUrls': item['imageUrls'] ?? [], // 전체 이미지 리스트 저장
                };
              }
            }
            _isLoading = false;
          });
        }

        // 이미 _diaries 맵에 저장된(최신) 일기인지 확인하기 위한 Set
        final Set<DateTime> processedDates = {};

        // 상세 조회를 통해 감정 데이터 덮어쓰기 (COMPLETED 상태인 경우만)
        for (var item in data) {
          final DateTime normalizedDate = _normalizeDate(
            _parseDate(item['createdAt']),
          );

          // 이미 해당 날짜의 최신 일기를 처리했다면 스킵
          if (processedDates.contains(normalizedDate)) continue;

          // 이 일기가 해당 날짜의 최신 일기가 맞다면(즉, 맵에 저장된 id와 같다면) 처리
          if (_diaries.containsKey(normalizedDate) &&
              _diaries[normalizedDate]!['id'] == item['id']) {
            processedDates.add(normalizedDate);

            if (item['analysisStatus'] == 'COMPLETED' && item['id'] != null) {
              final journalId = item['id'];
              try {
                final detailRes = await http.get(
                  Uri.parse('${ApiConfig.baseUrl}/api/journals/$journalId'),
                  headers: {'Authorization': 'Bearer $token'},
                );
                if (detailRes.statusCode == 200) {
                  final detailBody = jsonDecode(
                    utf8.decode(detailRes.bodyBytes),
                  );
                  final detailData = detailBody['data'];
                  if (detailData != null &&
                      detailData['emotionResult'] != null) {
                    final double joyScore =
                        (detailData['emotionResult']['joyScore'] ?? 0.0)
                            .toDouble();
                    int score = (joyScore * 100).toInt();
                    String emotionAsset = 'assets/imgs/m_normal.png';
                    if (joyScore >= 0.7)
                      emotionAsset = 'assets/imgs/m_happy.png';
                    else if (joyScore >= 0.4)
                      emotionAsset = 'assets/imgs/m_normal.png';
                    else
                      emotionAsset = 'assets/imgs/m_sad.png';

                    if (mounted) {
                      setState(() {
                        if (_diaries.containsKey(normalizedDate)) {
                          _diaries[normalizedDate]!['score'] = score;
                          _diaries[normalizedDate]!['emotion'] = emotionAsset;
                          if (detailData['imageUrls'] != null) {
                            _diaries[normalizedDate]!['imageUrls'] =
                                detailData['imageUrls'];
                          }
                        }
                      });
                    }
                  }
                }
              } catch (e) {
                debugPrint("Error fetching detail for $journalId: $e");
              }
            }
          }
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching journals: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper to normalize datetime for map key matching
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    final normalizedSelected = _selectedDay != null
        ? _normalizeDate(_selectedDay!)
        : null;
    final selectedDiary = normalizedSelected != null
        ? _diaries[normalizedSelected]
        : null;

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
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.3),
                ),
              ),
              child: TableCalendar(
                firstDay: _joinDate,
                lastDay: DateTime.now().add(
                  const Duration(days: 30),
                ), // up to next month
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
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.6),
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final normalizedDay = _normalizeDate(day);
                    if (_diaries.containsKey(normalizedDay)) {
                      final String emotionData =
                          _diaries[normalizedDay]!['emotion'];
                      return Positioned(
                        bottom: 4,
                        child: emotionData.startsWith('assets/')
                            ? Image.asset(
                                emotionData,
                                width: 16,
                                height: 16,
                                fit: BoxFit.contain,
                              )
                            : Text(
                                emotionData,
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : selectedDiary != null
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
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.3),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 일기 본문 텍스트
                  Text(
                    diary['content'],
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.8),
                  ),
                  const SizedBox(height: 16),

                  // 첨부 이미지가 있는 경우 렌더링 (텍스트 아래에 표시, 폴라로이드 디자인)
                  if (diary['imageUrls'] != null &&
                      diary['imageUrls'].isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: List.generate(
                          (diary['imageUrls'] as List).length,
                          (index) {
                            final String url = diary['imageUrls'][index]
                                .toString();
                            // 인덱스에 따라 약간씩 다른 기울기 적용 (감성 효과)
                            final double angle = index % 3 == 0
                                ? -0.02
                                : (index % 3 == 1 ? 0.03 : -0.01);

                            return Padding(
                              padding: EdgeInsets.only(
                                right:
                                    index <
                                        (diary['imageUrls'] as List).length - 1
                                    ? 16.0
                                    : 0,
                              ),
                              child: Center(
                                child: Transform.rotate(
                                  angle: angle,
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 10,
                                      bottom: 32,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 10,
                                          offset: const Offset(2, 4),
                                        ),
                                      ],
                                    ),
                                    child:
                                        url.startsWith('http') ||
                                            url.startsWith('/')
                                        ? Image.network(
                                            url.startsWith('/')
                                                ? '${ApiConfig.baseUrl}$url'
                                                : url
                                                      .replaceAll(
                                                        'http://localhost:8080',
                                                        ApiConfig.baseUrl,
                                                      )
                                                      .replaceAll(
                                                        'http://127.0.0.1:8080',
                                                        ApiConfig.baseUrl,
                                                      ),
                                            width: 160,
                                            height: 160,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(url),
                                            width: 160,
                                            height: 160,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
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
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
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
