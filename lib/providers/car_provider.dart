// ============= lib/providers/car_provider.dart =============
import 'package:flutter/foundation.dart';
import '../models/car.dart';
import '../database/db_helper.dart';

class CarProvider with ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  List<Car> _cars = [];

  CarProvider() {
    _loadCars();
  }

  List<Car> get cars => _cars;
  List<Car> get myAds => _cars.where((car) => car.ownerId == '1').toList();
  List<Car> get favoriteCars => _cars.where((car) => car.isFavorite).toList();

  Future<void> _loadCars() async {
    final carMaps = await _dbHelper.getCars();
    _cars = carMaps.map((map) => Car.fromMap(map)).toList();
    
    // Add dummy data if empty for first run
    if (_cars.isEmpty) {
      await _addDummyData();
    }
    notifyListeners();
  }

  Future<void> _addDummyData() async {
    final dummyCars = [
      Car(
        id: '1',
        model: 'Civic',
        brand: 'Honda',
        year: '2019',
        pricePerDay: 45.0,
        imageUrl: 'https://via.placeholder.com/300x200',
        ownerId: '1', 
        type: 'Sedan',
        pickupLocation: 'New York',
        description: 'A comfortable and fuel-efficient sedan.',
      ),
      Car(
        id: '2',
        model: 'Yaris',
        brand: 'Toyota',
        year: '2020',
        pricePerDay: 40.0,
        imageUrl: 'https://via.placeholder.com/300x200',
        ownerId: '1', 
        type: 'Sedan',
        pickupLocation: 'Los Angeles',
        description: 'Reliable and easy to drive.',
      ),
    ];
    for (var car in dummyCars) {
      await _dbHelper.insertCar(car.toMap());
    }
    final carMaps = await _dbHelper.getCars();
    _cars = carMaps.map((map) => Car.fromMap(map)).toList();
  }

  List<Car> getFilteredCars(String category, String query) {
    List<Car> filtered = _cars;
    
    if (category != 'All') {
      filtered = filtered.where((car) => car.type.toLowerCase() == category.toLowerCase()).toList();
    }
    
    if (query.isNotEmpty) {
      filtered = filtered.where((car) {
        final title = '${car.brand} ${car.model}'.toLowerCase();
        return title.contains(query.toLowerCase());
      }).toList();
    }
    
    return filtered;
  }

  Future<void> addCar(Car car) async {
    await _dbHelper.insertCar(car.toMap());
    _cars.add(car);
    notifyListeners();
  }

  Future<void> removeCar(String id) async {
    await _dbHelper.deleteCar(id);
    _cars.removeWhere((car) => car.id == id);
    notifyListeners();
  }

  Future<void> updateCar(Car updatedCar) async {
    await _dbHelper.updateCar(updatedCar.toMap());
    final index = _cars.indexWhere((car) => car.id == updatedCar.id);
    if (index != -1) {
      _cars[index] = updatedCar;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String id) async {
    final index = _cars.indexWhere((car) => car.id == id);
    if (index != -1) {
      _cars[index].isFavorite = !_cars[index].isFavorite;
      await _dbHelper.updateCar(_cars[index].toMap());
      notifyListeners();
    }
  }
}
