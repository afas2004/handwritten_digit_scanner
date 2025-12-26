import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class DigitClassifier {
  
  // 1. Load Model
  Future<void> loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/mnist.tflite",
        labels: "assets/labels.txt",
        numThreads: 1, // Defaults to 1
        isAsset: true,
        useGpuDelegate: false,
      );
      print("Model loaded: $res");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // 2. Classify a File (Camera)
  Future<int?> classifyFile(File imageFile) async {
    try {
      // Tflite.runModelOnImage automatically handles resizing and normalization!
      var recognitions = await Tflite.runModelOnImage(
        path: imageFile.path,
        numResults: 1,    // We only want the best guess
        threshold: 0.1,   // Confidence threshold
        imageMean: 0.0,   // MNIST defaults (0-1 normalization is usually handled by these params)
        imageStd: 255.0,  // Divide pixel values by 255
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        // recognitions is a list like [{label: "7", confidence: 0.99}]
        return int.parse(recognitions[0]['label']);
      }
    } catch (e) {
      print("Error classifying file: $e");
    }
    return null;
  }

  // 3. Classify Bytes (Drawing)
  Future<int?> classifyBytes(Uint8List imageBytes) async {
    try {
      // For this library, it's safest to save the bytes to a temp file first
      final tempDir = await getTemporaryDirectory();
      File tempFile = await File('${tempDir.path}/temp_drawing.png').create();
      await tempFile.writeAsBytes(imageBytes);

      return await classifyFile(tempFile);
    } catch (e) {
      print("Error classifying bytes: $e");
      return null;
    }
  }
  
  void close() {
    Tflite.close();
  }
}