import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyrka/zefyrka.dart';
import '../providers/notes_provider.dart';
import '../../domain/entities/note.dart';
import 'dart:convert';

class NoteEditScreen extends ConsumerStatefulWidget {
  final Note? note;
  const NoteEditScreen({Key? key, this.note}) : super(key: key);

  @override
  ConsumerState<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends ConsumerState<NoteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late ZefyrController _contentController;
  late FocusNode _focusNode;
  bool _isChecklist = false;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = ZefyrController(
      widget.note != null && widget.note!.content.isNotEmpty
          ? NotusDocument.fromJson(jsonDecode(widget.note!.content))
          : NotusDocument(),
    );
    _focusNode = FocusNode();
    _isChecklist = widget.note?.isChecklist ?? false;
    _tags = widget.note?.tags ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final note = Note(
        id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: jsonEncode(_contentController.document.toJson()),
        tags: _tags,
        isChecklist: _isChecklist,
        checklistItems: [], // TODO: Add checklist support
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        folderId: null,
      );
      if (widget.note == null) {
        ref.read(notesProvider.notifier).addNote(note);
      } else {
        ref.read(notesProvider.notifier).updateNote(note);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isChecklist,
                    onChanged: (val) =>
                        setState(() => _isChecklist = val ?? false),
                  ),
                  const Text('Checklist'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ZefyrEditor(
                  controller: _contentController,
                  focusNode: _focusNode,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _tags.join(', '),
                decoration:
                    const InputDecoration(labelText: 'Tags (comma separated)'),
                onChanged: (val) => _tags = val
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
