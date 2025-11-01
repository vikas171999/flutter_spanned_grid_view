/// Interface that any grid item must implement
/// This makes the grid view completely generic
abstract class SpannedGridItem {
  /// Unique identifier for the item
  String get id;

  /// Grid span - how many columns this item should occupy
  /// If null or not specified, item will take full width
  /// Must be between 1 and the maximum columns in the grid
  int? get gridSpan;
}

/// Extension to provide default values
extension SpannedGridItemDefaults on SpannedGridItem {
  /// Get effective grid span - defaults to full width if not specified
  int getEffectiveSpan(int maxColumns) {
    if (maxColumns < 1) {
      return 12;
    }
    return gridSpan?.clamp(1, maxColumns) ?? maxColumns;
  }
}
