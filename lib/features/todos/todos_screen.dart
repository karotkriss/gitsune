import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// To-Dos tab. Placeholder until E5 builds the To-Do List.
class TodosScreen extends StatelessWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text('To-Dos', style: gs.screenTitle),
          ),
        ),
      ),
    );
  }
}
