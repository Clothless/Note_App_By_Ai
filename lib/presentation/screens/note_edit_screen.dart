import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:next_notes_flutter/domain/entities/note.dart';
import 'package:next_notes_flutter/presentation/bloc/note_bloc.dart';
import 'package:next_notes_flutter/presentation/bloc/note_event.dart';
import 'dart:convert';

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  const NoteEditScreen({
    super.key,
    this.note,
  });

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late final TextEditingController _titleController;
  late final QuillController _quillController;
  late final FocusNode _titleFocusNode;
  late final FocusNode _contentFocusNode;
  Color? _selectedColor;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
    _selectedColor =
        widget.note?.color != null ? Color(widget.note!.color!) : null;
    _isCompleted = widget.note?.isCompleted ?? false;

    // Initialize QuillController with proper document
    Document document;
    if (widget.note?.content != null && widget.note!.content.isNotEmpty) {
      try {
        document = Document.fromJson(jsonDecode(widget.note!.content));
      } catch (e) {
        // If content is not valid JSON, create a new document with the content as plain text
        document = Document()..insert(0, widget.note!.content);
      }
    } else {
      document = Document();
    }
    _quillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    // Auto-focus title if it's a new note
    if (widget.note == null) {
      _titleFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final content = jsonEncode(_quillController.document.toDelta().toJson());
    final note = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      color: _selectedColor?.value,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isCompleted: _isCompleted,
    );

    if (widget.note == null) {
      context.read<NoteBloc>().add(AddNote(note));
    } else {
      context.read<NoteBloc>().add(UpdateNote(note));
    }

    Navigator.pop(context);
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Colors.transparent,
              Colors.red,
              Colors.pink,
              Colors.purple,
              Colors.deepPurple,
              Colors.indigo,
              Colors.blue,
              Colors.lightBlue,
              Colors.cyan,
              Colors.teal,
              Colors.green,
              Colors.lightGreen,
              Colors.lime,
              Colors.yellow,
              Colors.amber,
              Colors.orange,
              Colors.deepOrange,
              Colors.brown,
              Colors.grey,
              Colors.blueGrey,
            ].map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color == Colors.transparent ? null : color;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: _selectedColor ==
                          (color == Colors.transparent ? null : color)
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _showColorPicker,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color:
              _selectedColor != null ? _selectedColor!.withOpacity(0.05) : null,
          border: Border(
            left: BorderSide(
              color: _selectedColor ?? Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: QuillEditor(
                focusNode: FocusNode(),
                scrollController: ScrollController(),
                configurations: QuillEditorConfigurations(
                  controller: _quillController,
                  placeholder: 'Start writing...',
                  padding: const EdgeInsets.all(16),
                  expands: false,
                ),
              ),
            ),
            QuillToolbar(
              child: Row(
                children: [
                  QuillToolbarToggleStyleButton(
                    controller: _quillController,
                    attribute: Attribute.bold,
                    options: const QuillToolbarToggleStyleButtonOptions(),
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: _quillController,
                    attribute: Attribute.italic,
                    options: const QuillToolbarToggleStyleButtonOptions(),
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: _quillController,
                    attribute: Attribute.underline,
                    options: const QuillToolbarToggleStyleButtonOptions(),
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: _quillController,
                    attribute: Attribute.strikeThrough,
                    options: const QuillToolbarToggleStyleButtonOptions(),
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: _quillController,
                    attribute: Attribute.ul,
                    options: const QuillToolbarToggleStyleButtonOptions(),
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: _quillController,
                    attribute: Attribute.ol,
                    options: const QuillToolbarToggleStyleButtonOptions(),
                  ),
                  QuillToolbarToggleStyleButton(
                    controller: _quillController,
                    attribute: Attribute.checked,
                    options: const QuillToolbarToggleStyleButtonOptions(
                      tooltip: 'Checkbox',
                      iconData: Icons.check_box_outline_blank,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
