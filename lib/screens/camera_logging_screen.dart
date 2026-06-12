import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/services/food_sourcing_service.dart';
import 'package:calorize/widgets/food_edit_sheet.dart';
import 'package:calorize/widgets/analyze_view.dart';

class CameraLoggingScreen extends StatefulWidget {
  final bool initialBarcodeMode;
  const CameraLoggingScreen({super.key, this.initialBarcodeMode = true});

  @override
  State<CameraLoggingScreen> createState() => _CameraLoggingScreenState();
}

class _CameraLoggingScreenState extends State<CameraLoggingScreen> {
  // Barcode Scanner
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.all],
    returnImage: false,
  );

  bool _isFlashOn = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (!widget.initialBarcodeMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _captureAndAnalyze(fromGallery: false);
      });
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _scannerController.toggleTorch();
    });
  }

  Future<void> _onBarcodeDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    try {
      final log = await FoodSourcingService().getProductByBarcode(code);
      if (mounted && log != null) {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FoodEditSheet(initialLog: log),
        );
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product not found')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _captureAndAnalyze({required bool fromGallery}) async {
    try {
      File? imageFile;

      if (fromGallery) {
        final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (picked != null) imageFile = File(picked.path);
      } else {
        final picked = await ImagePicker().pickImage(source: ImageSource.camera);
        if (picked != null) imageFile = File(picked.path);
      }

      if (imageFile != null && mounted) {
        final file = imageFile;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AnalyzeView(
            imageFile: file,
            onCancel: () {
              if (mounted) Navigator.pop(ctx);
              // In deep-link mode, pop the screen as well
              if (!widget.initialBarcodeMode && mounted) {
                Navigator.pop(context);
              }
            },
            onSuccess: (log) {
              if (mounted) {
                Navigator.pop(ctx); // close AnalyzeView
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => FoodEditSheet(initialLog: log),
                ).then((_) {
                  // After edit sheet closes, pop camera screen in deep-link mode
                  if (!widget.initialBarcodeMode && mounted) {
                    Navigator.pop(context);
                  }
                });
              }
            },
            onAnalyze: (contextText, onStatusChanged) async {
              return await FoodSourcingService().analyzeImage(
                file,
                contextText,
                onStatusChanged: onStatusChanged,
              );
            },
          ),
        );
      } else {
        // User cancelled image selection/capture, pop the screen in deep-link mode
        if (mounted && !widget.initialBarcodeMode) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        if (!widget.initialBarcodeMode) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Barcode Scanner Layer
          MobileScanner(
            controller: _scannerController,
            onDetect: _onBarcodeDetect,
            overlayBuilder: (context, constraints) {
              return Stack(
                children: [
                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.black54,
                      BlendMode.srcOut,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            backgroundBlendMode: BlendMode.dstOut,
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 300,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 300,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Top Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Controls / Status
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
              padding: const EdgeInsets.only(bottom: 32, top: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      'Point at a barcode',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Gallery Option
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: Colors.white, size: 32),
                    onPressed: () => _captureAndAnalyze(fromGallery: true),
                  ),
                ],
              ),
            ),
          ),
          
          // Processing Indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}