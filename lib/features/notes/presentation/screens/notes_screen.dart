import 'package:flutter/material.dart';
import '../../../../shared/theme/theme_toggle_button.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: const [ThemeToggleButton()],
      ),
      body: const Center(
        child: Text('Notes List will appear here'),
      ),
    );
  }
}
