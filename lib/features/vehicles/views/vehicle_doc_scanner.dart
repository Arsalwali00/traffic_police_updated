import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

/// High-accuracy vehicle document scanner for Pakistani RC cards
/// Handles broken text, noise, split lines, and common OCR errors
class VehicleDocScanner {
  /// Scans vehicle document and returns:
  /// {
  ///   'registration_number': 'ABC123',
  ///   'chassis_number'     : 'ABC12345678901234'
  /// }
  Future<Map<String, dynamic>?> scanVehicleDoc(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
        return null;
      }

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final String fullText = recognizedText.text;
      debugPrint("=== RAW OCR TEXT ===\n$fullText\n=====================");

      final lines = fullText
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      String? registrationNumber = _extractRegistrationNumber(lines);
      String? chassisNumber = _extractChassisNumber(lines);

      // Final validation
      final regValid = registrationNumber != null &&
          RegExp(r'^[A-Z]{2,3}\d{1,4}$').hasMatch(registrationNumber);

      final chassisValid = chassisNumber != null &&
          RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(chassisNumber);

      if (regValid && chassisValid) {
        debugPrint("SUCCESS → Reg: $registrationNumber, Chassis: $chassisNumber");
        return {
          'registration_number': registrationNumber,
          'chassis_number': chassisNumber,
        };
      } else {
        final error = 'Invalid data → Reg: $registrationNumber (valid: $regValid), '
            'Chassis: $chassisNumber (valid: $chassisValid)';
        debugPrint(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not read registration or chassis number clearly.')),
        );
        throw Exception(error);
      }
    } catch (e) {
      debugPrint("Scan error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e')),
      );
      rethrow;
    }
  }

  // ========================================================================
  // 1. REGISTRATION NUMBER (e.g., LHR123, ABC-456 → ABC456)
  // ========================================================================
  String? _extractRegistrationNumber(List<String> lines) {
    final regRegex = RegExp(r'\b([A-Z]{2,3}[ -]?\d{1,4})\b', caseSensitive: false);

    // Try direct regex match
    for (final line in lines) {
      final match = regRegex.firstMatch(line);
      if (match != null) {
        return match
            .group(0)!
            .replaceAll(RegExp(r'[- ]'), '')
            .toUpperCase();
      }
    }

    // Fallback: near keywords
    return _findNearKeyword(lines, ['reg', 'registration', 'no.', 'number', 'regd']);
  }

  // ========================================================================
  // 2. CHASSIS NUMBER / VIN (17 chars, A-HJ-NPR-Z0-9)
  // ========================================================================
  String? _extractChassisNumber(List<String> lines) {
    final keywords = [
      'chassis', 'vin', 'frame', 'chasis', 'chasi', 'chas1s',
      'chassis no', 'vin no', 'frame no'
    ];

    int keywordIndex = -1;
    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase().replaceAll('.', '');
      if (keywords.any(lower.contains)) {
        keywordIndex = i;
        break;
      }
    }

    if (keywordIndex == -1) return null;

    final candidates = <String>[];

    // Same line after colon
    final colonLine = lines[keywordIndex];
    final colonIdx = colonLine.indexOf(':');
    if (colonIdx != -1) {
      final after = colonLine
          .substring(colonIdx + 1)
          .replaceAll(RegExp(r'[^A-Z0-9]'), '')
          .toUpperCase();
      if (after.length >= 10) candidates.add(after);
    }

    // Next 1–3 lines (OCR often breaks VIN)
    for (int i = 1; i <= 3 && keywordIndex + i < lines.length; i++) {
      final next = lines[keywordIndex + i]
          .replaceAll(RegExp(r'[^A-Z0-9]'), '')
          .toUpperCase();
      if (next.length >= 8) candidates.add(next);
    }

    // Combine all candidates
    final combined = candidates.join('');

    // Exact 17-digit VIN
    final exactMatch = RegExp(r'[A-HJ-NPR-Z0-9]{17}').firstMatch(combined);
    if (exactMatch != null) return exactMatch.group(0);

    // Find longest valid segment
    final segments = combined
        .split(RegExp(r'[^A-HJ-NPR-Z0-9]+'))
        .where((s) => s.length >= 15)
        .toList();

    for (final seg in segments) {
      if (seg.length == 17 && _isValidVin(seg)) return seg;
      if (seg.length > 17) {
        final sub = RegExp(r'[A-HJ-NPR-Z0-9]{17}').firstMatch(seg);
        if (sub != null) return sub.group(0);
      }
    }

    return null;
  }

  bool _isValidVin(String vin) {
    return RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(vin);
  }

  // ========================================================================
  // Helper: Extract value after keyword (e.g., "Reg No: ABC123")
  // ========================================================================
  String? _findNearKeyword(List<String> lines, List<String> keywords) {
    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      if (keywords.any(lower.contains)) {
        // Next line
        if (i + 1 < lines.length) {
          final candidate = lines[i + 1].replaceAll(RegExp(r'[^A-Z0-9]'), '');
          if (candidate.length >= 3) return candidate.toUpperCase();
        }
        // Same line after colon
        final colonIdx = lines[i].indexOf(':');
        if (colonIdx != -1) {
          final candidate = lines[i]
              .substring(colonIdx + 1)
              .replaceAll(RegExp(r'[^A-Z0-9]'), '');
          if (candidate.length >= 3) return candidate.toUpperCase();
        }
      }
    }
    return null;
  }
}