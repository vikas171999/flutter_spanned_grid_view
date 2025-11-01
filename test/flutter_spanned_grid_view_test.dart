import 'package:flutter/material.dart';
import 'package:flutter_spanned_grid_view/flutter_spanned_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

class TestGridItem implements SpannedGridItem {
  @override
  final String id;
  @override
  final int? gridSpan;
  final String label;
  TestGridItem(this.id, {this.gridSpan, required this.label});
}

Widget buildTestGrid({
  required List<TestGridItem> items,
  int? maxColumns,
  double crossAxisSpacing = 12,
  double mainAxisSpacing = 12,
  EdgeInsetsGeometry? padding,
  ScrollController? controller,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SpannedGridView<TestGridItem>(
        items: items,
        itemBuilder: (context, item, index) =>
            Text(item.label, key: ValueKey(item.id)),
        maxColumns: maxColumns,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        padding: padding,
        scrollController: controller,
      ),
    ),
  );
}

void main() {
  testWidgets('renders correct number of items', (tester) async {
    final items =
        List.generate(5, (i) => TestGridItem('id$i', label: 'Item $i'));
    await tester.pumpWidget(buildTestGrid(items: items));
    for (final item in items) {
      expect(find.text(item.label), findsOneWidget);
    }
  });

  testWidgets('renders nothing for empty list', (tester) async {
    await tester.pumpWidget(buildTestGrid(items: []));
    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('itemBuilder receives correct parameters', (tester) async {
    final items = [TestGridItem('id1', label: 'A')];
    await tester.pumpWidget(buildTestGrid(items: items));
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('respects maxColumns and gridSpan', (tester) async {
    final items = [
      TestGridItem('id1', gridSpan: 1, label: 'A'),
      TestGridItem('id2', gridSpan: 2, label: 'B'),
      TestGridItem('id3', gridSpan: 1, label: 'C'),
    ];
    await tester.pumpWidget(buildTestGrid(items: items, maxColumns: 3));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('applies crossAxisSpacing, mainAxisSpacing, and padding',
      (tester) async {
    final items = [
      TestGridItem('id1', label: 'A'),
      TestGridItem('id2', label: 'B')
    ];
    await tester.pumpWidget(buildTestGrid(
      items: items,
      crossAxisSpacing: 20,
      mainAxisSpacing: 30,
      padding: const EdgeInsets.all(40),
    ));
    // Padding is applied to ListView
    final listView = tester.widget<ListView>(find.byType(ListView));
    expect(listView.padding, const EdgeInsets.all(40));
  });

  testWidgets('uses provided scroll controller', (tester) async {
    final controller = ScrollController();
    final items =
        List.generate(20, (i) => TestGridItem('id$i', label: 'Item $i'));
    await tester
        .pumpWidget(buildTestGrid(items: items, controller: controller));
    expect(controller.hasClients, isTrue);
  });

  testWidgets('fills incomplete rows with empty space', (tester) async {
    final items = [
      TestGridItem('id1', gridSpan: 1, label: 'A'),
      TestGridItem('id2', gridSpan: 1, label: 'B'),
    ];
    await tester.pumpWidget(buildTestGrid(items: items, maxColumns: 3));
    // There should be a SizedBox.shrink for the empty space
    expect(find.byType(SizedBox), findsWidgets);
  });

  testWidgets('updates layout when items or columns change', (tester) async {
    final items1 = [TestGridItem('id1', label: 'A')];
    final items2 = [
      TestGridItem('id1', label: 'A'),
      TestGridItem('id2', label: 'B')
    ];
    await tester.pumpWidget(buildTestGrid(items: items1, maxColumns: 2));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);
    await tester.pumpWidget(buildTestGrid(items: items2, maxColumns: 2));
    expect(find.text('B'), findsOneWidget);
    await tester.pumpWidget(buildTestGrid(items: items2, maxColumns: 3));
    // Should still show both items
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });
}
