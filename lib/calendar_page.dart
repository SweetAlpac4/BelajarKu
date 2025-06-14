import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:belajarku/models/task_model.dart';
import 'package:belajarku/edit_schedule_bottom_sheet.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<TaskModel>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

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

  List<TaskModel> _getEventsForDay(DateTime day) {
    final tasksBox = Hive.box<TaskModel>('tasks');
    return tasksBox.values
        .where((task) => task.date != null && isSameDay(task.date!, day))
        .toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _showEditScheduleBottomSheet(TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditScheduleBottomSheet(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Kalender Jadwal',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: false,
      ),
      body: ValueListenableBuilder<Box<TaskModel>>(
        valueListenable: Hive.box<TaskModel>('tasks').listenable(),
        builder: (context, box, _) {
          return Column(
            children: [
              TableCalendar<TaskModel>(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2101, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: (day) => _getEventsForDay(day),
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.deepPurple.shade200,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.purple.shade700,
                    shape: BoxShape.circle,
                  ),
                  markerSize: 5.0,
                  markersAnchor: 0.8,
                  defaultTextStyle: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  weekendTextStyle: GoogleFonts.poppins(color: Colors.red),
                  outsideTextStyle: GoogleFonts.poppins(
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonShowsNext: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  formatButtonTextStyle: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  weekendStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ValueListenableBuilder<List<TaskModel>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    if (value.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada tugas untuk hari ini.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final task = value[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          elevation: 2,
                          color: (task.isCompleted ?? false)
                              ? Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade800
                                    : Colors.grey[100]
                              : Theme.of(context).cardColor,
                          child: InkWell(
                            onTap: () => _showEditScheduleBottomSheet(task),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title ?? 'No Title',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: (task.isCompleted ?? false)
                                                ? Colors.grey
                                                : Theme.of(
                                                    context,
                                                  ).textTheme.titleLarge?.color,
                                            decoration:
                                                (task.isCompleted ?? false)
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                      Checkbox(
                                        value: task.isCompleted ?? false,
                                        onChanged: (bool? newValue) async {
                                          if (newValue != null) {
                                            task.isCompleted = newValue;
                                            await task.save();
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
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
                                  if (task.description != null &&
                                      task.description!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      task.description!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: (task.isCompleted ?? false)
                                            ? Colors.grey
                                            : Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
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
                                        color: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...task.subtasks.map(
                                      (subtaskName) => Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                          bottom: 4.0,
                                        ),
                                        child: Text(
                                          '• $subtaskName',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: (task.isCompleted ?? false)
                                                ? Colors.grey
                                                : Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall?.color,
                                            decoration:
                                                (task.isCompleted ?? false)
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
                                          color: Theme.of(
                                            context,
                                          ).iconTheme.color,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat.yMMMd().format(task.date!),
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.color,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      if (task.time != null) ...[
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Theme.of(
                                            context,
                                          ).iconTheme.color,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getFormattedTime(task.time),
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.color,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (task.category != null &&
                                      task.category!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(
                                            task.category,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          task.category!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: _getCategoryTextColor(
                                              task.category,
                                            ),
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
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
