import 'package:dynamic_table/table/dynamic_table_date_filter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

///Dynamic table widget that receives a list of data and columns to render a table
///with pagination, sorting, search and date filtering capabilities.
///[data] List of maps with the data to render in the table
///[columns] List of TableColumn objects with the configuration of each column
///[actions] List of widgets to render in the top right corner of the table
///[selectedActions] List of widgets to render when at least one row is selected
///[rowActions] List of widgets to render at the end of each row
///
///[ColumnType] Enum with the types of columns that can be rendered
/// - types: text, number, currency, date, boolean, default is text
///
///[ColumnSize] Enum with the sizes of columns that can be rendered
/// - sizes: small, medium, large, default is medium
///
///Example:
///```dart
///DynamicTable(
///  data: [
///    {'id': 1, 'name': 'John', 'lastName': 'Doe', 'createdAt': DateTime.now(), 'active': true},
///    {'id': 2, 'name': 'Jane', 'lastName': 'Doe', 'createdAt': DateTime.now(), 'active': false},
///  ],
///  columns: [
///    TableColumn(key: 'id', label: 'ID', size: ColumnSize.small),
///    TableColumn(key: 'name', label: 'Name'),
///    TableColumn(key: 'lastName', label: 'Last Name', size: ColumnSize.large),
///    TableColumn(key: 'createdAt', label: 'Created At', type: ColumnType.date),
///    TableColumn(key: 'active', label: 'Active', type: ColumnType.boolean),
///  ],
///  actions: [
///    ElevatedButton(
///      onPressed: () {},
///      child: Text('Add'),
///    ),
///  ],
///  selectedActions: [
///    ElevatedButton(
///      onPressed: () {},
///      child: Text('Delete'),
///   ),
/// ],
///rowActions: [
/// ElevatedButton(
///  onPressed: () {},
/// child: Text('Edit'),
///),
///],
///)
///```dart
///

enum ColumnType { text, number, currency, date, boolean }

enum ColumnSize { small, medium, large }

class TableColumn {
  final String id;
  final String label;
  final ColumnType type;
  ColumnSize? size;

  TableColumn({required this.id, required this.label, this.type = ColumnType.text, this.size = ColumnSize.medium}) {
    size = type == ColumnType.boolean ? ColumnSize.small : size;
  }
}

class DynamicTableStyle {
  final Color? backgroundColor;
  final Color? textColor;
  final Color? headerColor;
  final Color? headerTextColor;
  final Color? selectedColor;
  final Color? selectedTextColor;
  final Color? dividersColors;

  const DynamicTableStyle({
    this.backgroundColor,
    this.textColor,
    this.headerColor,
    this.headerTextColor,
    this.selectedColor,
    this.selectedTextColor,
    this.dividersColors,
  });
}

class DynamicTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<TableColumn> columns;
  final List<Widget>? actions;
  final List<Widget>? selectedActions;
  final Function(List<String> selectedIndex)? onSelectedRows;
  final List<Widget>? rowActions;
  final int rowsPerPage;
  final DynamicTableStyle? style;

  const DynamicTable({
    super.key,
    required this.data,
    required this.columns,
    this.actions,
    this.selectedActions,
    this.onSelectedRows,
    this.rowActions,
    this.rowsPerPage = 20,
    this.style,
  });

  @override
  _DynamicTableState createState() => _DynamicTableState();
}

