import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:belajarku/models/task_model.dart';
import 'package:belajarku/edit_schedule_bottom_sheet.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _getFormattedTime(TimeOfDay? time) {
    if (time == null) {
      return 'No Time';
    }
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat.jm().format(dateTime);
  }

  void _showEditScheduleBottomSheet(TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditScheduleBottomSheet(task: task),
    );
  }

  Color _getCategoryColor(String? category) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (category) {
      case 'Studi':
        return isDarkMode ? Colors.blue.shade700 : Colors.blue.shade100;
      case 'Tugas':
        return isDarkMode ? Colors.purple.shade700 : Colors.purple.shade100;
      case 'Kerja':
        return isDarkMode ? Colors.orange.shade700 : Colors.orange.shade100;
      case 'Lainnya':
        return isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
      default:
        return isDarkMode ? Colors.grey.shade800 : Colors.white;
    }
  }

  Color _getCategoryTextColor(String? category) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (category) {
      case 'Studi':
        return isDarkMode ? Colors.blue.shade100 : Colors.blue.shade700;
      case 'Tugas':
        return isDarkMode ? Colors.purple.shade100 : Colors.purple.shade700;
      case 'Kerja':
        return isDarkMode ? Colors.orange.shade100 : Colors.orange.shade700;
      case 'Lainnya':
        return isDarkMode ? Colors.grey.shade200 : Colors.grey.shade700;
      default:
        return isDarkMode ? Colors.white : Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: false,
      ),
      body: ValueListenableBuilder<Box<TaskModel>>(
        valueListenable: Hive.box<TaskModel>('tasks').listenable(),
        builder: (context, box, _) {
          final allTasks = box.values.toList();
          final today = DateTime.now();

          final List<TaskModel> upcomingTasks = [];
          final List<TaskModel> overdueTasks = [];
          final List<TaskModel> completedTasks = [];

          for (var task in allTasks) {
            if (task.isCompleted ?? false) {
              completedTasks.add(task);
            } else if (task.date != null) {
              final taskDateNormalized = DateTime(
                task.date!.year,
                task.date!.month,
                task.date!.day,
              );
              final todayNormalized = DateTime(
                today.year,
                today.month,
                today.day,
              );

              bool isToday = taskDateNormalized.isAtSameMomentAs(
                todayNormalized,
              );
              bool isOverdue = taskDateNormalized.isBefore(todayNormalized);

              if (isToday) {
                upcomingTasks.add(task);
              } else if (isOverdue) {
                overdueTasks.add(task);
              }
            }
          }

          upcomingTasks.sort((a, b) {
            if (a.date == null && b.date == null) return 0;
            if (a.date == null) return 1;
            if (b.date == null) return -1;
            int dateComparison = a.date!.compareTo(b.date!);
            if (dateComparison != 0) return dateComparison;
            if (a.time == null && b.time == null) return 0;
            if (a.time == null) return 1;
            if (b.time == null) return -1;
            final aTime = DateTime(
              a.date!.year,
              a.date!.month,
              a.date!.day,
              a.time!.hour,
              a.time!.minute,
            );
            final bTime = DateTime(
              b.date!.year,
              b.date!.month,
              b.date!.day,
              b.time!.hour,
              b.time!.minute,
            );
            return aTime.compareTo(bTime);
          });

          overdueTasks.sort((a, b) {
            if (a.date == null && b.date == null) return 0;
            if (a.date == null) return 1;
            if (b.date == null) return -1;
            int dateComparison = b.date!.compareTo(a.date!);
            if (dateComparison != 0) return dateComparison;
            if (a.time == null && b.time == null) return 0;
            if (a.time == null) return 1;
            if (b.time == null) return -1;
            final aTime = DateTime(
              a.date!.year,
              a.date!.month,
              a.date!.day,
              a.time!.hour,
              a.time!.minute,
            );
            final bTime = DateTime(
              b.date!.year,
              b.date!.month,
              b.date!.day,
              b.time!.hour,
              b.time!.minute,
            );
            return bTime.compareTo(aTime);
          });

          completedTasks.sort((a, b) {
            if (a.date == null && b.date == null) return 0;
            if (a.date == null) return 1;
            if (b.date == null) return -1;
            return b.date!.compareTo(a.date!);
          });

          if (upcomingTasks.isEmpty &&
              overdueTasks.isEmpty &&
              completedTasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Colors.green.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Semua tugas selesai atau tidak ada yang jatuh tempo!',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nikmati waktu luang Anda atau tambahkan tugas baru.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              if (upcomingTasks.isNotEmpty) ...[
                Text(
                  'Tugas Mendatang (Hari Ini)',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),
                ...upcomingTasks
                    .map(
                      (task) => _buildTaskCard(
                        task,
                        _showEditScheduleBottomSheet,
                        false,
                      ),
                    )
                    .toList(),
                const SizedBox(height: 20),
              ],
              if (overdueTasks.isNotEmpty) ...[
                Text(
                  'Tugas Terlambat',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                ...overdueTasks
                    .map(
                      (task) => _buildTaskCard(
                        task,
                        _showEditScheduleBottomSheet,
                        true,
                      ),
                    )
                    .toList(),
                const SizedBox(height: 20),
              ],
              if (completedTasks.isNotEmpty) ...[
                Text(
                  'Tugas Selesai',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 10),
                ...completedTasks
                    .map(
                      (task) => _buildTaskCard(
                        task,
                        _showEditScheduleBottomSheet,
                        false,
                      ),
                    )
                    .toList(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(
    TaskModel task,
    Function(TaskModel) onTap,
    bool isOverdue,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: (task.isCompleted ?? false)
          ? Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey[100]
          : Theme.of(context).cardColor,
      child: InkWell(
        onTap: () => onTap(task),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title ?? 'No Title',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: (task.isCompleted ?? false)
                            ? Colors.grey
                            : (isOverdue
                                  ? Colors.red.shade700
                                  : Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color),
                        decoration: (task.isCompleted ?? false)
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isOverdue && !(task.isCompleted ?? false))
                    Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                  Checkbox(
                    value: task.isCompleted ?? false,
                    onChanged: (bool? newValue) async {
                      if (newValue != null) {
                        task.isCompleted = newValue;
                        await task.save();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                newValue
                                    ? 'Tugas "${task.title ?? 'ini'}" ditandai selesai!'
                                    : 'Tugas "${task.title ?? 'ini'}" ditandai belum selesai.',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    activeColor: Colors.deepPurple,
                    checkColor: Colors.white,
                  ),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: (task.isCompleted ?? false)
                        ? Colors.grey
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    decoration: (task.isCompleted ?? false)
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              if (task.subtasks.isNotEmpty) ...[
                Text(
                  'Sub-tugas:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                ...task.subtasks.map(
                  (subtaskName) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                    child: Text(
                      '• $subtaskName',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: (task.isCompleted ?? false)
                            ? Colors.grey
                            : Theme.of(context).textTheme.bodySmall?.color,
                        decoration: (task.isCompleted ?? false)
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  if (task.date != null) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat.yMMMd().format(task.date!),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (task.time != null) ...[
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getFormattedTime(task.time),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ],
              ),
              if (task.category != null && task.category!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(task.category),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.category!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryTextColor(task.category),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
