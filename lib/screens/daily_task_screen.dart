import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DailyTaskScreen extends StatefulWidget {
  final String userId;
  const DailyTaskScreen({super.key, required this.userId});

  @override
  State<DailyTaskScreen> createState() => _DailyTaskScreenState();
}

class _DailyTaskScreenState extends State<DailyTaskScreen> {
  Map<String, dynamic>? taskData;
  bool loading = true;
  bool completed = false;

  Future<void> fetchTask() async {
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          "http://192.168.152.126:5000/daily_task?user_id=${widget.userId}",
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          taskData = data;
          completed = data["completed"] ?? false;
          loading = false;
        });
      } else {
        throw Exception("Failed to fetch task");
      }
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> markComplete() async {
    if (taskData == null) return;
    try {
      final response = await http.post(
        Uri.parse("http://192.168.152.126:5000/complete_task"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": widget.userId,
          "task_id": taskData!["timestamp"],
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          completed = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Task marked as completed!")),
        );
      } else {
        throw Exception("Failed to complete task");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Task")),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : taskData == null
              ? const Center(child: Text("No task available"))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Today's Task:",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      taskData!["task"] ?? "No task",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: completed ? null : markComplete,
                      icon: Icon(completed ? Icons.check : Icons.done),
                      label: Text(completed ? "Completed" : "Mark as Done"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: completed ? Colors.grey : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
