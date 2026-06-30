import 'package:flutter/material.dart';
import '../services/theme_helper.dart';

class GoalTrackerScreen extends StatelessWidget {
  const GoalTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> goals = [
      {
        "title": "Graduate CS with GPA > 3.8",
        "category": "Academic",
        "progress": 0.74,
        "tasksCount": 10,
        "completedCount": 8,
        "color": colors.primary
      },
      {
        "title": "Secure UI/UX Summer Internship",
        "category": "Career",
        "progress": 0.50,
        "tasksCount": 6,
        "completedCount": 3,
        "color": colors.secondary
      },
      {
        "title": "Complete 5K Running Challenge",
        "category": "Personal",
        "progress": 0.35,
        "tasksCount": 10,
        "completedCount": 3,
        "color": Colors.pinkAccent
      }
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Goal Progress'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          final double progress = goal["progress"];

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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: style.text.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          goal["category"],
                          style: TextStyle(
                            color: style.text,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}% Done',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: style.text),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    goal["title"],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: style.text),
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress indicator bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: style.text.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        style.accent == Colors.white || style.accent == style.text ? const Color(0xFFC48CB3) : style.accent
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Icon(Icons.checklist, size: 14, color: style.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${goal["completedCount"]} of ${goal["tasksCount"]} contributing tasks completed',
                        style: TextStyle(fontSize: 12, color: style.textSecondary),
                      ),
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
