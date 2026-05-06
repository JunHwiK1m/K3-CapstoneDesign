import 'package:flutter/material.dart';
import 'setup_screen.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _appLockEnabled = false;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          _buildSectionTitle('일반 설정'),
          SwitchListTile(
            title: const Text('앱 알림'),
            subtitle: const Text('매일 일기 쓰기 리마인더 등'),
            value: _notificationsEnabled,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
            secondary: Icon(Icons.notifications_outlined, color: Theme.of(context).colorScheme.primary),
          ),
          SwitchListTile(
            title: const Text('다크 모드'),
            subtitle: const Text('시스템 설정과 관계없이 항상 어둡게'),
            value: _darkModeEnabled,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) => setState(() => _darkModeEnabled = value),
            secondary: Icon(Icons.dark_mode_outlined, color: Theme.of(context).colorScheme.primary),
          ),
          const Divider(height: 32),
          _buildSectionTitle('보안 및 프라이버시'),
          SwitchListTile(
            title: const Text('앱 잠금 (비밀번호)'),
            subtitle: const Text('앱 실행 시 비밀번호 요구'),
            value: _appLockEnabled,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) => setState(() => _appLockEnabled = value),
            secondary: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary),
          ),
          ListTile(
            leading: Icon(Icons.cloud_upload_outlined, color: Theme.of(context).colorScheme.primary),
            title: const Text('데이터 백업 및 복원'),
            onTap: () {},
          ),
          const Divider(height: 32),
          _buildSectionTitle('내 정보 및 AI 설정'),
          ListTile(
            leading: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary),
            title: const Text('프로필 및 초기 설정 변경'),
            subtitle: const Text('닉네임, AI 성향 등 수정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SetupScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
            title: const Text('앱 정보'),
            subtitle: const Text('버전 1.0.0'),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
        ),
      ),
    );
  }
}
