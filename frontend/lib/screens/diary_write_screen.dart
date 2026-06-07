import 'dart:convert';
import '../config.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'analysis_loading_screen.dart';
import 'records_screen.dart';

class LinedPaperPainter extends CustomPainter {
  final Color lineColor;
  final double lineHeight;

  LinedPaperPainter({required this.lineColor, required this.lineHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    for (double i = 0; i <= size.height; i += lineHeight) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiaryWriteScreen extends StatefulWidget {
  final String token;
  const DiaryWriteScreen({super.key, required this.token});

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends State<DiaryWriteScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<String> _selectedImagePaths = [];
  bool _isRecording = false;
  bool _isSubmitting = false;

  late stt.SpeechToText _speechToText; // STT 객체
  bool _isSpeechInitialized = false; // STT 초기화 상태
  String _startText = ''; // 음성 인식 시작 시점의 텍스트 저장용

  bool _isAiAnalysisEnabled = true; // AI 분석 동의 여부 상태

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _initSpeech();
    _fetchUserSettings(); // 설정 조회
  }

  // 백엔드에서 사용자 설정(AI 분석 동의 여부 등)을 불러옵니다.
  Future<void> _fetchUserSettings() async {
    try {
      final token = widget.token.trim();
      if (token.isEmpty) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/users/settings'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final data = body['data'];
        if (data != null && mounted) {
          setState(() {
            _isAiAnalysisEnabled = data['isAiAnalysisEnabled'] ?? true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching settings: $e");
    }
  }

  // STT 초기화 및 권한 요청 (Korean comments)
  void _initSpeech() async {
    _isSpeechInitialized = await _speechToText.initialize(
      onError: (error) => debugPrint('STT 에러: $error'),
      onStatus: (status) {
        debugPrint('STT 상태: $status');
        // 사용자가 말을 멈추거나 타임아웃으로 인식이 종료되었을 때 UI 업데이트
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() {
              _isRecording = false;
            });
          }
        }
      },
    );
    setState(() {});
  }

  // 음성 인식 시작 및 중지 토글 (Korean comments)
  void _toggleListening() async {
    if (_speechToText.isNotListening) {
      // 마이크 권한 확인
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('음성 인식을 위해 마이크 권한이 필요합니다.')),
          );
        }
        return;
      }

      if (_isSpeechInitialized) {
        setState(() {
          _isRecording = true;
          _startText = _contentController.text; // 현재 작성된 텍스트 저장
        });

        // 음성 인식 시작 (Korean comments)
        await _speechToText.listen(
          onResult: (result) {
            setState(() {
              // 인식된 텍스트를 기존 텍스트 뒤에 실시간으로 이어붙임
              final currentWords = result.recognizedWords;
              _contentController.text = _startText.isEmpty
                  ? currentWords
                  : '$_startText $currentWords';
              // 커서를 텍스트 맨 끝으로 이동
              _contentController.selection = TextSelection.fromPosition(
                TextPosition(offset: _contentController.text.length),
              );
            });
          },
          localeId: 'ko_KR', // 한국어 설정
        );
      }
    } else {
      // 음성 인식 중지
      await _speechToText.stop();
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            if (_selectedImagePaths.length < 3) {
              _selectedImagePaths.add(image.path);
            }
          }
        });

        if (_selectedImagePaths.length > 3 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지는 최대 3장까지만 첨부할 수 있습니다.')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('일기 내용을 입력해주세요.')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final token = widget.token.trim();
      List<String> uploadedImgUrls = [];

      // 1. Upload images if selected
      if (_selectedImagePaths.isNotEmpty) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConfig.baseUrl}/api/files/upload-multiple'),
        );
        request.headers['Authorization'] = 'Bearer $token';

        for (String path in _selectedImagePaths) {
          request.files.add(await http.MultipartFile.fromPath('files', path));
        }

        var uploadRes = await request.send();
        if (uploadRes.statusCode >= 200 && uploadRes.statusCode < 300) {
          final respStr = await uploadRes.stream.bytesToString();
          final uploadBody = jsonDecode(respStr);
          final data = uploadBody['data'];
          if (data is List) {
            uploadedImgUrls = data.map((e) => e.toString()).toList();
          }
        } else {
          final errStr = await uploadRes.stream.bytesToString();
          debugPrint("Image upload failed: ${uploadRes.statusCode} - $errStr");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '이미지 업로드에 실패했습니다. 다시 시도해주세요. (${uploadRes.statusCode})',
                ),
              ),
            );
            setState(() {
              _isSubmitting = false;
            });
          }
          return; // 업로드 실패 시 일기 저장도 중단
        }
      }

      final payload = {
        "content": content,
        "imageUrls": uploadedImgUrls,
        "voiceUrl": "",
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/journals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final int journalId = body['data'] is int
            ? body['data']
            : int.tryParse(body['data'].toString()) ?? 0;

        if (mounted) {
          // AI 분석 동의 여부에 따라 화면 이동 분기 처리
          if (_isAiAnalysisEnabled && journalId > 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AnalysisLoadingScreen(
                  token: widget.token,
                  journalId: journalId,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RecordsScreen(token: widget.token),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('일기 저장 실패: ${response.statusCode}')),
          );
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error submitting journal: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')));
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('새로운 일기'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          _isSubmitting
              ? const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _submit,
                  child: Text(
                    '완료',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Springs
          SizedBox(
            width: 50,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 20,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Row(
                    children: [
                      const Spacer(),
                      // The hole
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // The wire
                      Container(
                        width: 14,
                        height: 4,
                        margin: const EdgeInsets.only(left: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Vertical Divider
          Container(
            width: 1,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            margin: const EdgeInsets.only(right: 8),
          ),
          // Right Content Area
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: LinedPaperPainter(
                      lineColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.15),
                      lineHeight: 36.0,
                    ),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        hintText: '오늘 하루는 어땠나요?',
                      ),
                      style: const TextStyle(fontSize: 16, height: 36.0 / 16.0),
                      strutStyle: const StrutStyle(
                        fontSize: 16,
                        height: 36.0 / 16.0,
                        leading: 0,
                      ),
                    ),
                  ),
                ),
                // Bottom Toolbar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        // Camera/Gallery Button
                        IconButton(
                          icon: const Icon(Icons.photo_library_outlined),
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: _pickImage,
                        ),
                        if (_selectedImagePaths.isNotEmpty)
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _selectedImagePaths
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      int index = entry.key;
                                      String path = entry.value;
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            margin: const EdgeInsets.only(
                                              left: 8,
                                              top: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: FileImage(File(path)),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: -8,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedImagePaths.removeAt(
                                                    index,
                                                  );
                                                });
                                              },
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    })
                                    .toList(),
                              ),
                            ),
                          ),
                        const Spacer(),
                        // Voice Record Button
                        GestureDetector(
                          onTap: _toggleListening,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isRecording
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isRecording ? Icons.mic : Icons.mic_none,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
