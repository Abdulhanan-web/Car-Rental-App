// ============= lib/models/car.dart =============
class Car {
  final String id;
  final String model;
  final String brand;
  final double pricePerDay;
  final String imageUrl;
  final String ownerId;
  final String type;
  final String pickupLocation;
  final String description;
  final String year;
  final String mileage;
  final String fuelType;
  final String transmission;
  final String registeredIn;
  final String exteriorColor;
  final String assembly;
  final String engineCapacity;
  bool isFavorite;

  Car({
    required this.id,
    required this.model,
    required this.brand,
    required this.pricePerDay,
    required this.imageUrl,
    required this.ownerId,
    required this.type,
    required this.pickupLocation,
    required this.description,
    this.year = '2021',
    this.mileage = '10,000 km',
    this.fuelType = 'Petrol',
    this.transmission = 'Automatic',
    this.registeredIn = 'Unknown',
    this.exteriorColor = 'Unknown',
    this.assembly = 'Local',
    this.engineCapacity = '1500cc',
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'pricePerDay': pricePerDay,
      'type': type,
      'pickupLocation': pickupLocation,
      'description': description,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'mileage': mileage,
      'fuelType': fuelType,
      'transmission': transmission,
      'registeredIn': registeredIn,
      'exteriorColor': exteriorColor,
      'assembly': assembly,
      'engineCapacity': engineCapacity,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      brand: map['brand'],
      model: map['model'],
      year: map['year'],
      pricePerDay: map['pricePerDay'],
      type: map['type'],
      pickupLocation: map['pickupLocation'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      ownerId: map['ownerId'],
      mileage: map['mileage'],
      fuelType: map['fuelType'],
      transmission: map['transmission'],
      registeredIn: map['registeredIn'],
      exteriorColor: map['exteriorColor'],
      assembly: map['assembly'],
      engineCapacity: map['engineCapacity'],
      isFavorite: map['isFavorite'] == 1,
    );
  }
}
