import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  List<String> tags;

  @HiveField(4)
  bool isChecklist;

  @HiveField(5)
  List<ChecklistItemModel> checklistItems;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  @HiveField(8)
  String? folderId;

  @HiveField(9)
  int color;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.isChecklist,
    required this.checklistItems,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
    this.color = 0xFFFFFFFF, // default white
  });
}

@HiveType(typeId: 1)
class ChecklistItemModel extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  bool isChecked;

  ChecklistItemModel({
    required this.text,
    required this.isChecked,
  });
}
