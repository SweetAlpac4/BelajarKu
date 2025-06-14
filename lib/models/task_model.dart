import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime? date;

  @HiveField(4)
  TimeOfDay? time;

  @HiveField(5)
  String? category;

  @HiveField(6)
  bool? isCompleted;

  @HiveField(7)
  List<String> subtasks;

  TaskModel({
    this.id,
    this.title,
    this.description,
    this.date,
    this.time,
    this.category,
    bool? isCompleted,
    List<String>? subtasks,
  }) : this.isCompleted = isCompleted ?? false,
       this.subtasks = subtasks ?? [];
}

class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final typeId = 1;

  @override
  TimeOfDay read(BinaryReader reader) {
    final hour = reader.readInt();
    final minute = reader.readInt();
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeInt(obj.hour);
    writer.writeInt(obj.minute);
  }
}
