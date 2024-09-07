import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todotask/models/category_model.dart';
import 'package:todotask/models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new category
  Future<void> addCategory(
      String userId, String categoryName, String emoji) async {
    await _db.collection('users').doc(userId).collection('categories').add({
      'name': categoryName,
      'emoji': emoji,
    });
  }

   // Stream to get categories of a user
  Stream<List<Category>> getCategories(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('categories')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  // Add a new task to a category
  Future<void> addTask(String userId, String categoryName, String taskName,
      DateTime taskDate) async {
    final categoryRef =
        _db.collection('users').doc(userId).collection('categories');
    final categorySnapshot =
        await categoryRef.where('name', isEqualTo: categoryName).limit(1).get();

    if (categorySnapshot.docs.isNotEmpty) {
      final categoryId = categorySnapshot.docs.first.id;
      await _db
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc(categoryId)
          .collection('tasks')
          .add({
        'name': taskName,
        'date': taskDate,
        'isCompleted': false,
      });
    }
  }

  // Update task completion status
  Future<void> updateTaskCompletion(String userId, String categoryName,
      String taskId, bool isCompleted) async {
    final categoryRef =
        _db.collection('users').doc(userId).collection('categories');
    final categorySnapshot =
        await categoryRef.where('name', isEqualTo: categoryName).limit(1).get();

    if (categorySnapshot.docs.isNotEmpty) {
      final categoryId = categorySnapshot.docs.first.id;
      await _db
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc(categoryId)
          .collection('tasks')
          .doc(taskId)
          .update({'isCompleted': isCompleted});
    }
  }

  // Stream to get tasks of a category
  Stream<List<Task>> getTasks(String userId, String categoryName) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .limit(1)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final categoryId = snapshot.docs.first.id;
        final taskSnapshot = await _db
            .collection('users')
            .doc(userId)
            .collection('categories')
            .doc(categoryId)
            .collection('tasks')
            .get();
        return taskSnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      }
      return [];
    });
  }
}


