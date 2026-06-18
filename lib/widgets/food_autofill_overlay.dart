import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/data/models/food_log.dart';

class FoodAutofillOverlay extends StatelessWidget {
  final List<FoodLog> suggestions;
  final ValueChanged<FoodLog> onSelected;

  const FoodAutofillOverlay({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final log = suggestions[index];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index > 0)
                  Divider(height: 1, color: theme.dividerColor.withAlpha(60)),
                InkWell(
                  onTap: () => onSelected(log),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                          log.foodName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        if (log.brandName != null && log.brandName!.isNotEmpty)
                          Text(
                            log.brandName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'P: ${log.macros.protein?.toStringAsFixed(1) ?? '0.0'}g  \u2022  C: ${log.macros.carbs?.toStringAsFixed(1) ?? '0.0'}g  \u2022  F: ${log.macros.fat?.toStringAsFixed(1) ?? '0.0'}g',
                          style: GoogleFonts.inter(fontSize: 11, color: theme.textTheme.bodySmall?.color?.withAlpha(170)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        ),
      ),
    );
  }
}
