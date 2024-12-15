// For handling byte data
import 'package:flutter/foundation.dart'; // For kIsWeb detection
import 'package:image_picker/image_picker.dart'; // Cross-platform Image Picker

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the gallery
  Future<Uint8List?> pickImage() async {
    try {
      // Web-specific implementation
      if (kIsWeb) {
        final XFile? image =
            await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          return await image.readAsBytes(); // Returns image as bytes
        }
      } else {
        // Mobile-specific implementation
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 512, // Resize to max width
          maxHeight: 512, // Resize to max height
          imageQuality: 75, // Compress image quality
        );
        if (image != null) {
          return await image.readAsBytes(); // Returns image as bytes
        }
      }
      return null; // No image selected
    } catch (e) {
      debugPrint('Error picking image: $e'); // Log the error
      return null;
    }
  }

  /// Takes a photo using the camera
  Future<Uint8List?> takePhoto() async {
    try {
      // Web-specific implementation (not supported)
      if (kIsWeb) {
        debugPrint('Camera is not supported on the web.'); // Log the message
        return null;
      } else {
        // Mobile-specific implementation
        final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 512, // Resize to max width
          maxHeight: 512, // Resize to max height
          imageQuality: 75, // Compress image quality
        );
        if (photo != null) {
          return await photo.readAsBytes(); // Returns photo as bytes
        }
      }
      return null; // No photo taken
    } catch (e) {
      debugPrint('Error taking photo: $e'); // Log the error
      return null;
    }
  }
}
