// lib/screens/main_navigation/add_car_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../models/car_model.dart';

class AddCarPage extends StatefulWidget {
  @override
  _AddCarPageState createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  List<File> _selectedImages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images.map((xFile) => File(xFile.path)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      List<String> imageUrls = await _storageService.uploadCarImages(
        _selectedImages,
        user.uid,
      );

      final userDoc = await _firestoreService.getUserProfile(user.uid);
      final userName = userDoc?.name ?? 'Unknown';

      final car = CarModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ownerId: user.uid,
        ownerName: userName,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        pricePerDay: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
        imageUrls: imageUrls,
        location: _locationController.text.trim(),
        isAvailable: true,
        createdAt: DateTime.now(),
      );

      String? error = await _firestoreService.addCar(car);

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car added successfully!')),
        );
        _clearForm();
      } else {
        throw Exception(error);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _brandController.clear();
    _modelController.clear();
    _yearController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _locationController.clear();
    setState(() {
      _selectedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your Car'),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Car Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              _buildImagesSection(),
              const SizedBox(height: 24),

              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand *',
                  hintText: 'e.g., Toyota, Honda',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter brand';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model *',
                  hintText: 'e.g., Camry, Civic',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Year *',
                  hintText: 'e.g., 2020',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter year';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price per Day (\$) *',
                  hintText: 'e.g., 50',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  hintText: 'e.g., New York, NY',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Tell renters about your car...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  if (value.length < 20) {
                    return 'Description should be at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Add Car',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Photos *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Photos'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_selectedImages.isEmpty)
          Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No photos selected'),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_selectedImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}