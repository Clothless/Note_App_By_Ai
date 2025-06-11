// Riverpod provider for NotesRepository
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/notes_repository_impl.dart';
import '../../data/datasources/notes_local_datasource.dart';

final notesRepositoryProvider = Provider((ref) {
  return NotesRepositoryImpl(NotesLocalDatasource());
});
