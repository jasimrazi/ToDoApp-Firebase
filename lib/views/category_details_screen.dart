import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todotask/services/firestore_service.dart'; // Import FirestoreService
import 'package:todotask/models/task_model.dart';
import 'package:todotask/widgets/checkbox_widget.dart'; // Import Task model

class CategoryDetailsScreen extends StatefulWidget {
  final String categoryName;
  final String categoryEmoji;

  CategoryDetailsScreen({
    required this.categoryName,
    required this.categoryEmoji,
  });

  @override
  _CategoryDetailsScreenState createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  void _showAddTaskDialog() {
    final TextEditingController _taskNameController = TextEditingController();
    DateTime _selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter task name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Select date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _selectedDate) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                ),
                controller: TextEditingController(
                  text: "${_selectedDate.toLocal()}".split(' ')[0],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_currentUser != null) {
                  await _firestoreService.addTask(
                    _currentUser!.uid,
                    widget.categoryName,
                    _taskNameController.text,
                    _selectedDate,
                  );
                  Navigator.of(context).pop();
                  setState(() {}); // Refresh tasks after adding
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Map<String, List<Task>> _groupTasksByDate(List<Task> tasks) {
    final Map<String, List<Task>> groupedTasks = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));

    for (var task in tasks) {
      final taskDate = DateTime(task.date.year, task.date.month, task.date.day);

      if (taskDate.isAtSameMomentAs(today)) {
        groupedTasks.putIfAbsent("Today", () => []).add(task);
      } else if (taskDate.isAtSameMomentAs(tomorrow)) {
        groupedTasks.putIfAbsent("Tomorrow", () => []).add(task);
      } else {
        final dateString = "${taskDate.toLocal()}".split(' ')[0];
        groupedTasks.putIfAbsent(dateString, () => []).add(task);
      }
    }

    // Sort keys to ensure "Today" and "Tomorrow" appear first
    final orderedKeys = ["Today", "Tomorrow"]..addAll(groupedTasks.keys
        .where((key) => key != "Today" && key != "Tomorrow")
        .toList());

    final orderedGroupedTasks = {
      for (var key in orderedKeys)
        if (groupedTasks.containsKey(key)) key: groupedTasks[key]!,
    };

    return orderedGroupedTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: StreamBuilder<List<Task>>(
        stream: _currentUser != null
            ? _firestoreService.getTasks(_currentUser!.uid, widget.categoryName)
            : Stream.value([]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final tasks = snapshot.data ?? [];
          final groupedTasks = _groupTasksByDate(tasks);

          if (groupedTasks.isEmpty) {
            return Center(child: Text("No tasks available"));
          }

          return ListView(
            children: groupedTasks.entries.map((entry) {
              final dateLabel = entry.key;
              final tasksForDate = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      dateLabel,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ...tasksForDate.map((task) => ListTile(
                        title: Text(task.name),
                        subtitle: Text("${task.date.toLocal()}".split(' ')[0]),
                        leading: CustomCheckbox(
                          value: task.isCompleted,
                          onChanged: (value) async {
                            if (_currentUser != null) {
                              await _firestoreService.updateTaskCompletion(
                                _currentUser!.uid,
                                widget.categoryName,
                                task.id,
                                value ?? false,
                              );
                              setState(() {}); // Refresh tasks after updating
                            }
                          },
                        ),
                      )),
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.black, // Black background color
        child: const Icon(Icons.add, color: Colors.white), // White plus icon
        shape: const CircleBorder(), // Ensures the FAB is circular
      ),
    );
  }
}
