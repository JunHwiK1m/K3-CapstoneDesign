import 'package:flutter/material.dart';

class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hide back button
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
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
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
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
                      border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
                    ),
                    child: Text(
                      '오늘 하루는 조금 지치고 힘들었구나. ☁️\n가끔은 훌훌 털어버리고 쉬어가는 것도 좋아. 내가 널 위해 기분 전환할 수 있는 것들을 찾아왔어!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Emotion Summary
            Text(
              '오늘의 감정 분석',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildEmotionStat(context, '지침', '75%', Icons.battery_alert),
                  _buildEmotionStat(context, '우울', '60%', Icons.cloud),
                  _buildEmotionStat(context, '스트레스', '80%', Icons.bolt),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Recommendations
            Text(
              '이런 콘텐츠는 어때요?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecommendationCard(
              context: context,
              icon: Icons.music_note,
              title: 'Spotify (스포티파이)',
              description: '마음을 편안하게 해주는 잔잔한 어쿠스틱 플레이리스트',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildRecommendationCard(
              context: context,
              icon: Icons.movie_filter,
              title: 'Netflix (넷플릭스)',
              description: '가볍게 웃고 넘길 수 있는 힐링 시트콤 모음',
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            _buildRecommendationCard(
              context: context,
              icon: Icons.fastfood,
              title: '배달 앱',
              description: '스트레스가 싹 풀리는 달콤한 마카롱과 디저트',
              color: Colors.orange,
            ),
            const SizedBox(height: 40),

            // Bottom Button
            ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
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

  Widget _buildEmotionStat(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
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

  Widget _buildRecommendationCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
        onTap: () {
          // Placeholder for actual link feature
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title(으)로 이동합니다 (기능 준비 중)'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}
