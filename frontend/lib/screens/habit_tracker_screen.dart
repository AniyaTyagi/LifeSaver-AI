import 'package:flutter/material.dart';
import '../services/theme_helper.dart';

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  final List<Map<String, dynamic>> _habits = [
    {
      "title": "LeetCode Daily Challenge",
      "frequency": "Daily",
      "streak": 8,
      "completedToday": true,
      "history": [true, true, true, true, false, true, true]
    },
    {
      "title": "30-Minute Focus Session",
      "frequency": "Daily",
      "streak": 12,
      "completedToday": false,
      "history": [true, true, true, true, true, true, false]
    },
    {
      "title": "Cardio Training",
      "frequency": "3x a Week",
      "streak": 3,
      "completedToday": false,
      "history": [false, true, false, true, false, true, false]
    }
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Habits & Streaks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          final habit = _habits[index];
          final completed = habit["completedToday"] as bool;

          final style = paletteStyles[index % 5];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: style.bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: style.border, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit["title"],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: style.text),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            habit["frequency"],
                            style: TextStyle(color: style.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      
                      // Check-in Circle Button
                      IconButton(
                        icon: Icon(
                          completed ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: completed 
                              ? (style.accent == Colors.white || style.accent == style.text ? const Color(0xFFC48CB3) : style.accent) 
                              : style.textSecondary,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            _habits[index]["completedToday"] = !completed;
                            if (!completed) {
                              _habits[index]["streak"] += 1;
                            } else {
                              _habits[index]["streak"] -= 1;
                            }
                          });
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Streak Indicator
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${habit["streak"]} Day Streak',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: style.text),
                      ),
                      const Spacer(),
                      // Render week dots history
                      Row(
                        children: (habit["history"] as List<bool>).map((dayCheck) {
                          return Container(
                            margin: const EdgeInsets.only(left: 4),
                            height: 8,
                            width: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dayCheck 
                                  ? (style.accent == Colors.white || style.accent == style.text ? const Color(0xFFC48CB3) : style.accent) 
                                  : style.text.withOpacity(0.15),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
