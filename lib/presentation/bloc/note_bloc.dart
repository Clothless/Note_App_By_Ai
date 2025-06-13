import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:next_notes_flutter/domain/entities/note.dart';
import 'package:next_notes_flutter/presentation/bloc/note_event.dart';

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
    on<ReorderNotes>(_onReorderNotes);
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

  Future<void> _onReorderNotes(
      ReorderNotes event, Emitter<NoteState> emit) async {
    try {
      await _noteBox.clear();
      for (var note in event.notes) {
        await _noteBox.put(note.id, note);
      }
      emit(NoteLoaded(event.notes));
    } catch (e) {
      emit(NoteError('Failed to reorder notes: $e'));
    }
  }
}
