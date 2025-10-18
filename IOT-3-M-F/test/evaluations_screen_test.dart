import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_uno/screens/evaluaciones_screen.dart';
import 'fake_evaluation_service.dart';
import 'fake_auth_service.dart';
import 'package:proyecto_uno/models/evaluacion.dart';

void main() {
  testWidgets('EvaluationsScreen shows items from service',
      (WidgetTester tester) async {
    final fake = FakeEvaluationService();

    final fakeAuth = FakeAuthService();
    await tester.pumpWidget(MaterialApp(
        home:
            EvaluationsScreen(evaluationService: fake, authService: fakeAuth)));

    // push items
    fake.push([
      Evaluacion(id: '1', title: 'One'),
      Evaluacion(id: '2', title: 'Two', isDone: true),
    ]);

    // allow stream events to propagate
    await tester.pumpAndSettle();

    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);

    fake.dispose();
  });
}
