import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
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
  late quill.QuillController _contentController;
  late FocusNode _focusNode;
  late ScrollController _scrollController;
  bool _isChecklist = false;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = quill.QuillController(
      document: widget.note != null && widget.note!.content.isNotEmpty
          ? quill.Document.fromJson(jsonDecode(widget.note!.content))
          : quill.Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    _isChecklist = widget.note?.isChecklist ?? false;
    _tags = widget.note?.tags ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final note = Note(
        id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: jsonEncode(_contentController.document.toDelta().toJson()),
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
              Container(
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    quill.QuillToolbar(
                      child: quill.QuillToolbarToggleStyleButton(
                        controller: _contentController,
                        options:
                            const quill.QuillToolbarToggleStyleButtonOptions(),
                        attribute: quill.Attribute.bold,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: quill.QuillEditor(
                          focusNode: _focusNode,
                          scrollController: _scrollController,
                          configurations: quill.QuillEditorConfigurations(
                            controller: _contentController,
                            placeholder: 'Start writing...',
                          ),
                        ),
                      ),
                    ),
                  ],
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
