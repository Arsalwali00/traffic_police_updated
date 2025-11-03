import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class CnicScanner {
  Future<Map<String, dynamic>?> scanCnic(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image == null) {
        return null;
      }

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      textRecognizer.close();

      debugPrint("Raw Identity Card text: ${recognizedText.text}");

      String? name;
      String? cnicNumber;

      final lines = recognizedText.text.split('\n').map((line) => line.trim()).toList();

      final cnicRegex = RegExp(r'(\d{5}-?\d{7}-?\d{1}|\d{13})');

      for (var line in lines) {
        final match = cnicRegex.firstMatch(line);
        if (match != null) {
          cnicNumber = match.group(0)!.replaceAll('-', '');
          break;
        }
      }

      for (int i = 0; i < lines.length; i++) {
        final lowerLine = lines[i].toLowerCase();
        if (lowerLine.contains('name')) {
          if (i + 1 < lines.length && lines[i + 1].isNotEmpty && RegExp(r'^[A-Za-z\s]+$').hasMatch(lines[i + 1])) {
            name = lines[i + 1].trim();
          } else if (lowerLine.startsWith('name') && lines[i].length > 5) {
            name = lines[i].substring(lines[i].indexOf(':') + 1).trim();
            if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(name)) {
              name = null;
            }
          }
          break;
        }
      }

      if (name == null) {
        for (var line in lines) {
          if (RegExp(r'^[A-Za-z\s]{3,}$').hasMatch(line) && !line.toLowerCase().contains('pakistan')) {
            name = line.trim();
            break;
          }
        }
      }

      if (name != null && name.isNotEmpty && cnicNumber != null && RegExp(r'^\d{13}$').hasMatch(cnicNumber)) {
        return {
          'name': name,
          'cnic_number': cnicNumber,
        };
      } else {
        debugPrint("Failed to extract valid name or Identity Number. Name: $name, Identity Number: $cnicNumber");
        throw Exception('Unable to extract valid Name or Identity Number from Identity Card');
      }
    } catch (e) {
      debugPrint("Error processing Identity Card image: $e");
      throw Exception('Error processing Identity Card image: $e');
    }
  }
}