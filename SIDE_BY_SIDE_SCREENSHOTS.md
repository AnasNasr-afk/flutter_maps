# SideBySideScreenshots Widget

A Flutter widget that displays two screenshots side by side with equal dimensions, perfect for before/after comparisons.

## Features

- **Equal Dimensions**: Both images have the same width and height using AspectRatio
- **Side by Side Layout**: Uses Row widget with Expanded children for equal width distribution
- **Error Handling**: Graceful fallback UI when images fail to load
- **Loading States**: Progressive loading indicators while images download
- **Responsive Design**: Uses flutter_screenutil for responsive scaling
- **Reusable**: Can be easily imported and used anywhere in the app

## Usage

### Basic Usage

```dart
import 'package:flutter_maps/presentation/widgets/side_by_side_screenshots.dart';

// Simply add the widget anywhere in your widget tree
const SideBySideScreenshots()
```

### In a Container with Styling

```dart
Container(
  padding: EdgeInsets.all(16.w),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: const SideBySideScreenshots(),
)
```

### In a Dialog

```dart
showDialog(
  context: context,
  builder: (context) => Dialog(
    child: Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Compare Screenshots'),
          const SideBySideScreenshots(),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    ),
  ),
);
```

## Preview Screen

A complete preview screen is available at:
```dart
Navigator.pushNamed(context, Routes.sideBySideScreenshotsPreview);
```

## Image URLs

The widget currently displays these screenshots:
- **Before**: https://github.com/user-attachments/assets/2f2c8d59-2420-4e0d-9343-e1ca4014cadc
- **After**: https://github.com/user-attachments/assets/8c807979-d289-4743-b432-d44cfc93c423

## File Structure

```
lib/presentation/
├── widgets/
│   ├── side_by_side_screenshots.dart          # Main widget
│   └── side_by_side_screenshots_examples.dart # Usage examples
└── screens/
    └── side_by_side_screenshots_preview.dart  # Preview screen
```

## Dependencies

- `flutter/material.dart` - Material Design widgets
- `flutter_screenutil` - Responsive design utilities

## Testing

Run the widget tests with:
```bash
flutter test test/side_by_side_screenshots_test.dart
```

## Examples

See `side_by_side_screenshots_examples.dart` for comprehensive usage examples including:
- Dialog display
- Bottom sheet integration
- Card layouts
- Tab views
- Action buttons
- And more!