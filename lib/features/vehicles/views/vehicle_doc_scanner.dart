import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Simplified GB Number Plate Scanner
/// Accepts any combination of letters and numbers
class GBNumberPlateScanner {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Scans number plate from camera
  Future<String?> scanNumberPlate(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 100,
      );

      if (image == null) return null;
      return await _processImage(image.path, context);
    } catch (e) {
      debugPrint("Scan error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan failed: $e')),
        );
      }
      return null;
    }
  }

  /// Scans from gallery
  Future<String?> scanFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null) return null;
      return await _processImage(image.path, context);
    } catch (e) {
      debugPrint("Gallery scan error: $e");
      return null;
    }
  }

  /// Process image and extract plate number
  Future<String?> _processImage(String imagePath, BuildContext context) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      final String fullText = recognizedText.text;
      debugPrint("=== RAW OCR TEXT ===\n$fullText\n====================");

      // Get all text and clean it
      final cleaned = fullText
          .toUpperCase()
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      // Extract plate number
      String? plateNumber = _extractPlateNumber(cleaned);

      if (plateNumber != null && plateNumber.isNotEmpty) {
        // Remove all dashes from the plate number
        plateNumber = plateNumber.replaceAll('-', '');
        debugPrint("✓ Found plate: $plateNumber");
        return plateNumber;
      }

      debugPrint("✗ No valid plate found");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not detect number plate. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return null;
    } catch (e) {
      debugPrint("Process error: $e");
      rethrow;
    }
  }

  /// Extract plate number - very simple approach
  String? _extractPlateNumber(String text) {
    // Remove common words
    final ignore = ['NCP', 'GB', 'PAKISTAN', 'PAK', 'GOVT', 'GOVERNMENT', 'REGISTRATION'];
    String cleaned = text;
    for (var word in ignore) {
      cleaned = cleaned.replaceAll(word, '');
    }

    // Find any pattern with letters followed by numbers
    // Examples: ABC123, ABC-123, ABC 123, ABCD01234, etc.
    final patterns = [
      // Standard format: 2-4 letters, optional separator, 1-2 digits, optional separator, 1-4 digits
      RegExp(r'\b([A-Z]{2,4})[\s\-]*(\d{1,2})[\s\-]*(\d{1,4})\b'),
      // Simple format: 2-4 letters followed by 2-6 digits
      RegExp(r'\b([A-Z]{2,4})[\s\-]*(\d{2,6})\b'),
      // Any letters followed by any numbers
      RegExp(r'\b([A-Z]{2,5})[\s\-]*(\d{1,7})\b'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(cleaned);
      if (match != null) {
        // Reconstruct with standard format
        if (match.groupCount == 3) {
          // Format: ABC01123
          return '${match.group(1)}${match.group(2)}${match.group(3)}';
        } else if (match.groupCount == 2) {
          final letters = match.group(1)!;
          final numbers = match.group(2)!;

          // Return as: ABC01123
          if (numbers.length >= 3) {
            final split = numbers.length >= 4 ? 2 : 1;
            final part1 = numbers.substring(0, split).padLeft(2, '0');
            final part2 = numbers.substring(split);
            return '$letters$part1$part2';
          } else {
            return '$letters${numbers.padLeft(2, '0')}';
          }
        }
      }
    }

    // Last resort: just find any alphanumeric sequence
    final alphanumeric = cleaned.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (alphanumeric.length >= 4 && RegExp(r'[A-Z]').hasMatch(alphanumeric) && RegExp(r'[0-9]').hasMatch(alphanumeric)) {
      // Has both letters and numbers
      final letters = RegExp(r'^[A-Z]+').firstMatch(alphanumeric)?.group(0) ?? '';
      final numbers = alphanumeric.substring(letters.length);

      if (letters.length >= 2 && numbers.length >= 2) {
        return _formatPlate(letters, numbers);
      }
    }

    return null;
  }

  /// Format plate nicely
  String _formatPlate(String letters, String numbers) {
    if (numbers.length >= 3) {
      final split = numbers.length >= 4 ? 2 : 1;
      final part1 = numbers.substring(0, split).padLeft(2, '0');
      final part2 = numbers.substring(split);
      return '$letters$part1$part2';
    } else {
      return '$letters${numbers.padLeft(2, '0')}';
    }
  }

  /// Cleanup method
  void dispose() {
    _textRecognizer.close();
  }
}