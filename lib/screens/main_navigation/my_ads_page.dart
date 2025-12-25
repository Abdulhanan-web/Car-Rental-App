// lib/screens/main_navigation/my_ads_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/car_model.dart';
import '../car/edit_car_page.dart';

class MyAdsPage extends StatefulWidget {
  @override
  _MyAdsPageState createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Ads')),
        body: const Center(
          child: Text('Please login to view your ads'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ads'),
        elevation: 2,
      ),
      body: StreamBuilder<List<CarModel>>(
        stream: _firestoreService.getUserCars(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_car_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No cars posted yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the + icon to add your first car',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final cars = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              return _buildCarCard(cars[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildCarCard(CarModel car) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: car.imageUrls.isNotEmpty
                ? Image.network(
              car.imageUrls[0],
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.directions_car, size: 60),
                );
              },
            )
                : Container(
              height: 180,
              color: Colors.grey[300],
              child: const Icon(Icons.directions_car, size: 60),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: car.isAvailable
                            ? Colors.green[100]
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        car.isAvailable ? 'Available' : 'Rented',
                        style: TextStyle(
                          color: car.isAvailable
                              ? Colors.green[800]
                              : Colors.orange[800],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
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

                Text(
                  '\$${car.pricePerDay.toStringAsFixed(0)}/day',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCarPage(car: car),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteDialog(car),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _toggleAvailability(car),
                      icon: Icon(
                        car.isAvailable
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      tooltip: car.isAvailable
                          ? 'Mark as Unavailable'
                          : 'Mark as Available',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleAvailability(CarModel car) async {
    try {
      await _firestoreService.updateCarAvailability(
        car.id,
        !car.isAvailable,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            car.isAvailable
                ? 'Car marked as unavailable'
                : 'Car marked as available',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showDeleteDialog(CarModel car) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Car'),
          content: Text(
            'Are you sure you want to delete ${car.brand} ${car.model}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteCar(car);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCar(CarModel car) async {
    try {
      await _firestoreService.deleteCar(car.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting car: $e')),
      );
    }
  }
}