import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_uno/screens/login_screen.dart';
import 'package:proyecto_uno/models/evaluation.dart' as models;

void main() {
  group('Login Screen Tests', () {
    testWidgets('should show error when email is invalid',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Tap the login button without entering any data
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Should find error message
      expect(find.text('Por favor ingrese su correo'), findsOneWidget);
    });

    testWidgets('should show error when password is too short',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Enter email and short password
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, '12345');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Should find password error message
      expect(find.text('La contraseña debe tener al menos 6 caracteres'),
          findsOneWidget);
    });
  });

  group('Evaluation Model Tests', () {
    test('should correctly identify overdue evaluations', () {
      final pastEvaluation = models.Evaluation(
        title: 'Past Test',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      final futureEvaluation = models.Evaluation(
        title: 'Future Test',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );

      expect(pastEvaluation.isOverdue, true);
      expect(futureEvaluation.isOverdue, false);
    });

    test('should correctly identify pending evaluations', () {
      final pendingEvaluation = models.Evaluation(
        title: 'Pending Test',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isDone: false,
      );

      final completedEvaluation = models.Evaluation(
        title: 'Completed Test',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isDone: true,
      );

      expect(pendingEvaluation.isPending, true);
      expect(completedEvaluation.isPending, false);
    });
  });

  // Note: Evaluations screen widget tests were removed because they require
  // a live Firebase instance. To test widgets that depend on Firebase,
  // either mock the services or initialize Firebase with emulators.
}
