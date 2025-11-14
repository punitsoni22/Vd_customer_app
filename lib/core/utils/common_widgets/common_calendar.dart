import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vd_customer_app/core/theme/colors.dart';

class CustomCalendar extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<DateTime>? initiallySelectedDates;
  final ValueChanged<List<DateTime>>? onSelectionChanged;

  const CustomCalendar({
    super.key,
    this.startDate,
    this.endDate,
    this.initiallySelectedDates,
    this.onSelectionChanged,
  });

  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDay = DateTime.now();
  Set<DateTime> _selectedDates = {};

  @override
  void initState() {
    super.initState();
    if (widget.initiallySelectedDates != null) {
      _selectedDates = widget.initiallySelectedDates!
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet();
    }
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isWithinRange(DateTime day) {
    if (widget.startDate == null || widget.endDate == null) return false;
    final d = _normalize(day);
    final start = _normalize(widget.startDate!);
    final end = _normalize(widget.endDate!);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  @override
  Widget build(BuildContext context) {
    final primary = AllColors.olivegreenColor;

    if (widget.startDate == null || widget.endDate == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Text(
          "Please select the start and end date first",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      );
    }

    final firstDay = _normalize(widget.startDate!);
    final lastDay = _normalize(widget.endDate!);
    final initialFocused = _focusedDay.isBefore(firstDay) ? firstDay : _focusedDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Dates",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
        Column(
          children: [
            TableCalendar(
              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: initialFocused,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left_rounded,
                  color: primary,
                  size: 30.sp,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right_rounded,
                  color: primary,
                  size: 30.sp,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
                weekendStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                isTodayHighlighted: true,
                todayDecoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w700,
                ),
                selectedDecoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                defaultTextStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 14.sp,
                ),
                weekendTextStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 14.sp,
                ),
                disabledTextStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14.sp,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              selectedDayPredicate: (day) =>
                  _selectedDates.contains(_normalize(day)),
              enabledDayPredicate: (day) => _isWithinRange(day),
              onDaySelected: (selectedDay, focusedDay) {
                if (!_isWithinRange(selectedDay)) return;
                setState(() {
                  final d = _normalize(selectedDay);
                  if (_selectedDates.contains(d)) {
                    _selectedDates.remove(d);
                  } else {
                    _selectedDates.add(d);
                  }
                  _focusedDay = focusedDay;
                });
                if (widget.onSelectionChanged != null) {
                  final sortedDates = _selectedDates.toList()
                    ..sort((a, b) => a.compareTo(b));
                  widget.onSelectionChanged!(sortedDates);
                }
              },
            ),

            if (_selectedDates.isNotEmpty)
              _buildSelectedChips(primary),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedChips(Color primary) {
    final sortedDates = _selectedDates.toList()..sort((a, b) => a.compareTo(b));

    String format(DateTime d) {
      return "${d.day.toString().padLeft(2, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.year}";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Selected dates (${sortedDates.length}):",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 2,
          children: sortedDates.map((d) {
            return Chip(
              label: Text(
                format(d),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: primary,
                ),
              ),
              backgroundColor: primary.withValues(alpha: 0.08),
              side: BorderSide(
                color: primary.withValues(alpha: 0.3),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.w),
            );
          }).toList(),
        ),
        SizedBox(height: 2.h,),
      ],
    );
  }
}
