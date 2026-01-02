// lib/screens/main_navigation/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../../services/firestore_service.dart';
import '../../services/local_car_service.dart';
import '../../models/car_model.dart';
import '../car/car_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final LocalCarService _localCarService = LocalCarService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color themeBlue = Color(0xFF2145A1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header and Search Bar
            Container(
              color: themeBlue,
              padding: const EdgeInsets.only(bottom: 20),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildSearchBar(),
                  ],
                ),
              ),
            ),
            _buildCategories(),
            _buildWeekendSpecialBanner(),
            _buildFeaturedCarsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Car Rental',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for a car...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'name': 'SUV', 'icon': '🚙'},
      {'name': 'Sedan', 'icon': '🚗'},
      {'name': 'Electric', 'icon': '⚡'},
      {'name': 'Luxury', 'icon': '👑'},
      {'name': 'Van', 'icon': '🚐'},
      {'name': 'Sports', 'icon': '🏎️'},
    ];

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.3,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category['name'];

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = category['name']!);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2145A1) : Colors.grey[200]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(category['icon']!, style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 2),
                      Text(
                        category['name']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekendSpecialBanner() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekend Special',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Get 20% off on all rentals', style: TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.local_offer, color: Colors.white, size: 30),
        ],
      ),
    );
  }

  Widget _buildFeaturedCarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Featured Cars', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
        ),
        _buildCarsList(),
      ],
    );
  }

  Widget _buildCarsList() {
    return StreamBuilder<List<CarModel>>(
      stream: _localCarService.getAllCars(),
      builder: (context, localSnapshot) {
        return StreamBuilder<List<CarModel>>(
          stream: _firestoreService.getAllCars(),
          builder: (context, firestoreSnapshot) {
            List<CarModel> allCars = [];
            
            if (localSnapshot.hasData) {
              allCars.addAll(localSnapshot.data!);
            }
            
            if (firestoreSnapshot.hasData) {
              allCars.addAll(firestoreSnapshot.data!);
            }

            if (allCars.isEmpty && 
                firestoreSnapshot.connectionState == ConnectionState.waiting && 
                localSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ));
            }

            if (allCars.isEmpty) {
              return const Center(child: Text('No cars available'));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: allCars.length,
              itemBuilder: (context, index) => _buildCarCard(allCars[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildCarCard(CarModel car) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CarDetailPage(car: car))),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: car.imageUrls.isNotEmpty
                  ? _buildCarImage(car.imageUrls[0])
                  : Container(height: 160, color: Colors.grey[200], child: const Icon(Icons.directions_car, size: 40)),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${car.brand} ${car.model}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(car.location, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  Text('\$${car.pricePerDay.toStringAsFixed(0)}/day', style: const TextStyle(color: Color(0xFF2145A1), fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCarImage(String url) {
    if (kIsWeb || url.startsWith('http') || url.startsWith('blob:')) {
      return Image.network(url, height: 160, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder());
    } else {
      return Image.file(File(url), height: 160, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder());
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: 160,
      color: Colors.grey[300],
      child: const Icon(Icons.directions_car, size: 60),
    );
  }
}
