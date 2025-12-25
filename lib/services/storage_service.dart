// lib/services/storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload multiple car images
  Future<List<String>> uploadCarImages(
      List<File> imageFiles,
      String userId,
      ) async {
    List<String> downloadUrls = [];

    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'car_${userId}_${timestamp}_$i.jpg';
        final ref = _storage.ref().child('car_images/$userId/$fileName');

        // Upload file
        final uploadTask = await ref.putFile(imageFiles[i]);

        // Get download URL
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      return downloadUrls;
    } catch (e) {
      print('Error uploading images: $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  // Upload single profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final fileName = 'profile_$userId.jpg';
      final ref = _storage.ref().child('profile_images/$fileName');

      // Upload file
      final uploadTask = await ref.putFile(imageFile);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Delete image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Delete multiple images
  Future<void> deleteImages(List<String> imageUrls) async {
    for (String url in imageUrls) {
      await deleteImage(url);
    }
  }
}