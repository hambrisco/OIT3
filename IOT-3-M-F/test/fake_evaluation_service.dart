import 'dart:async';
import 'package:proyecto_uno/models/evaluacion.dart';
import 'package:proyecto_uno/services/evaluation_service.dart';

/// Fake implementation to be used in widget tests. It exposes a controller to push lists.
class FakeEvaluationService implements IEvaluationService {
  final _controller = StreamController<List<Evaluacion>>.broadcast();

  void push(List<Evaluacion> items) => _controller.add(items);

  @override
  Stream<List<Evaluacion>> getEvaluacionesStream() => _controller.stream;

  @override
  Future<void> addEvaluation(Evaluacion evaluacion) async {}

  @override
  Future<List<Evaluacion>> getEvaluations() async => [];

  @override
  Future<void> updateEvaluation(
      Evaluacion oldEvaluation, Evaluacion newEvaluation) async {}

  @override
  Future<void> toggleEvaluationStatus(String id, bool isDone) async {}

  @override
  Future<void> deleteEvaluation(String id) async {}

  void dispose() => _controller.close();
}
