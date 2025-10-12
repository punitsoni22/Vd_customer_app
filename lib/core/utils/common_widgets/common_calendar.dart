import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vd_customer_app/core/theme/colors.dart';


class CustomCalendar extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<DateTime>? initiallySelectedDates;
  final ValueChanged<List<DateTime>>? onSelectionChanged;
  const CustomCalendar({super.key, this.startDate, this.endDate, this.initiallySelectedDates, this.onSelectionChanged});

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
      _selectedDates = widget.initiallySelectedDates!.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    }
  }

  bool _isWithinRange(DateTime day) {
    if (widget.startDate == null || widget.endDate == null) return false;
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(widget.startDate!) && !d.isAfter(widget.endDate!);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startDate == null || widget.endDate == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Text(
          "Please select the start and end date first",
          style: TextStyle(
            color: AllColors.olivegreenColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Select Dates",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AllColors.olivegreenColor,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color.fromARGB(255, 184, 184, 184),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              TableCalendar(
                firstDay: widget.startDate!,
                lastDay: widget.endDate!,
                focusedDay: _focusedDay.isBefore(widget.startDate!) ? widget.startDate! : _focusedDay,
                selectedDayPredicate: (day) => _selectedDates.contains(DateTime(day.year, day.month, day.day)),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!_isWithinRange(selectedDay)) return;
                  setState(() {
                    final d = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                    if (_selectedDates.contains(d)) {
                      _selectedDates.remove(d);
                    } else {
                      _selectedDates.add(d);
                    }
                    _focusedDay = focusedDay;
                  });
                  if (widget.onSelectionChanged != null) {
                    widget.onSelectionChanged!(_selectedDates.toList()..sort((a, b) => a.compareTo(b)));
                  }
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left),
                  rightChevronIcon: Icon(Icons.chevron_right),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AllColors.iconColor,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.black),
                  defaultTextStyle: TextStyle(color: Colors.black87),
                  markerDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  weekendStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                enabledDayPredicate: (day) => _isWithinRange(day),
              ),
              if (_selectedDates.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ..._selectedDates
                          .toList()
                          .cast<DateTime>()
                          .map((d) => Chip(
                                label: Text("${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}"),
                                backgroundColor: Colors.teal.withOpacity(0.15),
                              ))
                          .toList()
                        ..sort((a, b) => (a.label as Text).data!.compareTo((b.label as Text).data!)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Optionally, you can keep this for legend if needed
  Widget _buildrow(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
