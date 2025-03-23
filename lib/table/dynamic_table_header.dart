import 'package:flutter/material.dart';

class DynamicTableHeader extends StatefulWidget {
  final Widget leading;
  final Widget widgetActionsOnSelected;
  final Function(String query) onSearch;
  final Function(DateTime from, DateTime? to) onDateFilter;
  final int countSelected;
  final String searchBarHint;

  const DynamicTableHeader({
    super.key,
    required this.leading,
    required this.widgetActionsOnSelected,
    required this.onSearch,
    required this.onDateFilter,
    this.countSelected = 0,
    this.searchBarHint = 'Search',
  });

  @override
  State<DynamicTableHeader> createState() => _DynamicTableHeaderState();
}

class _DynamicTableHeaderState extends State<DynamicTableHeader> {
  @override
  Widget build(BuildContext context) {
    return widget.countSelected == 0
        ? _PerfectTableHeader(widget: widget)
        : _OnSelectedPerfectTableHeader(
          countSelected: widget.countSelected,
          onSelectedActions: widget.widgetActionsOnSelected,
        );
  }
}

class _PerfectTableHeader extends StatelessWidget {
  const _PerfectTableHeader({required this.widget});

  final DynamicTableHeader widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.leading,
        SizedBox(width: 8),
        const VerticalDivider(indent: 12, endIndent: 12),
        SizedBox(width: 8),
        Expanded(
          child: SearchBar(
            leading: Icon(Icons.search, size: 18),
            hintText: widget.searchBarHint,
            onChanged: (query) => widget.onSearch(query),
          ),
        ),
        SizedBox(width: 8),
        const VerticalDivider(indent: 12, endIndent: 12),
        SizedBox(width: 8),
        // Expanded(child: DateFilterDataWidget(onSearch: widget.onDateFilter)),
      ],
    );
  }
}

class _OnSelectedPerfectTableHeader extends StatelessWidget {
  const _OnSelectedPerfectTableHeader({required this.countSelected, required this.onSelectedActions});

  final int countSelected;
  final Widget onSelectedActions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$countSelected filas seleccionadas',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
        SizedBox(width: 8),
        const VerticalDivider(indent: 12, endIndent: 12),
        SizedBox(width: 8),
        onSelectedActions,
      ],
    );
  }
}
