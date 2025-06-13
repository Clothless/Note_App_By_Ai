import 'package:next_notes_flutter/domain/entities/note.dart';

abstract class NoteEvent {}

class LoadNotes extends NoteEvent {}

class AddNote extends NoteEvent {
  final Note note;

  AddNote(this.note);
}

class UpdateNote extends NoteEvent {
  final Note note;

  UpdateNote(this.note);
}

class DeleteNote extends NoteEvent {
  final String id;

  DeleteNote(this.id);
}

class ToggleNoteCompletion extends NoteEvent {
  final String id;
  final bool isCompleted;

  ToggleNoteCompletion(this.id, this.isCompleted);
}

class ReorderNotes extends NoteEvent {
  final List<Note> notes;

  ReorderNotes(this.notes);
}
