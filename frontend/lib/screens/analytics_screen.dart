import 'package:flutter/material.dart';
import '../services/theme_helper.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Analytics & Insights'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _buildKpiCard(context, 'Completion Rate', '92%', '+12% this week', const Color(0xFF83A6CE), const Color(0xFF0B1B32), const Color(0xFF0B1B32)),
                _buildKpiCard(context, 'Missed Deadlines', '0 Missed', '-100% reduction', const Color(0xFFC48CB3), const Color(0xFF0B1B32), const Color(0xFF0B1B32)),
                _buildKpiCard(context, 'Focus Hours', '14.5 hr', '+3.2 hr increase', const Color(0xFFE5C9D7), const Color(0xFF0B1B32), const Color(0xFF0B1B32)),
                _buildKpiCard(context, 'Saved Deadlines', '7 Saves', 'AI early prevents', const Color(0xFF26415E), Colors.white, const Color(0xFF83A6CE)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Weekly Trends Panel
            Text('WEEKLY PRODUCTIVITY TRENDS', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14, letterSpacing: 1.1)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildChartBar('M', 0.4, colors.primary),
                        _buildChartBar('T', 0.6, colors.primary),
                        _buildChartBar('W', 0.85, colors.secondary), // Current day peak
                        _buildChartBar('T', 0.5, colors.primary),
                        _buildChartBar('F', 0.7, colors.primary),
                        _buildChartBar('S', 0.3, colors.primary),
                        _buildChartBar('S', 0.2, colors.primary),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Wednesday was your peak productivity focus day this week.',
                      style: TextStyle(fontSize: 12, color: colors.onSurface.withOpacity(0.6)),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Coaching Risk reduction Insight
            Card(
              color: const Color(0xFF0D1E4C), // Primary Navy
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF26415E), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.insights, color: Color(0xFFE5C9D7), size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Accountability coach interventions reduced your task postponement rate by 45% over the past 30 days.',
                        style: TextStyle(fontSize: 13, height: 1.4, color: colors.onSurface.withOpacity(0.9)),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, 
    String label, 
    String val, 
    String trend, 
    Color bgColor, 
    Color textColor,
    Color valueColor,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: textColor.withOpacity(0.15), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.65), fontWeight: FontWeight.bold)),
            Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: valueColor)),
            Text(trend, style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.65))),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(String day, double heightFactor, Color color) {
    return Column(
      children: [
        Container(
          height: 100 * heightFactor,
          width: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }
}
