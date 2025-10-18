// Compatibility shim: re-export Spanish model and provide English-compatible names
export 'evaluacion.dart';

import 'evaluacion.dart' as esp;

// Provide a simple alias so code that expects `Evaluation` can keep working.
class Evaluation extends esp.Evaluacion {
  Evaluation(
      {String? id,
      required String title,
      String? note,
      DateTime? dueDate,
      bool isDone = false})
      : super(
            id: id, title: title, note: note, dueDate: dueDate, isDone: isDone);

  bool get isPending => !isDone;
}
// TODO Implement this library.
