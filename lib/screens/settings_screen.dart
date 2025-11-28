import 'package:flutter/material.dart';

import '../utils/app_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppText.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.language),
            title: Text(AppText.language),
            subtitle: Text('العربية (الأساسية)'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(AppText.about),
            subtitle: Text('تطبيق موجود يساعدك في اكتشاف أفضل الأعمال في العراق.'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text(AppText.help),
            subtitle: Text('للدعم تواصل معنا عبر البريد: support@mawjood.app'),
          ),
        ],
      ),
    );
  }
}
