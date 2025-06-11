class Note {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final bool isChecklist;
  final List<ChecklistItem> checklistItems;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? folderId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.isChecklist,
    required this.checklistItems,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
  });
}

class ChecklistItem {
  final String text;
  final bool isChecked;

  ChecklistItem({
    required this.text,
    required this.isChecked,
  });
}
