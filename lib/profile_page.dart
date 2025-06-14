import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:belajarku/models/task_model.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _daysKeptToPlan = 4;

  int _getWeekNumber(DateTime date) {
    DateTime startOfWeek = date.subtract(
      Duration(days: date.weekday == DateTime.sunday ? 6 : date.weekday - 1),
    );
    return ((startOfWeek.difference(DateTime(startOfWeek.year, 1, 1)).inDays /
                7) +
            1)
        .ceil();
  }

  List<FlSpot> _getCompletedTasksDataForWeeklyChart(
    List<TaskModel> tasks,
    int numberOfWeeks,
  ) {
    final now = DateTime.now();
    DateTime startOfCurrentWeek = now.subtract(
      Duration(days: now.weekday == DateTime.sunday ? 6 : now.weekday - 1),
    );

    Map<int, int> weeklyCompletedCounts = {};

    for (int i = 0; i < numberOfWeeks; i++) {
      DateTime weekDate = startOfCurrentWeek.subtract(Duration(days: 7 * i));
      int weekKey = weekDate.year * 1000 + _getWeekNumber(weekDate);
      weeklyCompletedCounts[weekKey] = 0;
    }

    for (var task in tasks) {
      if ((task.isCompleted ?? false) && task.date != null) {
        final taskCompletedDate = task.date!;
        final taskWeekNumber = _getWeekNumber(taskCompletedDate);
        final taskYear = taskCompletedDate.year;

        int weekKey = taskYear * 1000 + taskWeekNumber;
        if (weeklyCompletedCounts.containsKey(weekKey)) {
          weeklyCompletedCounts[weekKey] =
              (weeklyCompletedCounts[weekKey] ?? 0) + 1;
        }
      }
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < numberOfWeeks; i++) {
      DateTime weekDate = startOfCurrentWeek.subtract(
        Duration(days: 7 * (numberOfWeeks - 1 - i)),
      );
      int weekKey = weekDate.year * 1000 + _getWeekNumber(weekDate);
      spots.add(
        FlSpot(i.toDouble(), (weeklyCompletedCounts[weekKey] ?? 0).toDouble()),
      );
    }

    return spots;
  }

  double _getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 5.0;
    double maxY = 0.0;
    for (var spot in spots) {
      if (spot.y > maxY) {
        maxY = spot.y;
      }
    }
    return (maxY / 5).ceil() * 5.0 + 5;
  }

  List<String> _getWeekLabels(int numberOfWeeks) {
    final now = DateTime.now();
    DateTime startOfCurrentWeek = now.subtract(
      Duration(days: now.weekday == DateTime.sunday ? 6 : now.weekday - 1),
    );
    List<String> labels = [];
    for (int i = 0; i < numberOfWeeks; i++) {
      DateTime weekDate = startOfCurrentWeek.subtract(
        Duration(days: 7 * (numberOfWeeks - 1 - i)),
      );
      labels.add('${weekDate.month}/${weekDate.day}');
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<TaskModel>>(
      valueListenable: Hive.box<TaskModel>('tasks').listenable(),
      builder: (context, box, _) {
        final allTasks = box.values.toList();
        int completedMainTasksCount = allTasks
            .where((task) => task.isCompleted ?? false)
            .length;
        final totalTasks = allTasks.length;
        final pendingTasks = totalTasks - completedMainTasksCount;

        final int numberOfWeeksToShow = 5;
        final List<FlSpot> chartData = _getCompletedTasksDataForWeeklyChart(
          allTasks,
          numberOfWeeksToShow,
        );
        final double maxYValue = _getMaxY(chartData);
        final List<String> weekLabels = _getWeekLabels(numberOfWeeksToShow);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Profil',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue.shade700
                      : Colors.blue.shade50,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.blue.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Terus patuhi rencana Anda selama $_daysKeptToPlan hari!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ringkasan Tugas',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                completedMainTasksCount.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tugas Selesai',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pendingTasks.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tugas Tertunda',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Penyelesaian Tugas Mingguan',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Theme.of(context).cardColor,
                  child: Container(
                    height: 250,
                    padding: const EdgeInsets.all(16.0),
                    child: chartData.every((spot) => spot.y == 0)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Tidak ada tugas yang diselesaikan dalam beberapa minggu terakhir.',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Data akan muncul di sini saat Anda menandai tugas utama selesai.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color
                                        // ignore: deprecated_member_use
                                        ?.withOpacity(0.1) ??
                                        // ignore: deprecated_member_use
                                        Colors.grey.shade600.withOpacity(0.1),
                                    strokeWidth: 0.1,
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color
                                        // ignore: deprecated_member_use
                                        ?.withOpacity(0.1) ??
                                        // ignore: deprecated_member_use
                                        Colors.grey.shade600.withOpacity(0.1),
                                    strokeWidth: 0.1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 &&
                                          index < weekLabels.length) {
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          space: 8.0,
                                          child: Text(
                                            weekLabels[index],
                                            style: GoogleFonts.poppins(
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: maxYValue > 10 ? 5 : 1,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: GoogleFonts.poppins(
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.left,
                                      );
                                    },
                                    reservedSize: 40,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color
                                      // ignore: deprecated_member_use
                                      ?.withOpacity(0.5) ??
                                      // ignore: deprecated_member_use
                                      Colors.grey.shade600.withOpacity(0.5),
                                  width: 0.5,
                                ),
                              ),
                              minX: 0,
                              maxX: (numberOfWeeksToShow - 1).toDouble(),
                              minY: 0,
                              maxY: maxYValue,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: chartData,
                                  isCurved: true,
                                  color: Colors.deepPurple,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 3,
                                            color: Colors.deepPurpleAccent,
                                            strokeWidth: 1,
                                            strokeColor: Colors.deepPurple,
                                          );
                                        },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        // ignore: deprecated_member_use
                                        Colors.deepPurple.withOpacity(0.3),
                                        // ignore: deprecated_member_use
                                        Colors.deepPurple.withOpacity(0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
