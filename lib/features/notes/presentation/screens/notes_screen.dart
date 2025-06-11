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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: 0, // TODO: Replace with notes count
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  // TODO: Replace with note item
                  return ListTile(
                    title: Text('Note Title'),
                    subtitle: Text('Note preview...'),
                    onTap: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add note screen
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Note',
      ),
    );
  }
}
