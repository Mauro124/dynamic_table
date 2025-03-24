import 'package:flutter/material.dart';

enum ColumnType { text, number, currency, date, boolean, action }

enum ColumnSize { small, medium, large }

class TableColumn {
  final String id;
  final String label;
  final ColumnType type;
  ColumnSize? size;
  final Widget Function(dynamic row)? childBuilder;

  TableColumn({
    required this.id,
    required this.label,
    this.type = ColumnType.text,
    this.size = ColumnSize.medium,
    this.childBuilder,
  }) {
    size = type == ColumnType.boolean ? ColumnSize.small : size;
  }

  TableColumn.text({required this.id, required this.label, this.size = ColumnSize.medium, this.childBuilder})
    : type = ColumnType.text;

  TableColumn.action({required this.id, required this.label, required this.childBuilder, this.size = ColumnSize.small})
    : type = ColumnType.action;

  TableColumn.date({required this.id, required this.label, this.size = ColumnSize.medium, this.childBuilder})
    : type = ColumnType.date;

  TableColumn.boolean({required this.id, required this.label, this.size = ColumnSize.small, this.childBuilder})
    : type = ColumnType.boolean;

  TableColumn.number({required this.id, required this.label, this.size = ColumnSize.medium, this.childBuilder})
    : type = ColumnType.number;

  TableColumn.currency({required this.id, required this.label, this.size = ColumnSize.medium, this.childBuilder})
    : type = ColumnType.currency;
}
