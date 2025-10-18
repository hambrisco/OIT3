import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/evaluacion.dart';

/// Interface to allow swapping the real Firebase-backed service with fakes
abstract class IEvaluationService {
  Stream<List<Evaluacion>> getEvaluacionesStream();
  Future<List<Evaluacion>> getEvaluations();
  Future<void> addEvaluation(Evaluacion evaluacion);
  Future<void> updateEvaluation(
      Evaluacion oldEvaluation, Evaluacion newEvaluation);
  Future<void> toggleEvaluationStatus(String id, bool isDone);
  Future<void> deleteEvaluation(String id);
}

class EvaluationService implements IEvaluationService {
  final CollectionReference _evaluaciones =
      FirebaseFirestore.instance.collection('evaluaciones');

  @override
  Stream<List<Evaluacion>> getEvaluacionesStream() {
    return _evaluaciones.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Evaluacion.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  @override
  Future<List<Evaluacion>> getEvaluations() async {
    final snapshot = await _evaluaciones.get();
    return snapshot.docs
        .map((doc) =>
            Evaluacion.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  @override
  Future<String> addEvaluation(Evaluacion evaluacion) async {
    final docRef = await _evaluaciones.add(evaluacion.toMap());
    return docRef.id;
  }

  @override
  Future<void> updateEvaluation(
      Evaluacion oldEvaluation, Evaluacion newEvaluation) async {
    await _evaluaciones.doc(oldEvaluation.id).update(newEvaluation.toMap());
  }

  @override
  Future<void> toggleEvaluationStatus(String id, bool isDone) async {
    await _evaluaciones.doc(id).update({'isDone': isDone});
  }

  @override
  Future<void> deleteEvaluation(String id) async {
    await _evaluaciones.doc(id).delete();
  }

  /// Si la colección está vacía, insertar 5 evaluaciones de ejemplo.
  Future<void> seedIfEmpty() async {
    final snapshot = await _evaluaciones.limit(1).get();
    if (snapshot.docs.isEmpty) {
      final examples = <Evaluacion>[
        Evaluacion(
            title: 'Módulo 1: Fundamentos',
            note: 'Repasar capítulo 1',
            dueDate: DateTime.now().add(const Duration(days: 3))),
        Evaluacion(
            title: 'Módulo 2: Práctica',
            note: 'Entrega en grupos',
            dueDate: DateTime.now().add(const Duration(days: 7))),
        Evaluacion(
            title: 'Módulo 3: Examen parcial',
            note: null,
            dueDate: DateTime.now().subtract(const Duration(days: 2))),
        Evaluacion(
            title: 'Módulo 4: Proyecto', note: 'Subir repo', dueDate: null),
        Evaluacion(
            title: 'Módulo 5: Laboratorio',
            note: 'Traer equipo',
            dueDate: DateTime.now().add(const Duration(days: 14))),
      ];

      for (final ex in examples) {
        await _evaluaciones.add(ex.toMap());
      }
    }
  }
}