class _DynamicTableState extends State<DynamicTable> {
  ValueNotifier<List<bool>> selectedRows = ValueNotifier([]);
  int currentPage = 0;
  String? sortedColumn;
  bool isAscending = true;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  DateTime? dateFrom;
  DateTime? dateTo;
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedRows.value = List.generate(widget.data.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Asegurar que selectedRows tenga el mismo tamaño que data

    selectedRows.addListener(() {
      if (widget.onSelectedRows != null) {
        widget.onSelectedRows!(
          selectedRows.value
              .asMap()
              .entries
              .where((entry) => entry.value)
              .map((entry) => entry.key.toString())
              .toList(),
        );
      }
    });

    List<Map<String, dynamic>> filteredData = _filterData();

    List<Map<String, dynamic>> sortedData = List.from(filteredData);
    if (sortedColumn != null) {
      sortedData.sort((a, b) {
        int compare = 0;
        var aValue = a[sortedColumn];
        var bValue = b[sortedColumn];

        if (aValue is num && bValue is num) {
          compare = aValue.compareTo(bValue);
        } else if (aValue is Comparable && bValue is Comparable) {
          compare = (aValue).compareTo(bValue);
        }

        return isAscending ? compare : -compare;
      });
    }

    final int totalPages = (sortedData.length / widget.rowsPerPage).ceil();
    final int startRow = currentPage * widget.rowsPerPage;
    final int endRow = (startRow + widget.rowsPerPage).clamp(0, sortedData.length);

    bool hasSelectedRows = selectedRows.value.any((selected) => selected);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child:
                hasSelectedRows
                    ? Row(
                      children: [
                        Text('${selectedRows.value.where((selected) => selected).length} seleccionados'),
                        SizedBox(width: 8),
                        VerticalDivider(indent: 12, endIndent: 12),
                        SizedBox(width: 8),
                        ...widget.selectedActions ?? [],
                      ],
                    )
                    : Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _SearchBarWidget(
                                  searchController: searchController,
                                  onSearch: (query) {
                                    setState(() {
                                      searchQuery = query;
                                      currentPage = 0;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              if (widget.columns.any((row) => row.type == ColumnType.date)) ...[
                                VerticalDivider(indent: 12, endIndent: 12),
                                SizedBox(width: 8),
                                DynamicTableDateFilter(
                                  onSearch: (from, to) {
                                    setState(() {
                                      dateFrom = from;
                                      dateTo = to;
                                      currentPage = 0;
                                    });
                                  },
                                ),
                                SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                        Visibility(
                          visible: widget.actions != null,
                          child: Row(
                            children: [
                              VerticalDivider(indent: 12, endIndent: 12),
                              SizedBox(width: 8),
                              ...widget.actions ?? [],
                            ],
                          ),
                        ),
                      ],
                    ),
          ),
          Container(
            color: widget.style?.headerColor ?? Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Checkbox(
                  value: selectedRows.value.isNotEmpty && selectedRows.value.every((selected) => selected),
                  onChanged: (value) {
                    setState(() {
                      selectedRows.value = List.generate(widget.data.length, (index) => value!);
                    });
                  },
                ),
                ...[
                  ...widget.columns.map((col) {
                    return Expanded(
                      flex: columnSize,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (sortedColumn == col.id) {
                              isAscending = !isAscending;
                            } else {
                              sortedColumn = col.id;
                              isAscending = true;
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              col.label.toUpperCase(),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: widget.style?.headerTextColor ?? Colors.black,
                              ),
                            ),
                            if (sortedColumn == col.id) Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (widget.rowActions != null) Expanded(flex: rowActionsSize, child: SizedBox()),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: endRow - startRow,
              itemBuilder: (context, index) {
                final rowIndex = startRow + index;
                final row = sortedData[rowIndex];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: widget.style?.dividersColors ?? Colors.grey)),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: selectedRows.value.elementAtOrNull(rowIndex) ?? false,
                        onChanged: (value) {
                          setState(() {
                            selectedRows.value[rowIndex] = value!;
                          });
                        },
                      ),
                      ...widget.columns.map((col) {
                        return Expanded(
                          flex: columnSize,
                          child: Align(alignment: Alignment.centerLeft, child: _buildCell(row[col.id], col.type)),
                        );
                      }),
                      Visibility(
                        visible: widget.rowActions != null,
                        child: Expanded(
                          flex: rowActionsSize,
                          child: Row(children: [...widget.rowActions!.map((action) => action)]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8),
          _PaginationControls(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: (page) {
              setState(() {
                currentPage = page;
              });
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterData() {
    return widget.data.where((row) {
      bool matchesSearchQuery = row.values.any(
        (value) => value.toString().toLowerCase().contains(searchQuery.toLowerCase()),
      );
      bool matchesDateRange = true;

      if (dateFrom != null) {
        matchesDateRange = row.values.any((value) {
          final dateParsed = DateTime.tryParse(value.toString());
          if (dateParsed == null) return false;
          final isDateFrom =
              dateParsed.day == dateFrom!.day &&
              dateParsed.month == dateFrom!.month &&
              dateParsed.year == dateFrom!.year;
          final isDateTo =
              dateTo != null &&
              dateParsed.day == dateTo!.day &&
              dateParsed.month == dateTo!.month &&
              dateParsed.year == dateTo!.year;
          return isDateFrom || isDateTo;
        });
      }

      return matchesSearchQuery && matchesDateRange;
    }).toList();
  }

  int get columnSize {
    int size = 0;
    for (var col in widget.columns) {
      size +=
          col.size == ColumnSize.large
              ? 3
              : col.size == ColumnSize.medium
              ? 2
              : 1;
    }
    return size;
  }

  int get rowActionsSize => (widget.rowActions?.length ?? 0) * 3;

  Widget _buildCell(dynamic value, ColumnType type) {
    if (value == null) return Text('-');

    switch (type) {
      case ColumnType.date:
        return Text(
          DateFormat('dd/MM/yyyy').format(value is DateTime ? value : DateTime.parse(value.toString())),
          textAlign: TextAlign.start,
        );
      case ColumnType.boolean:
        return Icon(
          value == true ? Icons.check_circle : Icons.cancel,
          color: value == true ? Colors.green : Colors.red,
        );
      case ColumnType.number:
        return Text(value.toString());
      case ColumnType.currency:
        return Text("\$ ${NumberFormat.currency(locale: 'es_AR', symbol: '').format(value)}");
      default:
        return Text(value.toString());
    }
  }
}

class _PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const _PaginationControls({required this.currentPage, required this.totalPages, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed:
              currentPage > 0
                  ? () {
                    onPageChanged(currentPage - 1);
                  }
                  : null,
        ),
        Text('Página ${currentPage + 1} de $totalPages'),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed:
              currentPage < totalPages - 1
                  ? () {
                    onPageChanged(currentPage + 1);
                  }
                  : null,
        ),
      ],
    );
  }
}

class _SearchBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;

  const _SearchBarWidget({required this.searchController, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(hintText: 'Buscar...', prefixIcon: Icon(Icons.search)),
      onChanged: onSearch,
    );
  }
}
