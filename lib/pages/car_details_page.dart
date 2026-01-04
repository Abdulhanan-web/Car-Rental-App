// ============= lib/pages/car_details_page.dart =============
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../providers/car_provider.dart';
import 'rent_car_page.dart';

class CarDetailsPage extends StatelessWidget {
  final Car car;

  const CarDetailsPage({Key? key, required this.car}) : super(key: key);

  Widget _buildCarImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.directions_car, size: 100)),
      );
    } else {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.directions_car, size: 100)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes in the car provider to update the favorite icon
    final carFromProvider = context.watch<CarProvider>().cars.firstWhere((c) => c.id == car.id);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${carFromProvider.brand} ${carFromProvider.model}'),
        backgroundColor: const Color(0xFF1A3D8A), 
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: _buildCarImage(carFromProvider.imageUrl),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Featured',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      context.read<CarProvider>().toggleFavorite(carFromProvider.id);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.7),
                      child: Icon(
                        carFromProvider.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: carFromProvider.isFavorite ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${carFromProvider.brand} ${carFromProvider.model}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${carFromProvider.pricePerDay.toStringAsFixed(0)}/day',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.black, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        carFromProvider.pickupLocation,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Icons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoIcon(Icons.calendar_today, carFromProvider.year),
                      _buildInfoIcon(Icons.speed, carFromProvider.mileage),
                      _buildInfoIcon(Icons.local_gas_station, carFromProvider.fuelType),
                      _buildInfoIcon(Icons.settings, carFromProvider.transmission),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  _buildDetailRow("Registered In", carFromProvider.registeredIn),
                  _buildDetailRow("Exterior Color", carFromProvider.exteriorColor),
                  _buildDetailRow("Assembly", carFromProvider.assembly),
                  _buildDetailRow("Engine Capacity", carFromProvider.engineCapacity),
                  _buildDetailRow("Body Type", carFromProvider.type),
                  _buildDetailRow("Last Updated", "20 Oct 2025"),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    "Renter Comments",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    carFromProvider.description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A3D8A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RentCarPage(car: carFromProvider)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Rent Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Chat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }
}
