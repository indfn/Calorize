import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DateStrip extends StatefulWidget {
  final Map<DateTime, bool>? successStatus;
  
  const DateStrip({
    super.key, 
    this.successStatus,
  });

  @override
  State<DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<DateStrip> {
  late List<DateTime> _currentWeek;

  @override
  void initState() {
    super.initState();
    _currentWeek = _generateCurrentWeek();
  }

  List<DateTime> _generateCurrentWeek() {
    final now = DateTime.now();
    // Find the most recent Monday
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _currentWeek.map((date) {
          final dateOnly = DateTime(date.year, date.month, date.day);
          final isToday = _isSameDay(date, now);
          final isFuture = dateOnly.isAfter(today);
          
          // Check success status
          // We need to match keys in the map which are DateTimes (midnight)
          final isSuccess = widget.successStatus?[dateOnly] ?? false;
          
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isToday ? Theme.of(context).cardTheme.color : Colors.transparent,
                borderRadius: BorderRadius.circular(28), // Squircle-ish
                boxShadow: isToday
                    ? [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(date), // Mon, Tue...
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isToday 
                            ? Theme.of(context).textTheme.bodyLarge?.color 
                            : isFuture ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSuccess ? Colors.green : Colors.transparent,
                        border: isToday && !isSuccess
                          ? Border.all(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black, width: 1.5)
                          : null,
                      ),
                      child: isSuccess 
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            date.day.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isToday 
                                  ? Theme.of(context).textTheme.bodyLarge?.color 
                                  : isFuture ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ).animate().slideY(
              begin: -0.2, 
              duration: 400.ms, 
              curve: Curves.easeOutQuad,
              delay: (50 * _currentWeek.indexOf(date)).ms,
            ).fadeIn(duration: 400.ms),
          );
        }).toList(),
      ),
    );
  }
}
