export 'flutter_spanned_grid_view_exports.dart';
import 'interfaces/spanned_grid_item.dart';
import 'models/grid_row.dart';

import 'dart:developer';

import 'package:flutter/material.dart';

/// A SpannedGridView that works with any data type
/// implementing GridItem interface.
///
/// This widget builds items only when they come into the viewport,
/// similar to ListView.builder for better performance with large datasets.
class SpannedGridView<T extends SpannedGridItem> extends StatefulWidget {
  /// List of items to display
  final List<T> items;

  /// Builder function to create widget for each item
  /// This is where all type-specific rendering happens
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Maximum number of columns in the grid
  /// If null, auto-calculated from items gridSpan values
  final int? maxColumns;

  /// Spacing between items horizontally
  final double crossAxisSpacing;

  /// Spacing between items vertically
  final double mainAxisSpacing;

  /// Padding around the grid
  final EdgeInsetsGeometry? padding;

  /// Optional scroll controller to allow parent access
  final ScrollController? scrollController;

  const SpannedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.maxColumns,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.scrollController,
    this.padding,
  });

  @override
  State<SpannedGridView<T>> createState() => _SpannedGridViewState<T>();
}

class _SpannedGridViewState<T extends SpannedGridItem> extends State<SpannedGridView<T>> {
  ScrollController _scrollController = ScrollController();
  List<GridRow<T>> _rows = [];
  int _effectiveMaxColumns = 2;

  @override
  void initState() {
    super.initState();
    var widgetScrollController = widget.scrollController;
    if(widgetScrollController != null) {
      _scrollController = widgetScrollController;
    }
    _calculateRows();
  }

  @override
  void didUpdateWidget(SpannedGridView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if we need to recalculate rows
    bool needsRecalculation = false;

    // Check if list reference changed
    if (oldWidget.items != widget.items) {
      needsRecalculation = true;
    }

    // Check if length changed (list was mutated in place)
    if (oldWidget.items.length != widget.items.length) {
      needsRecalculation = true;
    }

    // Check if maxColumns changed
    if (oldWidget.maxColumns != widget.maxColumns) {
      needsRecalculation = true;
    }

    // Check if items content changed (by comparing first/last items)
    if (widget.items.isNotEmpty && oldWidget.items.isNotEmpty) {
      if (oldWidget.items.first != widget.items.first ||
          oldWidget.items.last != widget.items.last) {
        needsRecalculation = true;
      }
    }

    if (needsRecalculation) {
      log('SpannedGridView: Detected change - Recalculating rows (${oldWidget.items.length} -> ${widget.items.length} items)');
      _calculateRows();
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  /// Pre-calculate all rows and their items for efficient lazy loading
  void _calculateRows() {
    if (widget.items.isEmpty) {
      _rows = [];
      return;
    }

    // Save current scroll position before recalculating
    final currentScrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    // Auto-calculate max columns if not provided
    _effectiveMaxColumns = widget.maxColumns ?? _calculateMaxColumns();

    final rows = <GridRow<T>>[];
    int itemIndex = 0;

    while (itemIndex < widget.items.length) {
      final rowItems = <GridRowItem<T>>[];
      int currentRowSpan = 0;

      // Build one row's metadata
      while (currentRowSpan < _effectiveMaxColumns && itemIndex < widget.items.length) {
        final item = widget.items[itemIndex];
        final itemSpan = item.getEffectiveSpan(_effectiveMaxColumns).toInt();

        // Check if item fits in current row
        if (currentRowSpan + itemSpan > _effectiveMaxColumns) {
          break;
        }

        rowItems.add(GridRowItem<T>(
          item: item,
          itemIndex: itemIndex,
          span: itemSpan,
          startColumn: currentRowSpan,
        ));

        currentRowSpan += itemSpan;
        itemIndex++;
      }

      if (rowItems.isNotEmpty) {
        rows.add(GridRow<T>(
          items: rowItems,
          rowIndex: rows.length,
          totalSpan: currentRowSpan,
        ));
      }
    }

    setState(() {
      _rows = rows;
    });

    // Restore scroll position after recalculation
    if (_scrollController.hasClients && currentScrollOffset > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
              currentScrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent)
          );
        }
      });
    }
  }

  /// Auto-calculate maximum columns based on items
  int _calculateMaxColumns() {
    if (widget.items.isEmpty) return 2;

    // Collect all non-null grid spans
    final spans = widget.items
        .map((item) => item.gridSpan)
        .where((span) => span != null && span > 0)
        .map((span) => span!)
        .toList();

    if (spans.isEmpty) return 2; // Default to 2 columns

    // Find the smallest span as base column count
    final minSpan = spans.reduce((a, b) => a < b ? a : b);
    return minSpan.clamp(2, 12);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty || _rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.all(16),
      itemCount: _rows.length,
      itemBuilder: (context, rowIndex) {
        return _buildRow(context, _rows[rowIndex]);
      },
    );
  }

  Widget _buildRow(BuildContext context, GridRow<T> row) {
    final rowWidgets = <Widget>[];

    for (final rowItem in row.items) {
      // Build the actual item widget using the provided builder
      final itemWidget = widget.itemBuilder(
        context,
        rowItem.item,
        rowItem.itemIndex,
      );

      rowWidgets.add(
        Expanded(
          flex: rowItem.span,
          child: Padding(
            padding: EdgeInsets.only(
              right: rowItem.startColumn + rowItem.span < _effectiveMaxColumns
                  ? widget.crossAxisSpacing
                  : 0,
            ),
            child: itemWidget,
          ),
        ),
      );
    }

    // Fill remaining space if row is not full
    if (row.totalSpan < _effectiveMaxColumns) {
      rowWidgets.add(
        Expanded(
          flex: (_effectiveMaxColumns - row.totalSpan).toInt(),
          child: const SizedBox.shrink(),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: row.rowIndex < _rows.length - 1 ? widget.mainAxisSpacing : 0,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowWidgets,
        ),
      ),
    );
  }
}
