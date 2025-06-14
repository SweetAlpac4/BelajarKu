import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:belajarku/home_page.dart';
import 'dart:async'; // Import untuk Timer

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1), // Durasi animasi logo
      vsync: this,
    );

    // Animasi posisi logo (dari bawah ke tengah)
    _positionAnimation =
        Tween<Offset>(
          begin: const Offset(
            0,
            0.5,
          ), // Mulai dari bawah (relatif terhadap Center)
          end: Offset.zero, // Berakhir di tengah
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic, // Kurva animasi yang lebih halus
          ),
        );

    // Animasi fade untuk teks
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.5,
          1.0,
          curve: Curves.easeIn,
        ), // Mulai fade setelah logo bergerak setengah jalan
      ),
    );

    // Mulai animasi setelah widget dirender
    _controller.forward();

    // Timer untuk transisi otomatis ke HomePage
    Timer(const Duration(seconds: 3), () {
      // Transisi setelah 3 detik
      if (mounted) {
        // Pastikan widget masih ada sebelum navigasi
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Pastikan controller animasi dibuang
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: _positionAnimation, // Terapkan animasi posisi pada logo
              child: const Icon(
                Icons.school_outlined, // Ikon edukasi
                size: 150,
                color: Colors
                    .deepPurple, // Ubah warna ikon agar terlihat di latar putih
              ),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _fadeAnimation, // Terapkan animasi fade pada teks
              child: Column(
                children: [
                  Text(
                    'Belajarku',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .deepPurple
                          .shade700, // Warna teks agar terlihat
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Jadwal Studi, Lebih Mudah!',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.grey.shade700, // Warna teks agar terlihat
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20), // Kurangi spasi, tidak ada tombol
                  Text(
                    'Versi 1.0',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
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
