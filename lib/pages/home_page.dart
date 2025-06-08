import 'package:flutter/material.dart';
import '../models/learning_plan.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<LearningPlan> plans = [];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _addPlan() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) return;

    setState(() {
      plans.add(LearningPlan(title: title, description: description));
      _titleController.clear();
      _descriptionController.clear();
    });
  }

  void _deletePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  void _editPlan(int index) {
    final plan = plans[index];
    _titleController.text = plan.title;
    _descriptionController.text = plan.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Rencana'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _titleController.clear();
                _descriptionController.clear();
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  plans[index].title = _titleController.text;
                  plans[index].description = _descriptionController.text;
                });
                _titleController.clear();
                _descriptionController.clear();
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rencana Belajar"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _addPlan,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Rencana'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: plans.isEmpty
                  ? const Center(
                      child: Text("Belum ada rencana, tambah dulu yuk~"),
                    )
                  : ListView.builder(
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              plan.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: plan.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(plan.description),
                            leading: Checkbox(
                              value: plan.isDone,
                              onChanged: (value) {
                                setState(() {
                                  plan.isDone = value ?? false;
                                });
                              },
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editPlan(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deletePlan(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
