import 'package:flutter/material.dart';
import 'analysis_loading_screen.dart';

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
  const DiaryWriteScreen({super.key});

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends State<DiaryWriteScreen> {
  final TextEditingController _contentController = TextEditingController();
  int _imageCount = 0;
  bool _isRecording = false;

  void _submit() {
    // Navigate to loading screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AnalysisLoadingScreen()),
    );
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
          TextButton(
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
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
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
                      lineColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      lineHeight: 36.0,
                    ),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        hintText: '오늘 하루는 어땠나요?',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 36.0 / 16.0, 
                      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    border: Border(
                      top: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        // Camera/Gallery Button
                        IconButton(
                          icon: const Icon(Icons.photo_library_outlined),
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            if (_imageCount < 4) {
                              setState(() {
                                _imageCount++;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('이미지는 최대 4장까지 첨부할 수 있습니다.')),
                              );
                            }
                          },
                        ),
                        Text(
                          '$_imageCount / 4',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        // Voice Record Button
                        GestureDetector(
                          onLongPressStart: (_) => setState(() => _isRecording = true),
                          onLongPressEnd: (_) => setState(() => _isRecording = false),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isRecording 
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
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

