import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:belajarku/models/task_model.dart';
import 'package:belajarku/add_schedule_bottom_sheet.dart';
import 'package:belajarku/edit_schedule_bottom_sheet.dart';
import 'package:belajarku/calendar_page.dart';
import 'package:belajarku/notification_page.dart';
import 'package:belajarku/profile_page.dart';
import 'package:belajarku/theme_provider.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0;

  // Pastikan ini non-nullable dan selalu diinisialisasi di initState
  late AnimationController _revealController;
  late Animation<double> _revealRadiusAnimation;
  GlobalKey _themeIconKey = GlobalKey();
  Offset? _revealOrigin;
  Color? _currentRevealColor; // Menyimpan warna yang akan diungkap

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    // Inisialisasi AnimationController dengan vsync: this
    _revealController = AnimationController(
      vsync: this, // 'this' merujuk pada SingleTickerProviderStateMixin
      duration: const Duration(milliseconds: 600), // Durasi animasi
    );

    // Animasi radius dari 0.0 ke 1.0 (meluas)
    _revealRadiusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: Curves.easeOutCubic, // Memberikan efek yang lebih halus
      ),
    );

    // Listener untuk mereset animasi setelah selesai
    _revealController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _revealOrigin = null;
          _currentRevealColor = null; // Reset warna setelah animasi selesai
        });
        _revealController
            .reset(); // Reset controller untuk penggunaan selanjutnya
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _revealController.dispose(); // Pastikan controller dibuang
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

  void _showAddScheduleBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddScheduleBottomSheet(),
    );
  }

  void _showEditScheduleBottomSheet(TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditScheduleBottomSheet(task: task),
    );
  }

  double _calculateMaxRadius(Size size, Offset center) {
    final double dx1 = size.width - center.dx;
    final double dx2 = center.dx;
    final double dy1 = size.height - center.dy;
    final double dy2 = center.dy;

    final double dist1 = sqrt((dx1 * dx1) + (dy1 * dy1));
    final double dist2 = sqrt((dx1 * dx1) + (dy2 * dy2));
    final double dist3 = sqrt((dx2 * dx2) + (dy1 * dy1));
    final double dist4 = sqrt((dx2 * dx2) + (dy2 * dy2));

    return max(max(dist1, dist2), max(dist3, dist4));
  }

  void _handleThemeToggle(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Dapatkan posisi pusat ikon tema secara global
    final RenderBox? renderBox =
        _themeIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      // Fallback: jika posisi ikon tidak dapat ditemukan, langsung toggle tema
      themeProvider.toggleTheme();
      return;
    }

    // Tentukan warna tema tujuan sebelum memulai animasi
    // themeProvider.isDarkMode di sini adalah status tema *sebelum* toggle
    final Color targetThemeBgColor = themeProvider.isDarkMode
        ? Colors.grey[50]! // Jika saat ini gelap, target adalah terang
        : Colors.grey[900]!; // Jika saat ini terang, target adalah gelap

    // Set state untuk memulai animasi
    setState(() {
      _revealOrigin = renderBox.localToGlobal(
        renderBox.size.center(Offset.zero),
      );
      _currentRevealColor =
          targetThemeBgColor; // Simpan warna tema tujuan untuk animasi
    });

    // Mulai animasi reveal
    _revealController.forward();

    // Toggle tema utama aplikasi pada titik tengah animasi untuk transisi yang mulus
    // Ini akan menyebabkan MaterialApp merender ulang dengan tema baru
    Future.delayed(const Duration(milliseconds: 300), () {
      themeProvider.toggleTheme();
    });
  }

  Widget _buildTasksPage(List<TaskModel> allTasks) {
    final filteredTasks = allTasks.where((task) {
      final query = _searchQuery.toLowerCase();
      bool matchesMainTask =
          (task.title?.toLowerCase().contains(query) ?? false) ||
          (task.description?.toLowerCase().contains(query) ?? false) ||
          (task.category?.toLowerCase().contains(query) ?? false);

      bool matchesSubtask = task.subtasks.any(
        (sub) => sub.toLowerCase().contains(query),
      );
      return matchesMainTask || matchesSubtask;
    }).toList();

    filteredTasks.sort((a, b) {
      if ((a.isCompleted ?? false) && !(b.isCompleted ?? false)) return 1;
      if (!(a.isCompleted ?? false) && (b.isCompleted ?? false)) return -1;

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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari tugas atau sub-tugas',
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).iconTheme.color,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
            style: GoogleFonts.poppins(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        Expanded(
          child: filteredTasks.isEmpty
              ? Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'Tidak ada tugas yang ditambahkan.'
                        : 'Tidak ada hasil untuk "$_searchQuery"',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: (task.isCompleted ?? false)
                                            ? Colors.grey
                                            : Theme.of(
                                                context,
                                              ).textTheme.titleLarge?.color,
                                        decoration: (task.isCompleted ?? false)
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
                                      color: Theme.of(context).iconTheme.color,
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
                                      color: _getCategoryColor(task.category),
                                      borderRadius: BorderRadius.circular(8),
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
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final Color currentThemeBackgroundColor = Theme.of(
      context,
    ).scaffoldBackgroundColor;

    return Stack(
      children: [
        Scaffold(
          key: const ValueKey('HomePageScaffold'),
          backgroundColor: currentThemeBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Belajarku',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
            centerTitle: false,
            actions: [
              IconButton(
                key: _themeIconKey,
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).appBarTheme.iconTheme?.color,
                ),
                tooltip: 'Ganti Tema',
                onPressed: () {
                  _handleThemeToggle(context);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  color: Theme.of(context).appBarTheme.iconTheme?.color,
                ),
                tooltip: 'Notifikasi',
                onPressed: () {
                  setState(() {
                    _selectedTab = 2;
                  });
                },
              ),
            ],
          ),
          body: ValueListenableBuilder<Box<TaskModel>>(
            valueListenable: Hive.box<TaskModel>('tasks').listenable(),
            builder: (context, box, _) {
              final allTasks = box.values.toList();
              return IndexedStack(
                index: _selectedTab,
                children: [
                  _buildTasksPage(allTasks),
                  const CalendarPage(),
                  const NotificationPage(),
                  const ProfilePage(),
                ],
              );
            },
          ),
          floatingActionButton: _selectedTab == 0
              ? FloatingActionButton(
                  onPressed: _showAddScheduleBottomSheet,
                  backgroundColor: Colors.deepPurple,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedTab,
            onTap: (index) {
              setState(() {
                _selectedTab = index;
              });
            },
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Theme.of(context).iconTheme.color,
            backgroundColor: Theme.of(context).cardColor,
            selectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tugas'),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Kalender',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Notifikasi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
        // Overlay untuk transisi tema hanya jika _revealOrigin dan _currentRevealColor tidak null,
        // dan animasi sedang berjalan
        if (_revealOrigin != null &&
            _currentRevealColor != null &&
            _revealController.isAnimating)
          AnimatedBuilder(
            animation: _revealController,
            builder: (context, child) {
              final size = MediaQuery.of(context).size;
              final double maxRadius = _calculateMaxRadius(
                size,
                _revealOrigin!,
              );
              final currentRadius = _revealRadiusAnimation.value * maxRadius;

              return ClipPath(
                clipper: _ThemeRevealClipper(
                  radius: currentRadius,
                  center: _revealOrigin!,
                ),
                child: Container(
                  color: _currentRevealColor!, // Gunakan warna yang disimpan
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ThemeRevealClipper extends CustomClipper<Path> {
  final double radius;
  final Offset center;

  _ThemeRevealClipper({required this.radius, required this.center});

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant _ThemeRevealClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}
