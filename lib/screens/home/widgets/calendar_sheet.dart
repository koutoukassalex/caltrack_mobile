import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/daily_log.dart';
import '../../../core/utils.dart';

class CalendarSheet extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, DailyLog> allLogs;
  final Function(DateTime) onSelectDate;

  const CalendarSheet({
    super.key,
    required this.selectedDate,
    required this.allLogs,
    required this.onSelectDate,
  });

  @override
  State<CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<CalendarSheet> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final firstWeekday = _month.weekday; // 1 = Mon, 7 = Sun
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _prevMonth,
              ),
              Text(
                DateFormat('MMMM yyyy').format(_month),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => SizedBox(
                      width: 32,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: (firstWeekday - 1) + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday - 1) {
                return const SizedBox();
              }
              final dayNumber = index - (firstWeekday - 2);
              final date = DateTime(_month.year, _month.month, dayNumber);
              final isToday = date == today;
              final isSelected = date.year == widget.selectedDate.year &&
                  date.month == widget.selectedDate.month &&
                  date.day == widget.selectedDate.day;
              final isFuture = date.isAfter(today);

              final dateKey = DateUtilsHelper.formatDateKey(date);
              final hasLog = widget.allLogs.containsKey(dateKey) &&
                  widget.allLogs[dateKey]!.foods.isNotEmpty;

              return InkWell(
                onTap: isFuture
                    ? null
                    : () {
                        widget.onSelectDate(date);
                        Navigator.pop(context);
                      },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isToday
                            ? theme.colorScheme.primary.withOpacity(0.15)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isToday || isSelected ? FontWeight.bold : null,
                          color: isSelected
                              ? Colors.white
                              : (isFuture
                                  ? theme.disabledColor
                                  : theme.colorScheme.onBackground),
                        ),
                      ),
                      if (hasLog)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
