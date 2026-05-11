import 'package:chauve_michel_ops/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navigates between operations sections', (tester) async {
    await tester.pumpWidget(const ChauveMichelApp(screenshotMode: true));
    await tester.pumpAndSettle();

    expect(find.text('Operations control'), findsOneWidget);

    await tester.tap(find.text('Assets'));
    await tester.pumpAndSettle();
    expect(find.text('Asset management'), findsOneWidget);
    expect(find.text('Forklift A12'), findsOneWidget);

    await tester.tap(find.text('Quality'));
    await tester.pumpAndSettle();
    expect(find.text('Quality control'), findsOneWidget);
    expect(find.text('Cold storage'), findsOneWidget);

    await tester.tap(find.text('Compliance'));
    await tester.pumpAndSettle();
    expect(find.text('Compliance reporting'), findsOneWidget);
    expect(find.text('Weekly safety register'), findsOneWidget);
  });

  testWidgets('adds a local asset record', (tester) async {
    await tester.pumpWidget(const ChauveMichelApp(screenshotMode: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Assets'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Asset name'),
      'Compressor C4',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Asset tag'),
      'CMP-C4',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Zone'), 'Plant');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Owner'),
      'Nadia',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Note'),
      'Pressure cycle verified before handoff.',
    );
    await tester.tap(find.text('Save record'));
    await tester.pumpAndSettle();

    expect(find.text('Compressor C4'), findsOneWidget);
    expect(find.textContaining('CMP-C4'), findsOneWidget);
  });

  testWidgets('opens local privacy settings', (tester) async {
    await tester.pumpWidget(const ChauveMichelApp(screenshotMode: true));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Local-only workspace'), findsOneWidget);
    expect(find.textContaining(supportEmail), findsOneWidget);
  });
}
