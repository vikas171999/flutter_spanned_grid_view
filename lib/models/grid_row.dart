
import 'package:flutter_spanned_grid_view/interfaces/spanned_grid_item.dart';

/// Represents a single row in the grid with its items
class GridRow<T extends SpannedGridItem> {
  final List<GridRowItem<T>> items;
  final int rowIndex;
  final int totalSpan;

  GridRow({
    required this.items,
    required this.rowIndex,
    required this.totalSpan,
  });
}

/// Represents a single item within a grid row
class GridRowItem<T extends SpannedGridItem> {
  final T item;
  final int itemIndex;
  final int span;
  final int startColumn;

  GridRowItem({
    required this.item,
    required this.itemIndex,
    required this.span,
    required this.startColumn,
  });
}