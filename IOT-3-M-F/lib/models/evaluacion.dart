import 'package:cloud_firestore/cloud_firestore.dart';

class Evaluacion {
  final String id;
  final String title;
  final String? note;
  final DateTime? dueDate;
  final bool isDone;

  Evaluacion({
    String? id,
    required this.title,
    this.note,
    this.dueDate,
    this.isDone = false,
  }) : id = id ?? '';

  bool get isOverdue {
    if (dueDate == null || isDone) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  factory Evaluacion.fromMap(Map<String, dynamic> data, String id) {
    return Evaluacion(
      id: id,
      title: data['title'] ?? '',
      note: data['note'],
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      isDone: data['isDone'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'note': note,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isDone': isDone,
    };
  }
}
