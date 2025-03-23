import 'package:flutter/material.dart';

class DynamicTableEmptyState extends StatelessWidget {
  final Widget? child;

  const DynamicTableEmptyState({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return child ??
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.folder_open, size: 64), SizedBox(height: 8), Text('No data found')],
        );
  }
}
