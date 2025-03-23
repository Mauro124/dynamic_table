import 'package:dynamic_table/utils/extensions/date_extensions.dart';
import 'package:flutter/material.dart';

class DynamicTableDateFilter extends StatefulWidget {
  final DateTime? initialFromDate;
  final DateTime? initialToDate;
  final Function(DateTime from, DateTime? to) onSearch;
  final Function()? onValidationError;

  const DynamicTableDateFilter({
    super.key,
    required this.onSearch,
    this.initialFromDate,
    this.initialToDate,
    this.onValidationError,
  });

  @override
  State<DynamicTableDateFilter> createState() => _DynamicTableDateFilterState();
}

class _DynamicTableDateFilterState extends State<DynamicTableDateFilter> {
  DateTime fromDate = DateTime.now();
  DateTime? toDate;
  MenuController fromController = MenuController();
  MenuController toController = MenuController();

  @override
  void initState() {
    super.initState();
    fromDate = widget.initialFromDate ?? DateTime.now().subtract(const Duration(days: 40));
    toDate = widget.initialToDate;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 20, color: Theme.of(context).colorScheme.secondary),
          SizedBox(width: 8),
          Expanded(
            child: MenuAnchor(
              controller: fromController,
              menuChildren: [
                PopupMenuItem(
                  enabled: false,
                  child: SizedBox(
                    width: 320,
                    height: 300,
                    child: CalendarDatePicker(
                      initialCalendarMode: DatePickerMode.day,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      onDateChanged: (date) {
                        fromDate = date;
                        setState(() {
                          fromController.close();
                        });
                      },
                    ),
                  ),
                ),
              ],
              child: TextFormField(
                controller: TextEditingController(text: fromDate.toFormattedString()),
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Desde', hintText: 'Hasta'),
                onTap: () async {
                  if (fromController.isOpen) {
                    fromController.close();
                  } else {
                    fromController.open();
                  }
                  setState(() {});
                },
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: MenuAnchor(
              controller: toController,
              menuChildren: [
                PopupMenuItem(
                  enabled: false,
                  child: SizedBox(
                    width: 320,
                    height: 300,
                    child: CalendarDatePicker(
                      initialCalendarMode: DatePickerMode.day,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                      onDateChanged: (date) {
                        if (fromDate.isAfter(date)) {
                          widget.onValidationError?.call();
                          return;
                        }

                        toDate = date;
                        setState(() {
                          toController.close();
                        });
                      },
                    ),
                  ),
                ),
              ],
              child: TextFormField(
                controller: TextEditingController(text: toDate?.toFormattedString()),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Hasta',
                  hintText: 'Hasta',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, size: 16, color: Theme.of(context).colorScheme.tertiary),
                    onPressed: () {
                      toDate = null;
                      setState(() {});
                    },
                  ),
                ),
                onTap: () async {
                  if (toController.isOpen) {
                    toController.close();
                  } else {
                    toController.open();
                  }
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Requerido';
                  }

                  return null;
                },
              ),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
            onPressed: () {
              widget.onSearch(fromDate, toDate);
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }
}
