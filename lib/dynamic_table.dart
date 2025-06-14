import 'package:dynamic_table/table/table_column.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

///Dynamic table widget that receives a list of data and columns to render a table
///with pagination, sorting, search and date filtering capabilities.
///[data] List of maps with the data to render in the table
///[columns] List of TableColumn objects with the configuration of each column
///[actions] List of widgets to render in the top right corner of the table
///[selectedActions] List of widgets to render when at least one row is selected
///[onSelectedRows] Function that receives a list of selected indexes
///[rowsPerPage] Number of rows to render per page, default is 20
///[style] DynamicTableStyle object with the style configuration
///
///[ColumnType] Enum with the types of columns that can be rendered
/// - types: text, number, currency, date, boolean, action, default is text
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
///],
///)
///```dart
///

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

class DynamicTableSelectedRow {
  final int index;
  final Map<String, dynamic> data;

  DynamicTableSelectedRow({required this.index, required this.data});
}

class DynamicTableController {
  void Function() clearSelectedRows = () {};
}

class DynamicTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<TableColumn> columns;
  final List<Widget>? actions;
  final List<Widget>? selectedActions;
  final Function(List<Map<String, dynamic>> selectedIndex)? onSelectedRows;
  final int rowsPerPage;
  final DynamicTableStyle? style;
  final DynamicTableController? controller;
  final List<Widget>? leading;
  final bool showCheckboxs;

  const DynamicTable({
    super.key,
    required this.data,
    required this.columns,
    this.actions,
    this.selectedActions,
    this.onSelectedRows,
    this.rowsPerPage = 20,
    this.style,
    this.controller,
    this.leading,
    this.showCheckboxs = true,
  });

  @override
  _DynamicTableState createState() => _DynamicTableState();
}

