import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:next_notes_flutter/domain/entities/note.dart';

// Events
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

// States
abstract class NoteState {}

class NoteInitial extends NoteState {}

class NoteLoading extends NoteState {}

class NoteLoaded extends NoteState {
  final List<Note> notes;
  NoteLoaded(this.notes);
}

class NoteError extends NoteState {
  final String message;
  NoteError(this.message);
}

// Bloc
class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final Box<Note> _noteBox;

  NoteBloc(this._noteBox) : super(NoteInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<ToggleNoteCompletion>(_onToggleNoteCompletion);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NoteState> emit) async {
    try {
      emit(NoteLoading());
      final notes = _noteBox.values.toList();
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError('Failed to load notes: $e'));
    }
  }

  Future<void> _onAddNote(AddNote event, Emitter<NoteState> emit) async {
    try {
      await _noteBox.put(event.note.id, event.note);
      final notes = _noteBox.values.toList();
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError('Failed to add note: $e'));
    }
  }

  Future<void> _onUpdateNote(UpdateNote event, Emitter<NoteState> emit) async {
    try {
      await _noteBox.put(event.note.id, event.note);
      final notes = _noteBox.values.toList();
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError('Failed to update note: $e'));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NoteState> emit) async {
    try {
      await _noteBox.delete(event.id);
      final notes = _noteBox.values.toList();
      emit(NoteLoaded(notes));
    } catch (e) {
      emit(NoteError('Failed to delete note: $e'));
    }
  }

  Future<void> _onToggleNoteCompletion(
      ToggleNoteCompletion event, Emitter<NoteState> emit) async {
    try {
      final note = _noteBox.get(event.id);
      if (note != null) {
        final updatedNote = note.copyWith(
          isCompleted: event.isCompleted,
          updatedAt: DateTime.now(),
        );
        await _noteBox.put(event.id, updatedNote);
        final notes = _noteBox.values.toList();
        emit(NoteLoaded(notes));
      }
    } catch (e) {
      emit(NoteError('Failed to toggle note completion: $e'));
    }
  }
}
