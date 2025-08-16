import 'package:flutter/material.dart';
import 'features/auth/login_screen.dart';
import 'features/patients/patients_screen.dart';

void main() {
  runApp(const BayleafApp());
}

class BayleafApp extends StatelessWidget {
  const BayleafApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF6EA06E);
    const textColor = Color(0xFF2F4732);

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        labelStyle: TextStyle(fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );

    return MaterialApp(
      title: 'Bayleaf',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routes: {
        '/': (_) => const LoginScreen(),
        '/patients': (_) => const PatientsScreen(),
      },
      initialRoute: '/',
    );
  }
}
