// lib/services/local_car_service.dart

import 'dart:async';
import '../models/car_model.dart';

class LocalCarService {
  static final LocalCarService _instance = LocalCarService._internal();
  factory LocalCarService() => _instance;
  LocalCarService._internal();

  final List<CarModel> _cars = [];
  final StreamController<List<CarModel>> _carStreamController = StreamController<List<CarModel>>.broadcast();

  Stream<List<CarModel>> getAllCars() {
    // Use a multi-stream or delayed add to ensure the listener gets the current data
    Timer.run(() => _carStreamController.add(List.from(_cars)));
    return _carStreamController.stream;
  }

  Stream<List<CarModel>> getUserCars(String userId) {
    Timer.run(() => _carStreamController.add(List.from(_cars)));
    return _carStreamController.stream.map(
          (cars) => cars.where((car) => car.ownerId == userId).toList(),
    );
  }

  Future<void> addCar(CarModel car) async {
    _cars.insert(0, car);
    _carStreamController.add(List.from(_cars));
  }

  Future<void> deleteCar(String carId) async {
    _cars.removeWhere((car) => car.id == carId);
    _carStreamController.add(List.from(_cars));
  }
}
