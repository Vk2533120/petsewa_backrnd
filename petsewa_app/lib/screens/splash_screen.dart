import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF354024).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, size: 80, color: Color(0xFF354024)),
            ),
            const SizedBox(height: 24),
            const Text(
              'PetSewa',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Care. Connect. Celebrate.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
