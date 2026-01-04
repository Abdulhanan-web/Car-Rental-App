// ============= lib/pages/add_car_page.dart =============
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/car_provider.dart';
import '../models/car.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({Key? key}) : super(key: key);

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _colorController = TextEditingController();
  final _engineCapacityController = TextEditingController();
  final _registeredInController = TextEditingController();

  // Dropdown values
  String _bodyType = 'Sedan';
  String _fuelType = 'Petrol';
  String _transmission = 'Automatic';
  String _assembly = 'Local';
  
  final List<String> _bodyTypes = ['Sedan', 'SUV', 'Hatchback', 'Sports', 'Crossover', 'Convertible', 'Pickup', 'Van'];
  
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Rental', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A3D8A),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Section
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Add Car Image', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Basic Info
              _buildSectionTitle('Basic Information'),
              _buildTextField(_brandController, 'Brand (e.g. Honda)'),
              _buildTextField(_modelController, 'Model (e.g. Civic)'),
              _buildTextField(_yearController, 'Year (e.g. 2021)', keyboardType: TextInputType.number),
              
              DropdownButtonFormField<String>(
                value: _bodyType,
                decoration: const InputDecoration(labelText: 'Body Type', border: OutlineInputBorder()),
                items: _bodyTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => setState(() => _bodyType = val!),
              ),
              const SizedBox(height: 16),
              
              _buildSectionTitle('Technical Specifications'),
              _buildTextField(_mileageController, 'Mileage (e.g. 10,000 km)'),
              _buildTextField(_engineCapacityController, 'Engine Capacity (e.g. 1500cc)'),
              
              // Dropdowns Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _fuelType,
                      decoration: const InputDecoration(labelText: 'Fuel Type', border: OutlineInputBorder()),
                      items: ['Petrol', 'Diesel', 'Hybrid', 'Electric'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (val) => setState(() => _fuelType = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _transmission,
                      decoration: const InputDecoration(labelText: 'Transmission', border: OutlineInputBorder()),
                      items: ['Automatic', 'Manual'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (val) => setState(() => _transmission = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _assembly,
                decoration: const InputDecoration(labelText: 'Assembly', border: OutlineInputBorder()),
                items: ['Local', 'Imported'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => setState(() => _assembly = val!),
              ),
              
              const SizedBox(height: 16),
              _buildSectionTitle('Additional Details'),
              _buildTextField(_colorController, 'Exterior Color'),
              _buildTextField(_registeredInController, 'Registered In (City)'),
              _buildTextField(_locationController, 'Pickup Location'),
              _buildTextField(_priceController, 'Price per day (\$)', keyboardType: TextInputType.number),
              _buildTextField(_descriptionController, 'Car Description (Renter Comments)', maxLines: 3),
              
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final car = Car(
                        id: DateTime.now().toString(),
                        brand: _brandController.text,
                        model: _modelController.text,
                        year: _yearController.text,
                        pricePerDay: double.tryParse(_priceController.text) ?? 0.0,
                        type: _bodyType,
                        pickupLocation: _locationController.text,
                        description: _descriptionController.text,
                        mileage: _mileageController.text,
                        fuelType: _fuelType,
                        transmission: _transmission,
                        exteriorColor: _colorController.text,
                        assembly: _assembly,
                        engineCapacity: _engineCapacityController.text,
                        registeredIn: _registeredInController.text,
                        imageUrl: _image?.path ?? 'https://via.placeholder.com/300x200',
                        ownerId: '1',
                      );
                      
                      context.read<CarProvider>().addCar(car);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Car added successfully')),
                      );
                      
                      _clearForm();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3D8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add Car', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3D8A)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  void _clearForm() {
    _brandController.clear();
    _modelController.clear();
    _yearController.clear();
    _priceController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _mileageController.clear();
    _engineCapacityController.clear();
    _colorController.clear();
    _registeredInController.clear();
    setState(() {
      _image = null;
      _bodyType = 'Sedan';
      _fuelType = 'Petrol';
      _transmission = 'Automatic';
      _assembly = 'Local';
    });
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _mileageController.dispose();
    _engineCapacityController.dispose();
    _colorController.dispose();
    _registeredInController.dispose();
    super.dispose();
  }
}
