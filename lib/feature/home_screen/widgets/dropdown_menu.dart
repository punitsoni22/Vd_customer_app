import 'package:flutter/material.dart';

class MyDropdown extends StatefulWidget {
  final List<String> items;
  final String? selectedItem;
  final Function(String?) onChanged;
  final String hintText;

  const MyDropdown({
    super.key,
    required this.items,
    this.selectedItem,
    required this.onChanged,
    this.hintText = "Select an item",
  });

  @override
  _MyDropdownState createState() => _MyDropdownState();
}

class _MyDropdownState extends State<MyDropdown> {
  String? _currentSelected;

  @override
  void initState() {
    super.initState();
    _currentSelected = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: Text(widget.hintText),
      value: _currentSelected,
      icon: Icon(Icons.arrow_drop_down),
      onChanged: (String? newValue) {
        setState(() {
          _currentSelected = newValue;
        });
        widget.onChanged(newValue);
      },
      items: widget.items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
    );
  }
}
