// ============= lib/pages/rent_car_page.dart =============
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../providers/car_provider.dart';

class RentCarPage extends StatefulWidget {
  final Car car;

  const RentCarPage({Key? key, required this.car}) : super(key: key);

  @override
  State<RentCarPage> createState() => _RentCarPageState();
}

class _RentCarPageState extends State<RentCarPage> {
  DateTime? _pickupDate;
  DateTime? _returnDate;
  bool _driverRequired = false;
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationController.text = "Lake City"; // Default from image
  }

  Future<void> _selectDate(BuildContext context, bool isPickup) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isPickup) {
          _pickupDate = picked;
        } else {
          _returnDate = picked;
        }
      });
    }
  }

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
    final carFromProvider = context.watch<CarProvider>().cars.firstWhere((c) => c.id == widget.car.id);

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
                  const Divider(),
                  const SizedBox(height: 20),

                  // Booking Form
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildBookingRow("Pickup Date:", _pickupDate == null ? "dd/mm/yyyy" : "${_pickupDate!.day}/${_pickupDate!.month}/${_pickupDate!.year}", () => _selectDate(context, true)),
                        _buildBookingRow("Return Date:", _returnDate == null ? "dd/mm/yyyy" : "${_returnDate!.day}/${_returnDate!.month}/${_returnDate!.year}", () => _selectDate(context, false)),
                        _buildBookingRowWithIcon("Pickup Location:", _locationController.text, Icons.location_on),
                        _buildDriverRow(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A3D8A),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking Confirmed!')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Confirm', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBookingRow(String label, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingRowWithIcon(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Driver Required:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Checkbox(
            value: _driverRequired,
            activeColor: const Color(0xFF1A3D8A),
            onChanged: (val) {
              setState(() {
                _driverRequired = val!;
              });
            },
          ),
        ],
      ),
    );
  }
}
