import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/presentation/screens/update_issuance/view/update_issuance_page.dart';

void main() {
  group('buildSubassetNameField', () {
    late TextEditingController subassetController;
    late Asset originalAsset;
    late GlobalKey<FormState> formKey;

    setUp(() {
      subassetController = TextEditingController(text: 'PIZZA.');
      originalAsset = const Asset(asset: 'PIZZA', assetLongname: 'PIZZA');
      formKey = GlobalKey<FormState>();
    });

    testWidgets('displays initial prefix', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildSubassetNameField(
              formKey,
              originalAsset,
              subassetController,
              (_) {},
            ),
          ),
        ),
      );

      expect(find.text('PIZZA.'), findsOneWidget);
    });

    testWidgets('validates empty input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: buildSubassetNameField(
                formKey,
                originalAsset,
                subassetController,
                (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '');
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Please enter a subasset name'), findsOneWidget);
    });

    testWidgets('validates length constraints', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: buildSubassetNameField(
                formKey,
                originalAsset,
                subassetController,
                (_) {},
              ),
            ),
          ),
        ),
      );

      final longString = List.filled(251, 'X').join();

      await tester.enterText(find.byType(TextFormField), 'PIZZA.$longString');
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Subasset name must be between 1 and 250 characters'),
          findsOneWidget);
    });

    testWidgets('validates period constraints', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: buildSubassetNameField(
                formKey,
                originalAsset,
                subassetController,
                (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'PIZZA..X');
      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Subasset name cannot contain consecutive periods'),
          findsOneWidget);
    });

    testWidgets('filters invalid characters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildSubassetNameField(
              formKey,
              originalAsset,
              subassetController,
              (_) {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'PIZZA.X@#');
      await tester.pump();

      expect(subassetController.text, 'PIZZA.X@');
    });

    testWidgets('filters invalid characters and allows lowercase',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildSubassetNameField(
              formKey,
              originalAsset,
              subassetController,
              (_) {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'PIZZA.x@#ABc!_');
      await tester.pump();

      expect(subassetController.text, 'PIZZA.x@ABc!_');
    });
  });
}
