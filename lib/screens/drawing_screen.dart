import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:handwritten_digit_scanner/services/history_service.dart';
import 'package:signature/signature.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/digit_classifier.dart';
import '../utils/styles.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 12, // Thick stroke for better recognition
    penColor: Colors.white,
    exportBackgroundColor: Colors.black, // Important for MNIST
  );

  final DigitClassifier _classifier = DigitClassifier();
  String _prediction = "?";
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _classifier.loadModel();
  }

  Future<void> _classifyDrawing() async {
    if (_controller.isEmpty) return;
    setState(() => _isProcessing = true);

    try {
      final Uint8List? pngBytes = await _controller.toPngBytes();
      if (pngBytes != null) {
        int? result = await _classifier.classifyBytes(pngBytes);
        
        if (result != null) {
          setState(() {
            _prediction = result.toString();
          });

          // --- NEW: Save to History ---
          await HistoryService.addScan(
            result.toString(), 
            1.0, // Drawings are usually 100% clear
            "Drawing"
          );
          
          // Optional: Show a tiny confirmation snackbar
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Drawing saved to History"), duration: Duration(milliseconds: 800))
            );
          }
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _clearCanvas() {
    _controller.clear();
    setState(() => _prediction = "?");
  }

  @override
  void dispose() {
    _controller.dispose();
    _classifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Digital Slate", style: AppTextStyles.header.copyWith(fontSize: 22)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Prediction Display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Text("AI PREDICTION", style: TextStyle(letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                Text(
                  _prediction, 
                  style: GoogleFonts.inter(fontSize: 80, fontWeight: FontWeight.w900, color: AppColors.primary)
                ),
              ],
            ),
          ),

          // 2. The Canvas (Black Box)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 4),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.black, // MNIST expects black background
                  height: double.infinity,
                  width: double.infinity,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          const Text("Draw a single digit (0-9)", style: TextStyle(color: Colors.grey)),

          // 3. Controls
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Clear Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearCanvas,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Clear"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Analyze Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _classifyDrawing,
                    icon: _isProcessing 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome),
                    label: Text(_isProcessing ? "Thinking..." : "Recognize"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}