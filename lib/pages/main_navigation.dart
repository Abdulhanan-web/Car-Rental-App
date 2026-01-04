// ============= lib/pages/main_navigation.dart =============
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'my_ads_page.dart';
import 'add_car_page.dart';
import 'chats_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    MyAdsPage(),
    AddCarPage(),
    ChatsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // This allows the body to extend behind the bottom bar
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 85,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Blue Background Bar
            Container(
              height: 65,
              decoration: const BoxDecoration(
                color: Color(0xFF1A3D8A),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, 'Home'),
                  _buildNavItem(1, Icons.menu, 'My ads'),
                  const SizedBox(width: 60), // Space for the center button
                  _buildNavItem(3, Icons.chat_bubble_outline, 'Chat'),
                  _buildNavItem(4, Icons.person_outline, 'Account'),
                ],
              ),
            ),
            // The Raised "Rent out" Button
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A3D8A),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.add, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Rent out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(isSelected ? 1 : 0.9),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(isSelected ? 1 : 0.9),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
