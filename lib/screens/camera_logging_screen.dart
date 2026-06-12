import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/screens/settings/ai_providers_screen.dart';
import 'package:calorize/services/food_sourcing_service.dart';
import 'package:calorize/widgets/food_edit_sheet.dart';

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
    String userContextText = '';
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
        // Show Context Dialog
        final contextController = TextEditingController();
        try {
          final shouldAnalyze = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add Context'),
              content: TextField(
                controller: contextController,
                decoration: const InputDecoration(
                  hintText: 'e.g. "Lunch at a cafe", "Homemade pasta"',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Analyze'),
                ),
              ],
            ),
          );

          if (shouldAnalyze == true && mounted) {
            userContextText = contextController.text;
            setState(() => _isProcessing = true);
            final log = await FoodSourcingService().analyzeImage(imageFile, userContextText);
            if (mounted) {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FoodEditSheet(initialLog: log),
              );
              if (mounted) Navigator.pop(context);
            }
          } else {
            // User cancelled context dialog, pop the screen as well since this is deep-link mode
            if (mounted && !widget.initialBarcodeMode) {
              Navigator.pop(context);
            }
          }
        } finally {
          contextController.dispose();
        }
      } else {
        // User cancelled image selection/capture, pop the screen since this is deep-link mode
        if (mounted && !widget.initialBarcodeMode) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString();
        final userFriendlyMsg = _parseErrorMessage(errorMsg);

        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Analysis Failed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userFriendlyMsg),
                if (userContextText.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Your context:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(userContextText, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: userContextText));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Context copied!')));
                },
                child: const Text('Copy Context'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Dismiss'),
              ),
              if (errorMsg.contains('No AI providers') || errorMsg.contains('API key'))
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AiProvidersScreen()));
                  },
                  child: const Text('Configure AI'),
                ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _captureAndAnalyze(fromGallery: fromGallery);
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        );

        if (mounted && !widget.initialBarcodeMode) {
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _parseErrorMessage(String raw) {
    if (raw.contains('No AI providers')) {
      return 'No AI providers configured. Add one in Settings.';
    }
    if (raw.contains('API error: 401') || raw.contains('API error: 403')) {
      return 'Authentication failed. Check your API key.';
    }
    if (raw.contains('API error: 429')) {
      return 'Rate limit exceeded. Please try again later.';
    }
    if (raw.contains('API error: 5')) {
      return 'The AI provider server returned an error. Try again.';
    }
    if (raw.contains('Connection refused') || raw.contains('SocketException')) {
      return 'Could not connect to the AI provider. Check your internet connection.';
    }
    return 'An unexpected error occurred. Please try again.';
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
              color: Colors.black.withOpacity(0.6),
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