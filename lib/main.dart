import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:belajarku/models/task_model.dart';
import 'package:belajarku/splash_page.dart';
import 'package:belajarku/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());

  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<bool>(ThemeProvider.themeBoxName);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Belajarku',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.grey[700]),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        cardColor: Colors.white,
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.poppins(color: Colors.black87),
          bodyMedium: GoogleFonts.poppins(color: Colors.grey[700]),
          titleLarge: GoogleFonts.poppins(color: Colors.black87),
          titleMedium: GoogleFonts.poppins(color: Colors.grey[800]),
          titleSmall: GoogleFonts.poppins(color: Colors.grey[600]),
          bodySmall: GoogleFonts.poppins(color: Colors.grey[500]),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[800],
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.poppins(color: Colors.white70),
          bodyMedium: GoogleFonts.poppins(color: Colors.white70),
          titleLarge: GoogleFonts.poppins(color: Colors.white),
          titleMedium: GoogleFonts.poppins(color: Colors.white),
          titleSmall: GoogleFonts.poppins(color: Colors.white60),
          bodySmall: GoogleFonts.poppins(color: Colors.grey[400]),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white70),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
