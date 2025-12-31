import 'package:flutter/material.dart';
import 'home_page.dart';
import 'add_car_page.dart';
import 'chats_page.dart';
import 'my_ads_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    MyAdsPage(),
    AddCarPage(),
    ChatsPage(),
    ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color themeBlue = Color(0xFF2145A1);
    const Color activeColor = Colors.white;
    const Color inactiveColor = Color(0xFFBCC6D9); // Clear whitish-grey

    // Total height of the widget including the bump
    double totalHeight = 110.0;
    // Height of the rectangular part of the bar
    double barHeight = 75.0;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: totalHeight,
        color: Colors.transparent, // Background must be transparent for the bump to work
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // 1. The main blue rectangle (the "floor" of the bar)
            Container(
              height: barHeight,
              decoration: const BoxDecoration(
                color: themeBlue,
              ),
            ),

            // 2. The Blue "Bump" (Larger and taller)
            Positioned(
              top: 5, // Controls how high the circle pops up
              child: Container(
                height: 90, // Increased diameter
                width: 90,
                decoration: const BoxDecoration(
                  color: themeBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // 3. Navigation Content
            Container(
              height: totalHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildNavItem(0, Icons.home_outlined, "Home", activeColor, inactiveColor),
                  _buildNavItem(1, Icons.menu, "My ads", activeColor, inactiveColor),

                  // Center "Rent out" Button
                  _buildCenterItem(2, "Rent out", activeColor),

                  _buildNavItem(3, Icons.chat_bubble_outline, "Chat", activeColor, inactiveColor),
                  _buildNavItem(4, Icons.account_circle_outlined, "Account", activeColor, inactiveColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color active, Color inactive) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0), // Padding from bottom of bar
        child: SizedBox(
          width: 65,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? active : inactive, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? active : inactive,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterItem(int index, String label, Color color) {
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15), // Lifts the center content
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: color, size: 48), // Larger + icon
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}