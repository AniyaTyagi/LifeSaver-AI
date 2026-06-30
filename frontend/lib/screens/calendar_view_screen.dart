import 'package:flutter/material.dart';
import '../services/theme_helper.dart';

class CalendarViewScreen extends StatelessWidget {
  const CalendarViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Simulated schedule entries
    final List<Map<String, dynamic>> scheduleItems = [
      {
        "time": "09:00 - 11:00",
        "title": "Code Compiler AST Parser",
        "type": "AI Focus Block",
        "description": "Allocated by Agent 4 to resolve High Risk Compiler Task.",
        "isAI": true
      },
      {
        "time": "11:30 - 12:00",
        "title": "Daily Standup Meeting",
        "type": "Google Calendar Sync",
        "description": "Syncd from primary work calendar calendar.",
        "isAI": false
      },
      {
        "time": "13:00 - 14:30",
        "title": "Review Marketing Strategy Mockups",
        "type": "AI Focus Block",
        "description": "Autoscheduled to ensure presentation preparedness.",
        "isAI": true
      },
      {
        "time": "15:00 - 16:00",
        "title": "Investor Pitch Sync Meeting",
        "type": "Google Calendar Sync",
        "description": "Conflict: 2 overlapping bookings detected.",
        "isAI": false,
        "conflict": true
      }
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Agenda Scheduler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Weekly Date Strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: colors.surface.withOpacity(0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDayItem(context, 'Mon', '22', false),
                _buildDayItem(context, 'Tue', '23', false),
                _buildDayItem(context, 'Wed', '24', true, colors.primary), // Active Day
                _buildDayItem(context, 'Thu', '25', false),
                _buildDayItem(context, 'Fri', '26', false),
                _buildDayItem(context, 'Sat', '27', false),
                _buildDayItem(context, 'Sun', '28', false),
              ],
            ),
          ),
          
          // Timeline Schedule
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: scheduleItems.length,
              itemBuilder: (context, index) {
                final item = scheduleItems[index];
                final isAI = item["isAI"] as bool;
                final isConflict = item["conflict"] == true;

                final style = paletteStyles[index % 5];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: style.bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isConflict ? colors.error : style.border,
                      width: 1.5
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item["time"],
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                color: style.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isConflict ? colors.error.withOpacity(0.2) : style.border.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item["type"],
                                style: TextStyle(
                                  color: isConflict ? colors.error : style.text,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item["title"],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: style.text),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item["description"],
                          style: TextStyle(color: style.textSecondary, fontSize: 12),
                        ),
                        if (isConflict) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: colors.error, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Conflict Detected. AI rescheduling recommended.',
                                style: TextStyle(color: colors.error, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDayItem(BuildContext context, String day, String date, bool isSelected, [Color? selectColor]) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(day, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        Container(
          height: 36,
          width: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? selectColor : Colors.transparent,
          ),
          child: Text(
            date,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : colors.onBackground,
            ),
          ),
        )
      ],
    );
  }
}