class _DynamicTableState extends State<DynamicTable> {
  ValueNotifier<List<DynamicTableSelectedRow>> selectedRows = ValueNotifier([]);
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
    if (widget.controller != null) {
      widget.controller!.clearSelectedRows = () {
        setState(() {
          selectedRows.value = [];
        });
      };
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    selectedRows.addListener(() {
      if (widget.onSelectedRows != null) {
        widget.onSelectedRows!(selectedRows.value.map((row) => row.data).toList());
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

    bool hasSelectedRows = selectedRows.value.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Container(
            height: kMinInteractiveDimension,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: hasSelectedRows ? _SelectedRowsHeader(selectedRows: selectedRows, widget: widget) : _actionsHeader(),
          ),
          _header(),
          _body(endRow, startRow, sortedData),
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

  Container _header() {
    return Container(
      height: 36,
      color: widget.style?.headerColor ?? Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        children: [
          Visibility(
            visible: widget.showCheckboxs,
            child: Checkbox(
              value: selectedRows.value.length == widget.data.length,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedRows.value =
                        widget.data
                            .asMap()
                            .entries
                            .map((e) => DynamicTableSelectedRow(index: e.key, data: e.value))
                            .toList();
                  } else {
                    selectedRows.value = [];
                  }
                });
              },
            ),
          ),
          ...widget.columns.map((col) {
            return Flexible(
              flex: columnSize(col),
              child: InkWell(
                mouseCursor:
                    col.type != ColumnType.action && col.type != ColumnType.dynamic && col.childBuilder == null
                        ? SystemMouseCursors.click
                        : MouseCursor.defer,
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
                    if (sortedColumn == col.id &&
                        col.type != ColumnType.action &&
                        col.type != ColumnType.dynamic &&
                        col.childBuilder == null)
                      Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16, color: Colors.black),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        col.label,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.style?.headerTextColor ?? Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Expanded _body(int endRow, int startRow, List<Map<String, dynamic>> sortedData) {
    if (sortedData.isEmpty) {
      return Expanded(child: Center(child: Text('No hay datos para mostrar')));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: endRow - startRow,
        itemBuilder: (context, index) {
          final rowIndex = startRow + index;
          final row = sortedData[rowIndex];
          return Container(
            height: 36,
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: widget.style?.dividersColors ?? Colors.grey)),
            ),
            child: Row(
              children: [
                Visibility(
                  visible: widget.showCheckboxs,
                  child: Checkbox(
                    value: selectedRows.value.any((element) => element.index == rowIndex),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedRows.value = [
                            ...selectedRows.value,
                            DynamicTableSelectedRow(index: rowIndex, data: row),
                          ];
                        } else {
                          selectedRows.value =
                              selectedRows.value.where((element) => element.index != rowIndex).toList();
                        }
                      });
                    },
                  ),
                ),
                ...widget.columns.map((col) {
                  return Expanded(
                    flex: columnSize(col),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child:
                            col.type == ColumnType.action || col.type == ColumnType.dynamic || col.childBuilder != null
                                ? SizedBox(height: 28, child: col.childBuilder!(row))
                                : Material(
                                  textStyle: TextStyle(
                                    color: widget.style?.textColor ?? Colors.black,
                                    fontSize: 14,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: _buildCell(row[col.id], col.type),
                                  ),
                                ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Row _actionsHeader() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              if (widget.leading != null) ...[
                const SizedBox(width: 4),
                ...widget.leading!,
                const SizedBox(width: 12),
                VerticalDivider(indent: 4, endIndent: 4),
                const SizedBox(width: 12),
              ],
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
              SizedBox(width: 12),
              // if (widget.columns.any((row) => row.type == ColumnType.date)) ...[
              //   VerticalDivider(indent: 4, endIndent: 4),
              //   SizedBox(width: 12),
              //   DynamicTableDateFilter(
              //     onSearch: (from, to) {
              //       setState(() {
              //         dateFrom = from;
              //         dateTo = to;
              //         currentPage = 0;
              //       });
              //     },
              //   ),
              //   SizedBox(width: 8),
              // ],
            ],
          ),
        ),
        Visibility(
          visible: widget.actions != null,
          child: Row(
            children: [VerticalDivider(indent: 4, endIndent: 4), SizedBox(width: 12), ...widget.actions ?? []],
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _filterData() {
    return widget.data.where((row) {
      bool matchesSearchQuery = row.values.any(
        (value) => value.toString().trim().toLowerCase().contains(searchQuery.toLowerCase()),
      );
      // bool matchesDateRange = true;

      // if (dateFrom != null) {
      //   matchesDateRange = row.values.any((value) {
      //     final dateParsed = DateTime.tryParse(value.toString());
      //     return dateParsed != null && dateParsed.isAfter(dateFrom!);
      //   });
      // }

      return matchesSearchQuery;
    }).toList();
  }

  int columnSize(column) {
    switch (column.size) {
      case ColumnSize.small:
        return 1;
      case ColumnSize.large:
        return 3;
      default:
        return 2;
    }
  }

  Widget _buildCell(dynamic value, ColumnType type) {
    if (value == null) return Text('-');

    switch (type) {
      case ColumnType.date:
        return Text(
          DateFormat('dd/MM/yyyy').format(value is DateTime ? value : DateTime.parse(value.toString())),
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        );
      case ColumnType.boolean:
        return Icon(
          value == true ? Icons.check_circle : Icons.cancel,
          color: value == true ? Colors.green : Colors.red,
        );
      case ColumnType.number:
        return Text(value.toString(), textAlign: TextAlign.start, overflow: TextOverflow.ellipsis);
      case ColumnType.currency:
        return Text(
          "\$ ${NumberFormat.currency(locale: 'es_AR', symbol: '').format(value)}",
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        );
      default:
        return Text(value.toString(), textAlign: TextAlign.start, overflow: TextOverflow.ellipsis);
    }
  }
}

class _SelectedRowsHeader extends StatelessWidget {
  const _SelectedRowsHeader({required this.selectedRows, required this.widget});

  final ValueNotifier<List<DynamicTableSelectedRow>> selectedRows;
  final DynamicTable widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('${selectedRows.value.length} seleccionados'),
        SizedBox(width: 8),
        VerticalDivider(indent: 4, endIndent: 4),
        SizedBox(width: 8),
        ...widget.selectedActions ?? [],
      ],
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const _PaginationControls({required this.currentPage, required this.totalPages, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    if (totalPages == 0 || totalPages == 1) return SizedBox();

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
