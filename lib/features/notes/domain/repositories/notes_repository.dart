import '../entities/note.dart';

abstract class NotesRepository {
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
  Future<List<Note>> getAllNotes();
  Future<Note?> getNoteById(String id);
}
