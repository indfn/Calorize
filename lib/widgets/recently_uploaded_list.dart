import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/data/models/food_log.dart';
import 'package:calorize/widgets/food_edit_sheet.dart';

class RecentlyUploadedList extends StatefulWidget {
  const RecentlyUploadedList({super.key});

  @override
  State<RecentlyUploadedList> createState() => _RecentlyUploadedListState();
}

class _RecentlyUploadedListState extends State<RecentlyUploadedList> {
  List<FoodLog> _recentLogs = [];
  bool _isLoading = true;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadRecentLogs();
  }

  Future<void> _loadRecentLogs() async {
    final logs = await DatabaseService().getRecentFoodLogs();
    if (mounted) {
      setState(() {
        _recentLogs = logs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Collapsible Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                Text(
                  'Recently uploaded',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Theme.of(context).disabledColor,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        if (_isExpanded)
          if (_recentLogs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(Icons.no_food, size: 48, color: Theme.of(context).disabledColor),
                    const SizedBox(height: 8),
                    Text(
                      'No recent meals',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _recentLogs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final log = _recentLogs[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => FoodEditSheet(initialLog: log),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.restaurant_rounded,
                            size: 24,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Food Name
                        Expanded(
                          child: Text(
                            log.foodName,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Edit icon hint
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(Icons.edit_outlined, size: 16, color: Theme.of(context).disabledColor),
                        ),
                        // Calories
                        Text(
                          '${log.calories} cal',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }
}
