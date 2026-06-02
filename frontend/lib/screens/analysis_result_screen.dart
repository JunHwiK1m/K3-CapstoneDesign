import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

class AnalysisResultScreen extends StatefulWidget {
  final String token;
  final int journalId;

  const AnalysisResultScreen({
    super.key,
    required this.token,
    required this.journalId,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  bool _isLoading = true;
  String _emotionSummary = '오늘 하루는 어땠나요?';
  double _joyScore = 0.0;
  double _sadnessScore = 0.0;
  List<dynamic> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final token = widget.token;
      final journalId = widget.journalId;

      final futures = await Future.wait([
        http.get(
          Uri.parse('http://10.0.2.2:8080/api/journals/$journalId'),
          headers: {'Authorization': 'Bearer $token'},
        ),
        http.get(
          Uri.parse(
            'http://10.0.2.2:8080/api/recommendations?journalId=$journalId',
          ),
          headers: {'Authorization': 'Bearer $token'},
        ),
      ]);

      final journalRes = futures[0];
      final recRes = futures[1];

      if (journalRes.statusCode == 200) {
        final body = jsonDecode(utf8.decode(journalRes.bodyBytes));
        final data = body['data'];
        if (data != null && data['emotionResult'] != null) {
          _emotionSummary = data['emotionResult']['emotionSummary'] ?? '';
          _joyScore = (data['emotionResult']['joyScore'] ?? 0.0).toDouble();
          _sadnessScore = (data['emotionResult']['sadnessScore'] ?? 0.0)
              .toDouble();
        }
      }

      if (recRes.statusCode == 200) {
        final body = jsonDecode(utf8.decode(recRes.bodyBytes));
        _recommendations = body['data'] ?? [];
      }
    } catch (e) {
      debugPrint("Error fetching analysis result: $e");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRecommendationClick(
    int recId,
    String category,
    String externalLink,
    String fallbackUrl,
    String title,
  ) async {
    try {
      // 1. Send click status to backend
      if (recId > 0) {
        await http.patch(
          Uri.parse('http://10.0.2.2:8080/api/recommendations/$recId/click'),
          headers: {'Authorization': 'Bearer ${widget.token}'},
        );
      }
    } catch (e) {
      debugPrint("Error updating click status: $e");
    }

    if (externalLink.isEmpty) return;

    // 2. Open link based on category
    if (category == 'MUSIC' && externalLink.startsWith('spotify:')) {
      try {
        // 스포티파이 SDK를 통해 앱을 열지 않고 백그라운드 재생 시도
        // TODO: 사용자가 대시보드에서 발급받은 Client ID로 변경해야 합니다.
        bool result = await SpotifySdk.connectToSpotifyRemote(
          clientId: 'b2a2b0e246b2460b83f8673cbc2e40d9',
          redirectUrl: 'narae://spotify-callback',
        );

        if (result) {
          await SpotifySdk.play(spotifyUri: externalLink);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('스포티파이 백그라운드 재생을 시작합니다.')),
            );
          }
        } else {
          throw Exception('Spotify remote connection failed');
        }
      } catch (e) {
        debugPrint('Spotify SDK Error: $e');
        // 실패 시 (앱 미설치 등) 일반 딥링크로 Fallback 시도
        if (await canLaunchUrl(Uri.parse(externalLink))) {
          await launchUrl(
            Uri.parse(externalLink),
            mode: LaunchMode.externalApplication,
          );
        } else if (fallbackUrl.isNotEmpty &&
            await canLaunchUrl(Uri.parse(fallbackUrl))) {
          await launchUrl(
            Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication,
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('스포티파이 앱을 찾을 수 없거나 재생할 수 없습니다.')),
          );
        }
      }
    } else {
      // 넷플릭스, 배달앱 등 기타 딥링크 실행
      try {
        if (await canLaunchUrl(Uri.parse(externalLink))) {
          await launchUrl(
            Uri.parse(externalLink),
            mode: LaunchMode.externalApplication,
          );
        } else if (fallbackUrl.isNotEmpty &&
            await canLaunchUrl(Uri.parse(fallbackUrl))) {
          await launchUrl(
            Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication,
          );
        } else if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$title 앱을 찾을 수 없습니다.')));
        }
      } catch (e) {
        debugPrint('Url Launcher Error: $e');
      }
    }
  }

  // helper method to get icon and color
  (IconData, Color) _getCategoryStyle(String category) {
    switch (category.toUpperCase()) {
      case 'MUSIC':
        return (Icons.music_note, Colors.green);
      case 'MOVIE':
        return (Icons.movie_filter, Colors.redAccent);
      case 'FOOD':
        return (Icons.fastfood, Colors.orange);
      case 'BOOK':
        return (Icons.menu_book, Colors.brown);
      default:
        return (Icons.star, Colors.blueAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hide back button
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mascot and Bubble
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
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
                      _emotionSummary,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Emotion Summary
            Text(
              '오늘의 감정 분석',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildEmotionStat(
                    context,
                    '기쁨',
                    '${(_joyScore * 100).toInt()}%',
                    Icons.sentiment_very_satisfied,
                  ),
                  _buildEmotionStat(
                    context,
                    '슬픔',
                    '${(_sadnessScore * 100).toInt()}%',
                    Icons.sentiment_dissatisfied,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Recommendations
            if (_recommendations.isNotEmpty) ...[
              Text(
                '이런 콘텐츠는 어때요?',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._recommendations.map((rec) {
                final String category = rec['category'] ?? 'ETC';
                final String title =
                    category; // Ideally, we'd have a specific title in API
                final String contentText = rec['contentText'] ?? '';
                final String externalLink = rec['externalLink'] ?? '';
                final String fallbackUrl = rec['fallbackUrl'] ?? '';
                final int id = rec['id'] ?? 0;
                final style = _getCategoryStyle(category);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildActionableRecommendationCard(
                    context: context,
                    icon: style.$1,
                    title: title,
                    description: contentText,
                    buttonText: '앱 열기 및 검색',
                    color: style.$2,
                    onTap: () => _handleRecommendationClick(
                      id,
                      category,
                      externalLink,
                      fallbackUrl,
                      title,
                    ),
                  ),
                );
              }).toList(),
            ] else ...[
              Text(
                '이런 콘텐츠는 어때요?',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildActionableRecommendationCard(
                  context: context,
                  icon: Icons.music_note,
                  title: 'Spotify (스포티파이)',
                  description: '마음을 편안하게 해주는 플레이리스트',
                  buttonText: '앱 열기 및 검색',
                  color: Colors.green,
                  onTap: () => _handleRecommendationClick(
                    0,
                    'MUSIC',
                    'spotify:playlist:37i9dQZF1DWZeKCadgRdKQ', // Deep focus playlist example
                    'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ',
                    'Spotify (스포티파이)',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildActionableRecommendationCard(
                  context: context,
                  icon: Icons.movie_filter,
                  title: 'Netflix (넷플릭스)',
                  description: '가볍게 웃고 즐길 수 있는 힐링 시트콤 모음',
                  buttonText: '앱 열기 및 검색',
                  color: Colors.redAccent,
                  onTap: () => _handleRecommendationClick(
                    0,
                    'MOVIE',
                    'netflix://',
                    'https://www.netflix.com/',
                    'Netflix (넷플릭스)',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildActionableRecommendationCard(
                  context: context,
                  icon: Icons.fastfood,
                  title: '배달 앱',
                  description: '스트레스가 싹 풀리는 달콤한 마카롱과 커피',
                  buttonText: '앱 열기 및 검색',
                  color: Colors.orange,
                  onTap: () => _handleRecommendationClick(
                    0,
                    'FOOD',
                    'smartbaemin://',
                    'https://www.baemin.com/',
                    '배달 앱',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),

            // Bottom Button
            ElevatedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                '홈으로 돌아가기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionableRecommendationCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withOpacity(0.1),
                foregroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
