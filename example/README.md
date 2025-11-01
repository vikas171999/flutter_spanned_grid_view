# Example: flutter_spanned_grid_view

This example demonstrates how to use the `flutter_spanned_grid_view` package with custom item types, dynamic spans, and custom widgets in a Flutter app.

## Features Shown
- Custom item types implementing `SpannedGridItem`
- Assigning different `gridSpan` values to items
- Displaying items in a spanned grid layout

## Running the Example

1. Ensure you have Flutter installed. For setup instructions, see the [Flutter documentation](https://docs.flutter.dev/get-started/install).
2. In this directory, run:
   ```sh
   flutter pub get
   flutter run
   ```

## Example Usage

Below is a simplified snippet from `lib/main.dart`:

```dart
final List<SpannedGridItem> items = [
  ItemTypeA(id: 'a1', title: 'Alpha', gridSpan: 2),
  ItemTypeB(id: 'b1', number: 42, gridSpan: 1),
  // ... more items ...
];

SpannedGridView(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    // Return a widget based on item type
  },
  getGridSpan: (index) => items[index].gridSpan ?? 1,
)
```

For more details, see the full source in `lib/main.dart`.
