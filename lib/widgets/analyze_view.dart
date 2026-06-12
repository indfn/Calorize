import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/data/models/food_log.dart';

class AnalyzeView extends StatefulWidget {
  final File imageFile;
  final VoidCallback onCancel;
  final Function(FoodLog log) onSuccess;
  final Future<FoodLog?> Function(
    String context,
    void Function(String status) onStatusChanged,
  ) onAnalyze;

  const AnalyzeView({
    super.key,
    required this.imageFile,
    required this.onCancel,
    required this.onSuccess,
    required this.onAnalyze,
  });

  @override
  State<AnalyzeView> createState() => _AnalyzeViewState();
}

class _AnalyzeViewState extends State<AnalyzeView> {
  final TextEditingController _contextController = TextEditingController();
  bool _isAnalyzing = false;
  String _statusText = '';
  String? _errorText;

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  void _updateStatus(String status) {
    if (mounted) {
      setState(() {
        _statusText = status;
      });
    }
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _statusText = 'Preparing...';
      _errorText = null;
    });

    try {
      final log = await widget.onAnalyze(
        _contextController.text,
        _updateStatus,
      );

      if (log != null && mounted) {
        widget.onSuccess(log);
      } else if (mounted) {
        setState(() {
          _errorText = 'Analysis returned no result. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = e.toString();
        });
      }
    }
  }

  void _handleCancel() {
    if (_isAnalyzing) {
      widget.onCancel();
    } else {
      widget.onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Photo thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                widget.imageFile,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Context (editable or read-only)
            if (!_isAnalyzing)
              TextFormField(
                controller: _contextController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'e.g. Lunch at a cafe, homemade pasta with pesto',
                  hintStyle: GoogleFonts.inter(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                style: GoogleFonts.inter(
                  color: colorScheme.onSurface,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Context:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _contextController.text.isEmpty
                          ? 'No context provided'
                          : _contextController.text,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: _contextController.text.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Status / spinner
            if (_isAnalyzing && _errorText == null) ...[
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 12),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Error display
            if (_errorText != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _parseErrorMessage(_errorText!),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colorScheme.onErrorContainer,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _errorText != null
                      ? () {
                          setState(() {
                            _isAnalyzing = false;
                            _errorText = null;
                            _statusText = '';
                          });
                        }
                      : _handleCancel,
                  child: Text(
                    _errorText != null ? 'Back' : 'Cancel',
                    style: GoogleFonts.inter(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isAnalyzing)
                  FilledButton(
                    onPressed: _startAnalysis,
                    child: Text(
                      'Analyze',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (_errorText != null)
                  FilledButton(
                    onPressed: _startAnalysis,
                    child: Text(
                      'Try Again',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
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
    // Strip the "Exception: " prefix for cleaner display
    final cleaned = raw.replaceAll('Exception: ', '');
    if (cleaned.length > 120) {
      return 'An unexpected error occurred. Please try again.';
    }
    return cleaned;
  }
}
