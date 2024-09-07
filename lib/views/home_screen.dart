import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todotask/models/category_model.dart';
import 'package:todotask/models/task_model.dart';
import 'package:todotask/services/firestore_service.dart'; // Import FirestoreService
import 'package:todotask/views/profile_page.dart';
import 'category_details_screen.dart'; // Import CategoryDetailsScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedEmoji = '';
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _emojiController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  // Function to handle the refresh
  Future<void> _refreshCategories() async {
    // Refresh logic: Fetch the latest categories (Firestore will automatically update the stream)
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search icon tap
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: _refreshCategories, // Pull-to-refresh handler
          child: StreamBuilder<List<Category>>(
            stream: _currentUser != null
                ? _firestoreService.getCategories(_currentUser!.uid)
                : Stream.value([]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final categories = snapshot.data ?? [];

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two grids per row
                ),
                itemCount: categories.length + 1, // Add one for the plus icon
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildPlusIconGridItem(
                        context); // First item with plus icon
                  } else {
                    final category = categories[index - 1];
                    return _buildCategoryGridItem(
                        category); // Display category items
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget for the first grid item with a plus icon
  Widget _buildPlusIconGridItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showAddCategoryDialog(context);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // No rounded corners
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 50,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  // Widget for a category grid item
  Widget _buildCategoryGridItem(Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailsScreen(
              categoryName: category.name,
              categoryEmoji: category.emoji,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // No rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.emoji,
                style: const TextStyle(fontSize: 40),
              ),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<Task>>(
                stream: _firestoreService.getTasks(
                    _currentUser!.uid, category.name),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading tasks...");
                  }
                  if (snapshot.hasError) {
                    return const Text("Error fetching tasks");
                  }

                  final taskCount = snapshot.data?.length ?? 0;
                  return Text(
                    "$taskCount task(s)",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to show the dialog for adding a new category
  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  hintText: 'Enter category name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emojiController,
                decoration: const InputDecoration(
                  hintText: 'Select an emoji',
                ),
                maxLength: 1, // Limit to a single character (emoji)
                onChanged: (value) {
                  setState(() {
                    _selectedEmoji = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              if (_selectedEmoji.isNotEmpty)
                Text(
                  _selectedEmoji,
                  style: const TextStyle(fontSize: 30),
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
                  await _firestoreService.addCategory(
                    _currentUser!.uid,
                    _categoryController.text,
                    _selectedEmoji,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
