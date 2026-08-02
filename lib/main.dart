import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: GitsuneApp()));
}

class GitsuneApp extends StatelessWidget {
  const GitsuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gitsune',
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
