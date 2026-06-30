import 'package:flutter/material.dart';
import '../services/theme_helper.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _tasks = [
    {
      "title": "Compiler Project Design",
      "category": "Academic",
      "dueDate": "Friday, 11:59 PM",
      "riskScore": 85,
      "riskLevel": "High Risk",
      "completed": false,
      "dependencies": ["Gather requirements", "AST grammar review"]
    },
    {
      "title": "File Q3 Tax Returns",
      "category": "Work",
      "dueDate": "In 3 Days",
      "riskScore": 75,
      "riskLevel": "High Risk",
      "completed": false,
      "dependencies": []
    },
    {
      "title": "Renew Slide Design Tool Sub",
      "category": "Billing",
      "dueDate": "In 2 Days",
      "riskScore": 30,
      "riskLevel": "Medium Risk",
      "completed": false,
      "dependencies": []
    },
    {
      "title": "Update Design Portfolio",
      "category": "Personal",
      "dueDate": "Next Monday",
      "riskScore": 12,
      "riskLevel": "Low Risk",
      "completed": false,
      "dependencies": []
    }
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Filter tasks
    final filteredTasks = _selectedCategory == 'All' 
        ? _tasks 
        : _tasks.where((t) => t["category"] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Tasks Manager'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Academic', 'Work', 'Billing', 'Personal'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : colors.onBackground,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: colors.primary,
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Tasks List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                final risk = task["riskScore"] as int;
                
                // Set color indicator based on risk
                Color riskColor = const Color(0xFF82F4B8); // Low (mint)
                if (risk >= 70) {
                  riskColor = const Color(0xFFFF7070); // High (coral)
                } else if (risk >= 30) {
                  riskColor = const Color(0xFFFFB85C); // Med (amber)
                }

                final style = paletteStyles[index % 5];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: style.bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
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
                            Expanded(
                              child: Text(
                                task["title"], 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16, 
                                  color: style.text
                                )
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: riskColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${task["riskScore"]}% Risk',
                                style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: style.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              task["dueDate"], 
                              style: TextStyle(color: style.textSecondary, fontSize: 13)
                            ),
                            const Spacer(),
                            Text(
                              task["category"], 
                              style: TextStyle(
                                color: style.accent == Colors.white || style.accent == style.text ? const Color(0xFFC48CB3) : style.accent, 
                                fontSize: 12,
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ],
                        ),
                        if ((task["dependencies"] as List).isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Divider(height: 1, color: style.border.withOpacity(0.5)),
                          const SizedBox(height: 8),
                          Text(
                            'Dependencies: ${(task["dependencies"] as List).join(', ')}',
                            style: TextStyle(fontSize: 12, color: style.textSecondary.withOpacity(0.9), fontStyle: FontStyle.italic),
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

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(decoration: InputDecoration(labelText: 'Task Title')),
              const SizedBox(height: 8),
              const TextField(decoration: InputDecoration(labelText: 'Category (Academic, Work, Personal)')),
              const SizedBox(height: 8),
              const TextField(decoration: InputDecoration(labelText: 'Due Date')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                // Mock task additions
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
