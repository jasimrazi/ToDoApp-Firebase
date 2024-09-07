import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String name;
  final DateTime date;
  final bool isCompleted;

  Task({
    required this.id,
    required this.name,
    required this.date,
    required this.isCompleted,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      name: data['name'],
      date: (data['date'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'],
    );
  }
}
