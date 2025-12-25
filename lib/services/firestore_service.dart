// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============ CAR OPERATIONS ============

  Future<String?> addCar(CarModel car) async {
    try {
      await _db.collection('cars').doc(car.id).set(car.toJson());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<CarModel>> getAllCars() {
    return _db
        .collection('cars')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CarModel.fromJson(doc.data()))
        .toList());
  }

  Stream<List<CarModel>> getUserCars(String userId) {
    return _db
        .collection('cars')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CarModel.fromJson(doc.data()))
        .toList());
  }

  Future<CarModel?> getCar(String carId) async {
    try {
      DocumentSnapshot doc = await _db.collection('cars').doc(carId).get();
      if (doc.exists) {
        return CarModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting car: $e');
      return null;
    }
  }

  Future<String?> updateCar(String carId, Map<String, dynamic> updates) async {
    try {
      await _db.collection('cars').doc(carId).update(updates);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateCarAvailability(String carId, bool isAvailable) async {
    try {
      await _db.collection('cars').doc(carId).update({
        'isAvailable': isAvailable,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteCar(String carId) async {
    try {
      await _db.collection('cars').doc(carId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ============ USER OPERATIONS ============

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<String?> createUserProfile(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toJson());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateUserProfile(
      String uid, Map<String, dynamic> updates) async {
    try {
      await _db.collection('users').doc(uid).update(updates);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ============ SEARCH & FILTER ============

  Future<List<CarModel>> searchCars(String query) async {
    try {
      final snapshot = await _db
          .collection('cars')
          .where('isAvailable', isEqualTo: true)
          .get();

      final cars = snapshot.docs
          .map((doc) => CarModel.fromJson(doc.data()))
          .where((car) =>
      car.brand.toLowerCase().contains(query.toLowerCase()) ||
          car.model.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return cars;
    } catch (e) {
      print('Error searching cars: $e');
      return [];
    }
  }

  Future<List<CarModel>> filterCarsByPrice(
      double minPrice, double maxPrice) async {
    try {
      final snapshot = await _db
          .collection('cars')
          .where('isAvailable', isEqualTo: true)
          .where('pricePerDay', isGreaterThanOrEqualTo: minPrice)
          .where('pricePerDay', isLessThanOrEqualTo: maxPrice)
          .get();

      return snapshot.docs
          .map((doc) => CarModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error filtering cars: $e');
      return [];
    }
  }
}