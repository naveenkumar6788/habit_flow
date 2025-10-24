import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paceai/providers/habits_provider.dart';
import 'package:paceai/pages/habits/habit_editor_page.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitsProvider>();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Habits', style: Theme.of(context).textTheme.headlineMedium),
              FilledButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HabitEditorPage()),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('New Habit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final h in provider.habits)
            Card(
              child: ListTile(
                title: Text(h.title),
                subtitle: Text(h.description ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.blue),
                  onPressed: () => provider.toggleToday(h.id),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text('7-day Progress', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    spots: [
                      for (int i = 0; i < 7; i++)
                        FlSpot(i.toDouble(), provider.habits.isEmpty ? 0 : provider.completionsForLastNDays(provider.habits.first.id, 7 - i).toDouble()),
                    ],
                  ),
                ],
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
