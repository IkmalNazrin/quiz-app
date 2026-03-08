import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_ui_core/quiz_ui_core.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('GlassHeader', () {
    testWidgets('renders title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const GlassHeader(
          title: Text('Test Title'),
        ),
      ));

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('renders leading widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const GlassHeader(
          leading: Icon(Icons.arrow_back),
        ),
      ));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders actions correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const GlassHeader(
          actions: [
            Icon(Icons.settings),
            Icon(Icons.help),
          ],
        ),
      ));

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.help), findsOneWidget);
    });

    testWidgets('renders child widget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const GlassHeader(
          child: Text('Child Content'),
        ),
      ));

      expect(find.text('Child Content'), findsOneWidget);
    });
  });
}
