import 'package:flutter/material.dart';
import 'learning_task_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Map<String, String>> tasks = [
    {
      'title': 'Belajar Flutter',
      'description': 'Pelajari widget dasar Flutter seperti Text, Row, Column.',
    },
    {
      'title': 'Implementasi ListView',
      'description': 'Gunakan ListView.builder untuk menampilkan data dinamis.',
    },
    {
      'title': 'State Management',
      'description': 'Pahami cara menggunakan setState dan Provider.',
    },
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Task Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _descController.clear();
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text.trim();
              final desc = _descController.text.trim();
              if (title.isNotEmpty && desc.isNotEmpty) {
                setState(() {
                  tasks.add({'title': title, 'description': desc});
                });
                _titleController.clear();
                _descController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas Belajar'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addTask)],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Stack(
            children: [
              LearningTaskCard(
                title: task['title']!,
                description: task['description']!,
                onEdit: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Edit Task'),
                      content: Text('Edit tugas: ${task['title']}'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                onDelete: () => _deleteTask(index),
              ),
            ],
          );
        },
      ),
    );
  }
}
