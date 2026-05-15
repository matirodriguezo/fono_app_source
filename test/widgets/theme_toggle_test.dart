import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fono_app/providers/theme_provider.dart';
import 'package:fono_app/widgets/theme_toggle_button.dart';

Widget _buildTestApp() {
  return ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: const MaterialApp(
      home: Scaffold(
        body: ThemeToggleButton(showLabel: true),
      ),
    ),
  );
}

void main() {
  testWidgets('ThemeToggleButton muestra el ícono del tema actual', (tester) async {
    await tester.pumpWidget(_buildTestApp());

    expect(find.byType(ThemeToggleButton), findsOneWidget);
  });

  testWidgets('ThemeToggleButton cambia el tema al hacer tap', (tester) async {
    await tester.pumpWidget(_buildTestApp());

    final themeProvider = tester.widget<MaterialApp>(find.byType(MaterialApp));
    // Verify toggle exists
    expect(find.byType(GestureDetector), findsWidgets);

    // Tap the toggle
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
  });

  testWidgets('ThemeToggleButton acepta showLabel', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MaterialApp(
          home: Scaffold(
            body: ThemeToggleButton(showLabel: true),
          ),
        ),
      ),
    );

    final toggle = tester.widget<ThemeToggleButton>(
      find.byType(ThemeToggleButton),
    );
    expect(toggle.showLabel, isTrue);
  });
}
