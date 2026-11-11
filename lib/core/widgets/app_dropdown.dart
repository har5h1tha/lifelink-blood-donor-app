import 'package:flutter/material.dart';

// NOTE: `validator` is an optional extra added to the spec (needed for forms).
class AppDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool allowAll; // adds an 'All' option whose value is null
  final String? Function(String?)? validator;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.allowAll = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: value,
      isExpanded: true,
      validator: validator,
      decoration: InputDecoration(labelText: label),
      items: [
        if (allowAll) const DropdownMenuItem<String>(value: null, child: Text('All')),
        ...items.map((i) => DropdownMenuItem<String>(value: i, child: Text(i))),
      ],
      onChanged: onChanged,
    );
  }
}
