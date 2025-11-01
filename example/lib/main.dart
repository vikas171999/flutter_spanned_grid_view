import 'package:flutter/material.dart';
import 'package:flutter_spanned_grid_view/flutter_spanned_grid_view.dart';


void main() => runApp(const MyApp());

class ItemTypeA implements SpannedGridItem {
  @override
  final String id;
  @override
  final int? gridSpan;
  final String title;

  ItemTypeA({required this.id, required this.title, this.gridSpan});
}

class ItemTypeB implements SpannedGridItem {
  @override
  final String id;
  @override
  final int? gridSpan;
  final int number;

  ItemTypeB({required this.id, required this.number, this.gridSpan});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final List<SpannedGridItem> items = [
      ItemTypeA(id: 'a1', title: 'Alpha', gridSpan: 2),
      ItemTypeB(id: 'b1', number: 42, gridSpan: 1),
      ItemTypeA(id: 'a2', title: 'Beta', gridSpan: 1),
      ItemTypeB(id: 'b2', number: 6, gridSpan: 2),
      ItemTypeA(id: 'a4', title: 'Delta', gridSpan: 3),
      ItemTypeA(id: 'a3', title: 'Gamma', gridSpan: 2),
      ItemTypeB(id: 'b3', number: 99, gridSpan: 1),
      ItemTypeA(id: 'a2', title: 'Beta', gridSpan: 1),
      ItemTypeB(id: 'b2', number: 6, gridSpan: 1),
      ItemTypeA(id: 'a2', title: 'Beta', gridSpan: 1),
    ];
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('SpannedGridView Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SpannedGridView<SpannedGridItem>(
            items: items,
            maxColumns: 3,
            itemBuilder: (context, item, index) => ItemWidgetFactory.build(context, item, index),
          ),
        ),
      ),
    );
  }
}

class ItemWidgetFactory {
  static Widget build(BuildContext context, SpannedGridItem item, int index) {
    if (item is ItemTypeA) {
      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        shadowColor: Colors.blueAccent.withValues(alpha: 0.4),
        color: Colors.blueAccent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else if (item is ItemTypeB) {
      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        shadowColor: Colors.green.withValues(alpha: 0.4),
        color: Colors.green,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.numbers, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              Text(
                item.number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
