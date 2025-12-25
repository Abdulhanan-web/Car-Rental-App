// lib/screens/main_navigation/home_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/car_model.dart';
import '../car/car_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Rental'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildCarList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search for cars...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Available', 'Sedan', 'SUV', 'Luxury'];

    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'All';
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.blue[100],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarList() {
    return StreamBuilder<List<CarModel>>(
      stream: _firestoreService.getAllCars(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('No cars available yet', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        List<CarModel> cars = snapshot.data!;

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          cars = cars.where((car) {
            return car.brand.toLowerCase().contains(_searchQuery) ||
                car.model.toLowerCase().contains(_searchQuery) ||
                car.location.toLowerCase().contains(_searchQuery);
          }).toList();
        }

        // Apply category filter
        if (_selectedFilter != 'All') {
          if (_selectedFilter == 'Available') {
            cars = cars.where((car) => car.isAvailable).toList();
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cars.length,
          itemBuilder: (context, index) {
            return _buildCarCard(cars[index]);
          },
        );
      },
    );
  }

  Widget _buildCarCard(CarModel car) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CarDetailPage(car: car),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: car.imageUrls.isNotEmpty
                  ? Image.network(
                car.imageUrls[0],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.directions_car, size: 80),
                  );
                },
              )
                  : Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.directions_car, size: 80),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${car.brand} ${car.model}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: car.isAvailable ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          car.isAvailable ? 'Available' : 'Rented',
                          style: TextStyle(
                            color: car.isAvailable ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Year: ${car.year}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        car.location,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${car.pricePerDay.toStringAsFixed(0)}/day',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: car.isAvailable
                            ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarDetailPage(car: car),
                            ),
                          );
                        }
                            : null,
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Cars'),
                leading: Radio(
                  value: 'All',
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Available Only'),
                leading: Radio(
                  value: 'Available',
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value.toString();
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
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
}