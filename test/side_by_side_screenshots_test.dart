import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_maps/presentation/widgets/side_by_side_screenshots.dart';

void main() {
  group('SideBySideScreenshots Widget Tests', () {
    testWidgets('should render two images side by side', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: const SideBySideScreenshots(),
            ),
          ),
        ),
      );

      // Verify that the widget renders
      expect(find.byType(SideBySideScreenshots), findsOneWidget);
      
      // Verify that there are two image containers
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Expanded), findsNWidgets(2));
      
      // Verify that labels are present
      expect(find.text('Before'), findsOneWidget);
      expect(find.text('After'), findsOneWidget);
      
      // Verify that Image.network widgets are present
      expect(find.byType(Image), findsNWidgets(2));
    });

    testWidgets('should have equal aspect ratios for both images', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: const SideBySideScreenshots(),
            ),
          ),
        ),
      );

      // Verify that AspectRatio widgets are present to ensure equal dimensions
      expect(find.byType(AspectRatio), findsNWidgets(2));
      
      // Get both AspectRatio widgets and verify they have the same ratio
      final aspectRatioWidgets = tester.widgetList<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatioWidgets.length, 2);
      expect(aspectRatioWidgets.first.aspectRatio, 1.0);
      expect(aspectRatioWidgets.last.aspectRatio, 1.0);
    });

    testWidgets('should have proper styling and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          child: MaterialApp(
            home: Scaffold(
              body: const SideBySideScreenshots(),
            ),
          ),
        ),
      );

      // Verify container padding
      expect(find.byType(Container), findsWidgets);
      
      // Verify ClipRRect for rounded corners
      expect(find.byType(ClipRRect), findsNWidgets(2));
      
      // Verify text styling
      final beforeText = tester.widget<Text>(find.text('Before'));
      final afterText = tester.widget<Text>(find.text('After'));
      
      expect(beforeText.style?.fontWeight, FontWeight.bold);
      expect(afterText.style?.fontWeight, FontWeight.bold);
    });
  });
}