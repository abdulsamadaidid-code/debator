// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:debator/app/app.dart';
import 'package:debator/data/repositories/debate_repository.dart';
import 'package:debator/data/services/mock_debate_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads discover tab and can create a debate', (tester) async {
    await tester.pumpWidget(
      DebatorApp(
        repository: DebateRepository(dataSource: MockDebateDataSource()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(
      find.text('A home for arguments that actually want structure.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Create').last);
    await tester.pumpAndSettle();

    Finder editableField(String key) {
      return find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(EditableText),
      );
    }

    await tester.enterText(
      editableField('create-title-field'),
      'Prototype Test Debate',
    );
    await tester.enterText(
      editableField('create-proposition-field'),
      'Structured debate apps create better arguments.',
    );
    await tester.enterText(
      editableField('create-overview-field'),
      'A short overview explaining why structure matters.',
    );
    await tester.enterText(
      editableField('create-opening-field'),
      'Open feeds reward heat. Structured rounds reward thought.',
    );

    await tester.ensureVisible(find.text('Launch debate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Launch debate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Prototype Test Debate'), findsOneWidget);
  });
}
