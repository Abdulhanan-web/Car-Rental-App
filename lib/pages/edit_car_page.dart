// ============= lib/pages/edit_car_page.dart =============
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/car_provider.dart';
import '../models/car.dart';

class EditCarPage extends StatefulWidget {
  final Car car;
  const EditCarPage({Key? key, required this.car}) : super(key: key);

  @override
  State<EditCarPage> createState() => _EditCarPageState();
}

class _EditCarPageState extends State<EditCarPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _yearController;
  late TextEditingController _mileageController;
  late TextEditingController _colorController;
  late TextEditingController _engineCapacityController;
  late TextEditingController _registeredInController;

  late String _bodyType;
  late String _fuelType;
  late String _transmission;
  late String _assembly;
  
  final List<String> _bodyTypes = ['Sedan', 'SUV', 'Hatchback', 'Sports', 'Crossover', 'Convertible', 'Pickup', 'Van'];
  
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.car.brand);
    _modelController = TextEditingController(text: widget.car.model);
    _priceController = TextEditingController(text: widget.car.pricePerDay.toStringAsFixed(0));
    _locationController = TextEditingController(text: widget.car.pickupLocation);
    _descriptionController = TextEditingController(text: widget.car.description);
    _yearController = TextEditingController(text: widget.car.year);
    _mileageController = TextEditingController(text: widget.car.mileage);
    _colorController = TextEditingController(text: widget.car.exteriorColor);
    _engineCapacityController = TextEditingController(text: widget.car.engineCapacity);
    _registeredInController = TextEditingController(text: widget.car.registeredIn);

    _bodyType = widget.car.type;
    _fuelType = widget.car.fuelType;
    _transmission = widget.car.transmission;
    _assembly = widget.car.assembly;
  }

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
        title: const Text('Edit Car Ad'),
        backgroundColor: const Color(0xFF1A3D8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      : (widget.car.imageUrl.startsWith('http') 
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(widget.car.imageUrl, fit: BoxFit.cover),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(widget.car.imageUrl), fit: BoxFit.cover),
                            )),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Basic Information'),
              _buildTextField(_brandController, 'Brand'),
              _buildTextField(_modelController, 'Model'),
              _buildTextField(_yearController, 'Year', keyboardType: TextInputType.number),
              
              DropdownButtonFormField<String>(
                value: _bodyType,
                decoration: const InputDecoration(labelText: 'Body Type', border: OutlineInputBorder()),
                items: _bodyTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (val) => setState(() => _bodyType = val!),
              ),
              const SizedBox(height: 16),
              
              _buildSectionTitle('Technical Specifications'),
              _buildTextField(_mileageController, 'Mileage'),
              _buildTextField(_engineCapacityController, 'Engine Capacity'),
              
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
              _buildTextField(_registeredInController, 'Registered In'),
              _buildTextField(_locationController, 'Pickup Location'),
              _buildTextField(_priceController, 'Price per day (\$)', keyboardType: TextInputType.number),
              _buildTextField(_descriptionController, 'Car Description', maxLines: 3),
              
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final updatedCar = Car(
                        id: widget.car.id,
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
                        imageUrl: _image?.path ?? widget.car.imageUrl,
                        ownerId: widget.car.ownerId,
                      );
                      
                      context.read<CarProvider>().updateCar(updatedCar);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Car updated successfully')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3D8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Update Ad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
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
