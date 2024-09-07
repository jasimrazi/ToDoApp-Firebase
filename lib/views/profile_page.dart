import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                child: Icon(Icons.person, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),

            // Display user name
            Center(
              child: _currentUser != null
                  ? Text(
                      _currentUser!.displayName ?? 'Guest User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : CircularProgressIndicator(),
            ),
            const SizedBox(height: 32),

            // Sections
            Expanded(
              child: ListView(
                children: [
                  _buildListTile(
                    context,
                    Icons.notifications,
                    'Notifications',
                    () {},
                  ),
                  _buildListTile(
                    context,
                    Icons.settings,
                    'General',
                    () {},
                  ),
                  _buildListTile(
                    context,
                    Icons.account_circle,
                    'Account',
                    () {},
                  ),
                  _buildListTile(
                    context,
                    Icons.info,
                    'About',
                    () {},
                  ),
                  _buildListTile(
                    context,
                    Icons.logout,
                    'Logout',
                    () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a list tile
  Widget _buildListTile(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
