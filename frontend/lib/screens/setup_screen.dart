import 'dart:convert';
import '../config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'diary_home_page.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _wakeUpTime;
  TimeOfDay? _diaryTime;
  bool _isLoading = false;

  // 6. 일기 작성 용도 (택 1)
  String _selectedPurpose = '기록용';
  final List<String> _purposes = ['기록용', '계획용', '멘탈관리용', '갓생용', '기타'];

  // 7. 조언 말투 설정 (택 1)
  String _selectedTone = '친근한';
  final List<String> _tones = ['직설적', '친근한', '공감적', '기타'];

  // 8. 좋아하는 노래 스타일 (다중 선택)
  final Map<String, bool> _musicStyles = {
    '발라드': false,
    '팝': false,
    '힙합': false,
    'R&B': false,
    '클래식': false,
    '재즈': false,
    '인디': false,
    'K-Pop': false,
    '기타': false,
  };

  // 9. AI 일기 분석 동의 여부
  bool _agreedToAIAnalysis = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isWakeUp) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isWakeUp) {
          _wakeUpTime = picked;
        } else {
          _diaryTime = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 설정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '조금 더 알아가고 싶어요 ✨',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 32),

            // 제거됨: 임시 토큰 입력창

            // 1. 프로필 이미지
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          // TODO: 이미지 선택 기능 구현
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. 닉네임
            Text('닉네임', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: '사용하실 닉네임을 입력해주세요',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.5),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 3. 생년월일
            Text('생년월일', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? '생년월일을 선택해주세요'
                          : '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일',
                      style: TextStyle(
                        color: _selectedDate == null
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.5)
                            : Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_rounded,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 4. 평균 기상 시간
            Text('평균 기상 시간', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectTime(context, true),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _wakeUpTime == null
                          ? '기상 시간을 선택해주세요'
                          : _wakeUpTime!.format(context),
                      style: TextStyle(
                        color: _wakeUpTime == null
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.5)
                            : Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.access_time_rounded,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 5. 일기 작성 시간
            Text('일기 작성 시간', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectTime(context, false),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _diaryTime == null
                          ? '일기 작성 시간을 선택해주세요'
                          : _diaryTime!.format(context),
                      style: TextStyle(
                        color: _diaryTime == null
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.5)
                            : Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.access_time_rounded,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 6. 일기 작성 용도
            Text(
              '일기 작성 용도 (택 1)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.5),
                ),
              ),
              child: Column(
                children: _purposes.map((String purpose) {
                  return RadioListTile<String>(
                    title: Text(purpose),
                    value: purpose,
                    groupValue: _selectedPurpose,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPurpose = value!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // 7. 조언 말투 설정
            Text(
              'AI 에이전트의 말투 (택 1)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.5),
                ),
              ),
              child: Column(
                children: _tones.map((String tone) {
                  return RadioListTile<String>(
                    title: Text(tone),
                    value: tone,
                    groupValue: _selectedTone,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedTone = value!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // 8. 좋아하는 노래 스타일
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '좋아하는 음악 장르 (다중 선택)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      bool allSelected = _musicStyles.values.every(
                        (element) => element,
                      );
                      _musicStyles.updateAll((key, value) => !allSelected);
                    });
                  },
                  child: Text(
                    _musicStyles.values.every((element) => element)
                        ? '모두 해제'
                        : '모두 선택',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _musicStyles.keys.map((String key) {
                return FilterChip(
                  label: Text(key),
                  selected: _musicStyles[key]!,
                  onSelected: (bool value) {
                    setState(() {
                      _musicStyles[key] = value;
                    });
                  },
                  selectedColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // 9. AI 분석 동의 여부
            Text('데이터 활용 동의', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.5),
                ),
              ),
              child: CheckboxListTile(
                title: Text(
                  'AI 일기 분석 및 맞춤 추천 서비스 동의',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                subtitle: Text(
                  '작성하신 일기 내용을 바탕으로 감정 분석 및 콘텐츠 추천을 제공합니다. 거부하셔도 기본 일기장 기능은 사용하실 수 있습니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.6),
                  ),
                ),
                value: _agreedToAIAnalysis,
                onChanged: (bool? value) {
                  setState(() {
                    _agreedToAIAnalysis = value ?? false;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            const SizedBox(height: 48),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_nicknameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('닉네임을 입력해주세요.')),
                          );
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          // 선택된 음악 장르를 리스트로 변환
                          List<String> selectedMusicStyles = _musicStyles.entries
                              .where((e) => e.value)
                              .map((e) => e.key)
                              .toList();

                          // 시간 포맷팅 헬퍼
                          String formatTime(TimeOfDay? time) {
                            if (time == null) return "00:00:00";
                            return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";
                          }

                          // 날짜 포맷팅 헬퍼
                          String formatDate(DateTime? date) {
                            if (date == null) return "2000-01-01";
                            return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                          }

                          final prefs = await SharedPreferences.getInstance();
                          final String tempToken = prefs.getString('auth_token') ?? '';
                          
                          if (tempToken.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('인증 정보가 없습니다. 다시 로그인해주세요.'),
                              ),
                            );
                            setState(() => _isLoading = false);
                            return;
                          }

                          final headers = {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer $tempToken',
                          };

                          // Enum 매핑 (프론트엔드 한글 -> 백엔드 Enum)
                          String mappedPurpose = 'RECORDING';
                          switch (_selectedPurpose) {
                            case '기록용':
                              mappedPurpose = 'RECORDING';
                              break;
                            case '계획용':
                              mappedPurpose = 'PLANNING';
                              break;
                            case '멘탈관리용':
                              mappedPurpose = 'MENTAL_CARE';
                              break;
                            case '갓생용':
                              mappedPurpose = 'GOD_SAENG';
                              break;
                            default:
                              mappedPurpose = 'RECORDING';
                              break;
                          }

                          String mappedTone = 'FORMAL';
                          switch (_selectedTone) {
                            case '직설적':
                              mappedTone = 'STRICT';
                              break;
                            case '친근한':
                              mappedTone = 'INFORMAL';
                              break;
                            case '공감적':
                              mappedTone = 'FRIENDLY';
                              break;
                            case '정중한':
                            default:
                              mappedTone = 'FORMAL';
                              break;
                          }

                          // 1. 설정 저장 (PATCH /api/users/settings)
                          final settingsResponse = await http.patch(
                            Uri.parse(
                              '${ApiConfig.baseUrl}/api/users/settings',
                            ),
                            headers: headers,
                            body: jsonEncode({
                              "usagePurpose": mappedPurpose,
                              "diaryTime": formatTime(_diaryTime),
                              "wakeUpTime": formatTime(_wakeUpTime),
                              "nickname": _nicknameController.text.trim(),
                              "personaStyle": mappedTone,
                              "musicStyles": selectedMusicStyles,
                              "birthDate": formatDate(_selectedDate),
                            }),
                          );

                          if (settingsResponse.statusCode >= 200 &&
                              settingsResponse.statusCode < 300) {
                            // 2. AI 분석 동의 설정 (PUT /api/users/settings/ai-analysis)
                            await http.put(
                              Uri.parse(
                                '${ApiConfig.baseUrl}/api/users/settings/ai-analysis?enabled=$_agreedToAIAnalysis',
                              ),
                              headers: headers,
                            );

                            // 토큰은 이미 LoginScreen에서 저장되었으므로 생략

                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DiaryHomePage(initialToken: tempToken),
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '설정 저장 실패: HTTP ${settingsResponse.statusCode}',
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('오류가 발생했습니다: $e')),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '시작하기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
