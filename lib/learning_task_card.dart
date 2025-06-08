import 'package:flutter/material.dart';

class LearningTaskCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LearningTaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onEdit,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox placeholder (todo/done) - kalau mau kamu bisa ganti logicnya
            Checkbox(
              value: false,
              onChanged: (value) {
                // Kalau mau, implement state untuk done/todo
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              onPressed: onDelete,
              tooltip: 'Hapus Task',
            ),
          ],
        ),
      ),
    );
  }
}
