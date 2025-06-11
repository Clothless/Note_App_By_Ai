import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/notes/presentation/screens/notes_screen.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

void main() {
  runApp(const ProviderScope(child: NextNotesApp()));
}

class NextNotesApp extends ConsumerWidget {
  const NextNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Next Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.deepPurple,
          secondary: Colors.deepPurpleAccent,
          surface: Colors.white,
          background: Colors.white,
        ),
        useMaterial3: true,
        brightness: Brightness.light,
        canvasColor: Colors.white,
        cardColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          primary: Colors.deepPurple,
          secondary: Colors.deepPurpleAccent,
          surface: Colors.grey[900]!,
          background: Colors.grey[900]!,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
        canvasColor: Colors.grey[900],
        cardColor: Colors.grey[900],
        dialogBackgroundColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      themeMode: themeMode,
      home: const NotesScreen(),
    );
  }
}
