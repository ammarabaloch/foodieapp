import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodie_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FoodieApp smoke test and navigation verification', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const FoodieApp());
    await tester.pumpAndSettle();

    // Verify brand title and welcome heading
    expect(find.text('Foodie'), findsWidgets);
    expect(find.text('What would you like to cook today?'), findsOneWidget);

    // Verify horizontal categories are present including My Food
    expect(find.text('All Recipes'), findsOneWidget);
    expect(find.text('My Food'), findsWidgets);
    expect(find.text('Breakfast'), findsOneWidget);

    // Verify navigation tabs
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Favorites'), findsWidgets);

    // Switch to Favorites tab
    await tester.tap(find.text('Favorites').first);
    await tester.pumpAndSettle();
    expect(find.text('Saved Favorites'), findsOneWidget);

    // Switch to My Food tab
    await tester.tap(find.text('My Food').first);
    await tester.pumpAndSettle();
    expect(find.text('Add Recipe'), findsOneWidget);
  });

  testWidgets('FoodieApp recipe search and category filtering test', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const FoodieApp());
    await tester.pumpAndSettle();

    // Enter search query
    await tester.enterText(find.byType(TextField).first, 'Salmon');
    await tester.pumpAndSettle();

    // Verify filtered results
    expect(find.text('Creamy Tuscan Garlic Butter Salmon'), findsWidgets);

    // Clear search
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Verify return to normal state
    expect(find.text('Featured Recipes'), findsOneWidget);

    // Filter by Breakfast category
    await tester.tap(find.text('Breakfast'));
    await tester.pumpAndSettle();
    expect(find.text('Avocado & Poached Egg Toast'), findsWidgets);
  });
}
