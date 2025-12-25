// lib/models/car_model.dart

class CarModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String brand;
  final String model;
  final int year;
  final double pricePerDay;
  final String description;
  final List<String> imageUrls;
  final String location;
  final bool isAvailable;
  final DateTime createdAt;

  CarModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.brand,
    required this.model,
    required this.year,
    required this.pricePerDay,
    required this.description,
    required this.imageUrls,
    required this.location,
    this.isAvailable = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerId': ownerId,
    'ownerName': ownerName,
    'brand': brand,
    'model': model,
    'year': year,
    'pricePerDay': pricePerDay,
    'description': description,
    'imageUrls': imageUrls,
    'location': location,
    'isAvailable': isAvailable,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CarModel.fromJson(Map<String, dynamic> json) => CarModel(
    id: json['id'],
    ownerId: json['ownerId'],
    ownerName: json['ownerName'],
    brand: json['brand'],
    model: json['model'],
    year: json['year'],
    pricePerDay: (json['pricePerDay'] as num).toDouble(),
    description: json['description'],
    imageUrls: List<String>.from(json['imageUrls']),
    location: json['location'],
    isAvailable: json['isAvailable'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  CarModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? brand,
    String? model,
    int? year,
    double? pricePerDay,
    String? description,
    List<String>? imageUrls,
    String? location,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return CarModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}