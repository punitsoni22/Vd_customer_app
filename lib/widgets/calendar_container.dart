import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vd_customer_app/theme/colors.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({super.key});
  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Start/End Date",
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
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
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
                    color: AllColors.iconColor,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.black),
                  defaultTextStyle: TextStyle(color: Colors.black87),
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
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildrow(Colors.orange, "Delayed"),
                    _buildrow(Colors.green, "Delivered"),
                    _buildrow(Colors.black, "Upcoming"),
                    _buildrow(Colors.purple, "Multiple Orders"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
