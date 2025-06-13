import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesLocalDatasource localDatasource;

  NotesRepositoryImpl(this.localDatasource);

  @override
  Future<void> addNote(Note note) async {
    final noteModel = NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      tags: note.tags,
      isChecklist: note.isChecklist,
      checklistItems: note.checklistItems
          .map((item) =>
              ChecklistItemModel(text: item.text, isChecked: item.isChecked))
          .toList(),
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      folderId: note.folderId,
      color: note.color,
    );
    await localDatasource.addNote(noteModel);
  }

  @override
  Future<void> updateNote(Note note) async {
    final noteModel = NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      tags: note.tags,
      isChecklist: note.isChecklist,
      checklistItems: note.checklistItems
          .map((item) =>
              ChecklistItemModel(text: item.text, isChecked: item.isChecked))
          .toList(),
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      folderId: note.folderId,
      color: note.color,
    );
    await localDatasource.updateNote(noteModel);
  }

  @override
  Future<void> deleteNote(String id) async {
    await localDatasource.deleteNote(id);
  }

  @override
  Future<List<Note>> getAllNotes() async {
    final noteModels = await localDatasource.getAllNotes();
    return noteModels
        .map((model) => Note(
              id: model.id,
              title: model.title,
              content: model.content,
              tags: model.tags,
              isChecklist: model.isChecklist,
              checklistItems: model.checklistItems
                  .map((item) =>
                      ChecklistItem(text: item.text, isChecked: item.isChecked))
                  .toList(),
              createdAt: model.createdAt,
              updatedAt: model.updatedAt,
              folderId: model.folderId,
              color: model.color,
            ))
        .toList();
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final model = await localDatasource.getNoteById(id);
    if (model == null) return null;
    return Note(
      id: model.id,
      title: model.title,
      content: model.content,
      tags: model.tags,
      isChecklist: model.isChecklist,
      checklistItems: model.checklistItems
          .map((item) =>
              ChecklistItem(text: item.text, isChecked: item.isChecked))
          .toList(),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      folderId: model.folderId,
      color: model.color,
    );
  }
}
