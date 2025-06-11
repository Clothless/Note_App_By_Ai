import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../../../shared/theme/theme_toggle_button.dart';
import '../providers/notes_provider.dart';
import 'note_edit_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getPlainText(String content) {
    try {
      final doc = quill.Document.fromJson(jsonDecode(content));
      return doc.toPlainText();
    } catch (e) {
      return 'Error loading content';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: notesAsync.when(
                data: (notes) {
                  final filteredNotes = notes.where((note) {
                    final title = note.title.toLowerCase();
                    final content = _getPlainText(note.content).toLowerCase();
                    final query = _searchQuery.toLowerCase();
                    return title.contains(query) || content.contains(query);
                  }).toList();
                  return filteredNotes.isEmpty
                      ? const Center(child: Text('No notes found.'))
                      : ListView.separated(
                          itemCount: filteredNotes.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            final content = _getPlainText(note.content);
                            return ListTile(
                              title: Text(note.title),
                              subtitle: Text(
                                content.length > 80
                                    ? content.substring(0, 80) + '...'
                                    : content,
                              ),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        NoteEditScreen(note: note)));
                              },
                            );
                          },
                        );
                },
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
