import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/data/models/food_log.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/widgets/food_edit_sheet.dart';
import 'package:intl/intl.dart';

class FoodHistoryList extends StatefulWidget {
  const FoodHistoryList({super.key});

  @override
  State<FoodHistoryList> createState() => _FoodHistoryListState();
}

class _FoodHistoryListState extends State<FoodHistoryList> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last 7 Days of Eats',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Theme.of(context).disabledColor,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            StreamBuilder<List<FoodLog>>(
              stream: DatabaseService().watchRecentFoodLogs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final logs = snapshot.data ?? [];
                
                if (logs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No meals logged recently',
                        style: GoogleFonts.inter(color: Theme.of(context).disabledColor),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => FoodEditSheet(initialLog: log),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: food name + timestamp
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.foodName,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('EEE, h:mm a').format(log.timestamp),
                                    style: GoogleFonts.inter(
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Right: calories + macros + edit icon
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${log.calories} kcal',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'P: ${log.macros.protein?.toInt() ?? 0} | C: ${log.macros.carbs?.toInt() ?? 0} | F: ${log.macros.fat?.toInt() ?? 0}',
                                      style: GoogleFonts.inter(
                                        color: Theme.of(context).disabledColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.edit_outlined, size: 14, color: Theme.of(context).disabledColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
