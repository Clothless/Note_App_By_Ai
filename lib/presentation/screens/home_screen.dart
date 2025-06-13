import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:next_notes_flutter/domain/entities/note.dart';
import 'package:next_notes_flutter/presentation/bloc/note_bloc.dart';
import 'package:next_notes_flutter/presentation/bloc/note_event.dart';
import 'package:next_notes_flutter/presentation/screens/note_edit_screen.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:next_notes_flutter/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NoteBloc>().add(LoadNotes());
  }

  String _getPlainText(String content) {
    try {
      final doc = Document.fromJson(jsonDecode(content));
      return doc.toPlainText();
    } catch (e) {
      return content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Notes'),
        actions: [
          IconButton(
            icon: Icon(
              themeModeNotifier.value == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              setState(() {
                themeModeNotifier.value =
                    themeModeNotifier.value == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state is NoteLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NoteError) {
            return Center(child: Text(state.message));
          }
          if (state is NoteLoaded) {
            if (state.notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 100,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Notes Yet',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to create your first note',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              );
            }
            return ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.notes.length,
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final List<Note> newNotes = List.from(state.notes);
                final note = newNotes.removeAt(oldIndex);
                newNotes.insert(newIndex, note);
                context.read<NoteBloc>().emit(NoteLoaded(newNotes));
                context.read<NoteBloc>().add(ReorderNotes(newNotes));
              },
              proxyDecorator: (child, index, animation) {
                return Material(
                  elevation: 8,
                  color: Colors.transparent,
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final note = state.notes[index];
                final content = _getPlainText(note.content);
                final isDarkMode = themeModeNotifier.value == ThemeMode.dark;
                return Card(
                  key: ValueKey(note.id),
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: note.isCompleted ? 1 : 2,
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: note.color != null
                              ? Color(note.color!).withOpacity(0.8)
                              : Colors.transparent,
                          width: 6,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteEditScreen(note: note),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (note.isCompleted)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    note.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? (note.isCompleted
                                              ? Colors.white38
                                              : Colors.white)
                                          : (note.isCompleted
                                              ? Colors.black38
                                              : Colors.black87),
                                      decoration: note.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  value: note.isCompleted,
                                  onChanged: (value) {
                                    context.read<NoteBloc>().add(
                                          ToggleNoteCompletion(
                                              note.id, value ?? false),
                                        );
                                  },
                                ),
                              ],
                            ),
                            if (content.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                content,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? (note.isCompleted
                                          ? Colors.white38
                                          : Colors.white70)
                                      : (note.isCompleted
                                          ? Colors.black38
                                          : Colors.black54),
                                  decoration: note.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: isDarkMode
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Last updated: ${_formatDate(note.updatedAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoteEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
