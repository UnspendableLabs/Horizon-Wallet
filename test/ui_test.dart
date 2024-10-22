import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart';

void main() {
  group('HorizonSearchableDropdownMenu', () {
    testWidgets('renders correctly with initial state',
        (WidgetTester tester) async {
      final items = [
        const DropdownMenuItem(value: 'apple', child: Text('Apple')),
        const DropdownMenuItem(value: 'banana', child: Text('Banana')),
        const DropdownMenuItem(value: 'cherry', child: Text('Cherry')),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizonSearchableDropdownMenu<String>(
              items: items,
              onChanged: (_) {},
              label: 'Select a fruit',
              displayStringForOption: (String value) => value,
            ),
          ),
        ),
      );

      // Check if at least one widget with the text "Select a fruit" exists
      expect(find.text('Select a fruit'), findsWidgets);

      // Check for the dropdown icon
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);

      // Ensure the TextField (search field) is not visible initially
      expect(find.byType(TextField), findsNothing);

      // Verify that none of the item texts are visible initially
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Banana'), findsNothing);
      expect(find.text('Cherry'), findsNothing);
    });

    testWidgets('opens dropdown when tapped', (WidgetTester tester) async {
      final items = [
        const DropdownMenuItem(value: 'apple', child: Text('Apple')),
        const DropdownMenuItem(value: 'banana', child: Text('Banana')),
        const DropdownMenuItem(value: 'cherry', child: Text('Cherry')),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizonSearchableDropdownMenu<String>(
              items: items,
              onChanged: (_) {},
              label: 'Select a fruit',
              displayStringForOption: (String value) => value,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select a fruit').first);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search...'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('filters items when searching', (WidgetTester tester) async {
      final items = [
        const DropdownMenuItem(value: 'apple', child: Text('Apple')),
        const DropdownMenuItem(value: 'banana', child: Text('Banana')),
        const DropdownMenuItem(value: 'cherry', child: Text('Cherry')),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizonSearchableDropdownMenu<String>(
              items: items,
              onChanged: (_) {},
              label: 'Select a fruit',
              displayStringForOption: (String value) => value,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select a fruit').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'an');
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsNothing);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsNothing);
    });

    testWidgets('selects item when tapped', (WidgetTester tester) async {
      String? selectedValue;
      final items = [
        const DropdownMenuItem(value: 'apple', child: Text('Apple')),
        const DropdownMenuItem(value: 'banana', child: Text('Banana')),
        const DropdownMenuItem(value: 'cherry', child: Text('Cherry')),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizonSearchableDropdownMenu<String>(
              items: items,
              onChanged: (value) => selectedValue = value,
              label: 'Select a fruit',
              displayStringForOption: (String value) => value,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select a fruit').first);
      await tester.pumpAndSettle();

      // Find and tap the 'Banana' option
      final bananaOption = find.text('Banana');
      expect(bananaOption, findsOneWidget);
      await tester.tap(bananaOption);
      await tester.pumpAndSettle();

      expect(selectedValue, equals('banana'));
    });

    testWidgets('displays selected value', (WidgetTester tester) async {
      final items = [
        const DropdownMenuItem(value: 'apple', child: Text('Apple')),
        const DropdownMenuItem(value: 'banana', child: Text('Banana')),
        const DropdownMenuItem(value: 'cherry', child: Text('Cherry')),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizonSearchableDropdownMenu<String>(
              items: items,
              onChanged: (_) {},
              label: 'Select a fruit',
              selectedValue: 'banana',
              displayStringForOption: (String value) => value,
            ),
          ),
        ),
      );

      final dropdown = find.byType(HorizonSearchableDropdownMenu<String>);
      expect(dropdown, findsOneWidget);
      expect(find.text('banana'), findsOneWidget);
    });

    testWidgets('respects enabled property', (WidgetTester tester) async {
      final items = [
        const DropdownMenuItem(value: 'apple', child: Text('Apple')),
        const DropdownMenuItem(value: 'banana', child: Text('Banana')),
        const DropdownMenuItem(value: 'cherry', child: Text('Cherry')),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizonSearchableDropdownMenu<String>(
              items: items,
              onChanged: (_) {},
              label: 'Select a fruit',
              enabled: false,
              displayStringForOption: (String value) => value,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select a fruit').first);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('displays error text when validator returns error',
        (WidgetTester tester) async {
      final items = [
        const DropdownMenuItem(value: 'apple', child: Text('Apple')),
        const DropdownMenuItem(value: 'banana', child: Text('Banana')),
        const DropdownMenuItem(value: 'cherry', child: Text('Cherry')),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HorizonSearchableDropdownMenu<String>(
              items: items,
              onChanged: (_) {},
              label: 'Select a fruit',
              validator: (value) =>
                  value == null ? 'Please select a fruit' : null,
              autovalidateMode: AutovalidateMode.always,
              displayStringForOption: (String value) => value,
            ),
          ),
        ),
      );

      expect(find.text('Please select a fruit'), findsOneWidget);
    });
  });
}
