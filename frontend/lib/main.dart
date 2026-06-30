import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Screen imports (implemented next)
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/task_manager_screen.dart';
import 'screens/calendar_view_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/goal_tracker_screen.dart';
import 'screens/habit_tracker_screen.dart';
import 'screens/focus_mode_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const LifeSaverApp());
}

class LifeSaverApp extends StatelessWidget {
  const LifeSaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeSaver AI',
      debugShowCheckedModeBanner: false,
      
      // Premium Light Material 3 Theme matching the mockup
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        
        // Premium Light Color Scheme from the mockup
        colorScheme: const ColorScheme.light(
          background: Color(0xFFF8FAFC), // Very light slate-blue background
          surface: Colors.white,         // Pure white cards and surfaces
          primary: Color(0xFF4F46E5),    // Indigo accent
          secondary: Color(0xFFEC4899),  // Pink accent
          error: Color(0xFFEF4444),      // Red error
          onBackground: Color(0xFF0F172A), // Slate-900 for dark text
          onSurface: Color(0xFF0F172A),
        ),
        
        // Font Configurations
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme.copyWith(
            displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 32, color: const Color(0xFF0F172A)),
            titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 20, color: const Color(0xFF0F172A)),
            bodyLarge: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF334155)),
            bodyMedium: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569)),
          ),
        ),
        
        // Card styling with subtle shadows and borders
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFFE2E8F0), width: 1), // Light border
          ),
        ),
      ),
      
      // Navigation Routes Configurations
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/tasks': (context) => const TaskManagerScreen(),
        '/calendar': (context) => const CalendarViewScreen(),
        '/chat': (context) => const AiChatScreen(),
        '/goals': (context) => const GoalTrackerScreen(),
        '/habits': (context) => const HabitTrackerScreen(),
        '/focus': (context) => const FocusModeScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
