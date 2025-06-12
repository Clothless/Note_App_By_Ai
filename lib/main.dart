import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:next_notes_flutter/domain/entities/note.dart';
import 'package:next_notes_flutter/presentation/bloc/note_bloc.dart';
import 'package:next_notes_flutter/presentation/screens/home_screen.dart';
import 'package:next_notes_flutter/presentation/theme/app_theme.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Note adapter
  Hive.registerAdapter(NoteAdapter());

  // Open notes box
  final noteBox = await Hive.openBox<Note>('notes');

  runApp(MyApp(noteBox: noteBox));
}

class MyApp extends StatelessWidget {
  final Box<Note> noteBox;

  const MyApp({
    super.key,
    required this.noteBox,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NoteBloc(noteBox),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'Next Notes',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
