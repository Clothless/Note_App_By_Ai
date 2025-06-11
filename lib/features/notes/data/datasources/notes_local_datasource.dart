import 'package:hive/hive.dart';
import '../models/note_model.dart';

class NotesLocalDatasource {
  static const String notesBoxName = 'notesBox';

  Future<Box<NoteModel>> openBox() async {
    return await Hive.openBox<NoteModel>(notesBoxName);
  }

  Future<void> addNote(NoteModel note) async {
    final box = await openBox();
    await box.put(note.id, note);
  }

  Future<void> updateNote(NoteModel note) async {
    final box = await openBox();
    await box.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    final box = await openBox();
    await box.delete(id);
  }

  Future<List<NoteModel>> getAllNotes() async {
    final box = await openBox();
    return box.values.toList();
  }

  Future<NoteModel?> getNoteById(String id) async {
    final box = await openBox();
    return box.get(id);
  }
}
