import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyrka/zefyrka.dart';
import '../../../../shared/theme/theme_toggle_button.dart';
import '../providers/notes_provider.dart';
import 'note_edit_screen.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
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
              child: notesAsync.when(
                data: (notes) => notes.isEmpty
                    ? const Center(child: Text('No notes yet.'))
                    : ListView.separated(
                        itemCount: notes.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          final doc =
                              NotusDocument.fromJson(jsonDecode(note.content));
                          return ListTile(
                            title: Text(note.title),
                            subtitle: Text(
                              doc.toPlainText().length > 80
                                  ? doc.toPlainText().substring(0, 80) + '...'
                                  : doc.toPlainText(),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      NoteEditScreen(note: note)));
                            },
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NoteEditScreen()));
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Note',
      ),
    );
  }
}
