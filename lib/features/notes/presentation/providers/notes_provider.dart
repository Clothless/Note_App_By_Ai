// Riverpod provider for NotesRepository
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../data/datasources/notes_local_datasource.dart';
import '../../domain/entities/note.dart';

final notesRepositoryProvider = Provider((ref) {
  return NotesRepositoryImpl(NotesLocalDatasource());
});

class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final NotesRepositoryImpl repository;
  NotesNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = const AsyncValue.loading();
    try {
      final notes = await repository.getAllNotes();
      state = AsyncValue.data(notes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addNote(Note note) async {
    await repository.addNote(note);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await repository.updateNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await repository.deleteNote(id);
    await loadNotes();
  }
}

final notesProvider =
    StateNotifierProvider<NotesNotifier, AsyncValue<List<Note>>>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  return NotesNotifier(repo);
});
