import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddOptionsSheet extends StatelessWidget {
  final VoidCallback onManualEntry;
  final VoidCallback onBarcodeScan;
  final VoidCallback onAiAnalysis;

  const AddOptionsSheet({
    super.key,
    required this.onManualEntry,
    required this.onBarcodeScan,
    required this.onAiAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Manual Entry'),
              onTap: onManualEntry,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBarcodeScan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text('Barcode', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onAiAnalysis,
                  icon: const Icon(Icons.camera_alt),
                  label: Text('Analyze Food', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
