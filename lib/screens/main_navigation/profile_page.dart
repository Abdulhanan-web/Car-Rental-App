// lib/screens/main_navigation/profile_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../auth/welcome_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await _firestoreService.getUserProfile(user.uid);
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: Text('Please login to view your profile'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 20),
              _buildProfileInfo(),
              const SizedBox(height: 20),
              _buildMenuItems(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue[200],
            backgroundImage: _userProfile?.photoUrl != null
                ? NetworkImage(_userProfile!.photoUrl!)
                : null,
            child: _userProfile?.photoUrl == null
                ? Text(
              _userProfile?.name[0].toUpperCase() ?? 'U',
              style: const TextStyle(fontSize: 48, color: Colors.white),
            )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _userProfile?.name ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 24),
              _buildInfoRow(
                Icons.person,
                'Name',
                _userProfile?.name ?? 'Not set',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.email,
                'Email',
                _userProfile?.email ?? 'Not set',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.phone,
                'Phone',
                _userProfile?.phoneNumber ?? 'Not set',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.calendar_today,
                'Member Since',
                _formatDate(_userProfile?.createdAt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildMenuItem(
            Icons.history,
            'Rental History',
                () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          _buildMenuItem(
            Icons.favorite,
            'Favorites',
                () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          _buildMenuItem(
            Icons.settings,
            'Settings',
                () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          _buildMenuItem(
            Icons.help_outline,
            'Help & Support',
                () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          _buildMenuItem(
            Icons.info_outline,
            'About',
                () {
              _showAboutDialog();
            },
          ),
          const SizedBox(height: 16),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Card(
      color: Colors.red[50],
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        ),
        onTap: _handleLogout,
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userProfile?.name);
    final phoneController = TextEditingController(text: _userProfile?.phoneNumber);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await _firestoreService.updateUserProfile(
                    user.uid,
                    {
                      'name': nameController.text,
                      'phoneNumber': phoneController.text,
                    },
                  );
                  Navigator.pop(context);
                  _loadUserProfile();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Car Rental App'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version: 1.0.0'),
              SizedBox(height: 8),
              Text('A modern car rental platform'),
              SizedBox(height: 8),
              Text('© 2024 Car Rental App'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _authService.logout();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => WelcomePage()),
                      (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}