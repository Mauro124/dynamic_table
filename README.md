# Dynamic Table

Dynamic Table is a Flutter package that provides a customizable table widget with features such as pagination, sorting, search, and date filtering.

## Features

- Pagination
- Sorting
- Search
- Date filtering
- Customizable columns
- Customizable actions for rows and selected rows

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  dynamic_table:
    path: [dynamic_table](http://_vscodecontentref_/0)
```

Then, run flutter pub get to install the package.

## Usage

Here is an example of how to use the DynamicTable widget:

```dart
import 'package:dynamic_table/dynamic_table.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Dynamic Table Example')),
        body: DynamicTable(
          data: [
            {'id': 1, 'name': 'John', 'lastName': 'Doe', 'createdAt': DateTime.now(), 'active': true},
            {'id': 2, 'name': 'Jane', 'lastName': 'Doe', 'createdAt': DateTime.now(), 'active': false},
          ],
          columns: [
            TableColumn(id: 'id', label: 'ID', size: ColumnSize.small),
            TableColumn(id: 'name', label: 'Name'),
            TableColumn(id: 'lastName', label: 'Last Name', size: ColumnSize.large),
            TableColumn(id: 'createdAt', label: 'Created At', type: ColumnType.date),
            TableColumn(id: 'active', label: 'Active', type: ColumnType.boolean),
          ],
          actions: [
            ElevatedButton(
              onPressed: () {},
              child: Text('Add'),
            ),
          ],
          selectedActions: [
            ElevatedButton(
              onPressed: () {},
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### TableColumn Configuration
The TableColumn class allows you to configure the columns of the table. Here are the available properties:

```id:``` The unique identifier for the column.

```label:``` The label to display in the column header.

```type:``` The type of data in the column (ColumnType.text, ColumnType.number, ColumnType.currency, ColumnType.date, ColumnType.boolean).

```size:``` The size of the column (ColumnSize.small, ColumnSize.medium, ColumnSize.large).

### DynamicTableStyle Configuration
The DynamicTableStyle class allows you to customize the appearance of the table. Here are the available properties:

```backgroundColor:``` The background color of the table.

```textColor:``` The text color of the table.

```headerColor:``` The background color of the header.

```headerTextColor:``` The text color of the header.

```selectedColor:``` The background color of selected rows.

```selectedTextColor:``` The text color of selected rows.

```dividersColors:``` The color of the dividers between rows.
