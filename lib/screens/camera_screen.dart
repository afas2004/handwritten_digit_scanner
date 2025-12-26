import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:handwritten_digit_scanner/screens/settings_screen.dart';
import '../main.dart'; // to access 'cameras'
import '../services/digit_classifier.dart';
import '../utils/styles.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/history_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  final DigitClassifier _classifier = DigitClassifier();
  
  bool _isProcessing = false;
  String _currentSequence = ""; // Stores the sequence "012..."
  String? _lastPrediction; // Stores last single digit
  bool _isSequenceMode = false; // Toggle state

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _classifier.loadModel();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  // The Core Logic: Capture -> Crop -> Predict
  Future<void> _captureAndPredict() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final image = await _controller!.takePicture();
      File imageFile = File(image.path);

      // Run Inference
      int? digit = await _classifier.classifyFile(imageFile);

      setState(() {
        _lastPrediction = digit?.toString() ?? "?";
        if (_isSequenceMode && digit != null) {
          // In sequence mode, we wait for user to hit 'Append' usually, 
          // but for this demo, let's just show it as the 'Pending' digit
        } else if (!_isSequenceMode && digit != null) {
          _currentSequence = digit.toString(); // Reset sequence in single mode
        }
      });
      
      _showResultDialog(digit);

    } catch (e) {
      print(e);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showResultDialog(int? digit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Prediction", style: AppTextStyles.body),
            Text(digit?.toString() ?? "Err", style: GoogleFonts.inter(fontSize: 72, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_isSequenceMode)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _currentSequence += digit.toString());
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Append"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Retry"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _classifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Preview
          Center(child: CameraPreview(_controller!)),

          // 2. Overlay (Darkened Background with Cutout)
          // Simplified overlay for readability
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcOut),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. UI Controls
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                        child: Text(_isSequenceMode ? "Sequence Mode" : "Single Mode", style: const TextStyle(color: Colors.white)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          // Navigate to the Settings Screen we just created
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingsScreen()));
                        },
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Result Display (Current String)
                if (_currentSequence.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                    child: Text(
                      _currentSequence,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
                    ),
                  ),
                
                const SizedBox(height: 20),

                // Bottom Control Panel
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      // Mode Switcher
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Single"),
                          Switch(
                            value: _isSequenceMode,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() {
                              _isSequenceMode = val;
                              if (!val) _currentSequence = "";
                            }),
                          ),
                          const Text("Sequence"),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Shutter Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.backspace, color: Colors.grey),
                            onPressed: () => setState(() => _currentSequence = ""),
                          ),
                          GestureDetector(
                            onTap: _captureAndPredict,
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 4),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: _isProcessing 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Icon(Icons.camera, color: Colors.white, size: 32),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.green, size: 32),
                            onPressed: () async {
                              if (_currentSequence.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("No digits scanned yet!"),
                                      backgroundColor: Colors.red),
                                );
                                return;
                              }

                              // --- REAL SAVE LOGIC ---
                              await HistoryService.addScan(
                                  _currentSequence, // The number (e.g., "7" or "012")
                                  0.99, // (Optional: You could track average confidence here)
                                  "Camera");

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Saved '$_currentSequence' to History"),
                                      backgroundColor: AppColors.primary),
                                );
                                Navigator.pop(context); // Go back to home
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}