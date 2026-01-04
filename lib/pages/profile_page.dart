// ============= lib/pages/profile_page.dart =============
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'welcome_page.dart';
import 'edit_profile_page.dart';
import 'favorites_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Light blue background
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFF90CAF9),
                    child: Text(
                      user?.name[0] ?? 'A',
                      style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Abdul Hanan',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    user?.email ?? 'xyz@gmail.com',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Account Information Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.person_outline, 'Name', user?.name ?? 'Abdul Hanan'),
                    _buildInfoRow(Icons.email_outlined, 'Email', user?.email ?? 'xyz@gmail.com'),
                    _buildInfoRow(Icons.phone_outlined, 'Phone', user?.phone ?? '03213114620'),
                    _buildInfoRow(Icons.calendar_today_outlined, 'Member Since', user?.memberSince ?? '24/12/2025'),
                  ],
                ),
              ),
            ),

            // Options List
            _buildOptionTile(context, Icons.history, 'Rental History', null),
            _buildOptionTile(context, Icons.favorite_outline, 'Favorites', const FavoritesPage()),
            _buildOptionTile(context, Icons.settings_outlined, 'Settings', null),
            _buildOptionTile(context, Icons.help_outline, 'Help & Support', null),
            _buildOptionTile(context, Icons.info_outline, 'About', null),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: InkWell(
                onTap: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomePage()),
                    (route) => false,
                  );
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFFFEBEE)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 120), // Space for bottom navigation bar
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, IconData icon, String title, Widget? destination) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.blue),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {
            if (destination != null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title is coming soon!')),
              );
            }
          },
        ),
      ),
    );
  }
}
