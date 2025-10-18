import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../services/evaluation_service.dart';
import '../models/evaluacion.dart';
import '../services/auth_service.dart';

class EvaluationsScreen extends StatefulWidget {
  final IEvaluationService? evaluationService;
  final IAuthService? authService;

  const EvaluationsScreen(
      {super.key, this.evaluationService, this.authService});

  @override
  State<EvaluationsScreen> createState() => _EvaluationsScreenState();
}

class _EvaluationsScreenState extends State<EvaluationsScreen> {
  late final IEvaluationService _evaluationService;
  late final IAuthService _authService;
  List<Evaluacion> _evaluations = [];
  String _searchQuery = '';
  String _filter = 'todas';
  @override
  void initState() {
    super.initState();
    _evaluationService = widget.evaluationService ?? EvaluationService();
    _authService = widget.authService ?? AuthService();

    _evaluationService.getEvaluacionesStream().listen((list) {
      if (mounted) setState(() => _evaluations = list);
    });
  }

  List<Evaluacion> get _filteredEvaluations {
    return _evaluations.where((e) {
      final matchesSearch = e.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (e.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      switch (_filter) {
        case 'pendientes':
          return matchesSearch && !e.isDone;
        case 'completas':
          return matchesSearch && e.isDone;
        default:
          return matchesSearch;
      }
    }).toList()
      ..sort((a, b) {
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
  }

  void _showCreateDialog() {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nueva Evaluación',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  selectedDate = date;
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('Seleccionar fecha (opcional)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El título es obligatorio')),
                  );
                  return;
                }
                _evaluationService.addEvaluation(
                  Evaluacion(
                    title: titleController.text,
                    note: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                    dueDate: selectedDate,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Crear'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluaciones'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar cierre de sesión'),
                  content:
                      const Text('¿Estás seguro de que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              );
              if (result != true) return;
              await _authService.signOut();
              if (!mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar evaluaciones...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Todas'),
                  selected: _filter == 'todas',
                  onSelected: (selected) => setState(() => _filter = 'todas'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pendientes'),
                  selected: _filter == 'pendientes',
                  onSelected: (selected) =>
                      setState(() => _filter = 'pendientes'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Completas'),
                  selected: _filter == 'completas',
                  onSelected: (selected) =>
                      setState(() => _filter = 'completas'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredEvaluations.length,
              itemBuilder: (context, index) {
                final evaluation = _filteredEvaluations[index];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          // Eliminar permanentemente en Firestore
                          try {
                            final messenger = ScaffoldMessenger.of(context);
                            await _evaluationService
                                .deleteEvaluation(evaluation.id);
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: const Text('Evaluación eliminada'),
                                action: SnackBarAction(
                                  label: 'Deshacer',
                                  onPressed: () async {
                                    // Re-crear la evaluación en la BD
                                    await _evaluationService.addEvaluation(
                                      Evaluacion(
                                        title: evaluation.title,
                                        note: evaluation.note,
                                        dueDate: evaluation.dueDate,
                                        isDone: evaluation.isDone,
                                      ),
                                    );
                                    if (!mounted) return;
                                  },
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                              SnackBar(content: Text('Error al eliminar: $e')),
                            );
                          }
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Eliminar',
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Tooltip(
                      message: evaluation.isDone
                          ? 'Marcar como pendiente'
                          : 'Marcar como completada',
                      child: Checkbox(
                        value: evaluation.isDone,
                        onChanged: (value) {
                          if (value != null) {
                            _evaluationService.toggleEvaluationStatus(
                                evaluation.id, value);
                          }
                        },
                      ),
                    ),
                    title: Text(
                      evaluation.title,
                      style: TextStyle(
                        decoration: evaluation.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (evaluation.note != null) Text(evaluation.note!),
                        if (evaluation.dueDate != null)
                          Text(
                            DateFormat('dd/MM/yyyy')
                                .format(evaluation.dueDate!),
                            style: TextStyle(
                              color: evaluation.isOverdue ? Colors.red : null,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (evaluation.isOverdue)
                          const Tooltip(
                            message: 'Evaluación vencida',
                            child: Icon(Icons.warning, color: Colors.orange),
                          ),
                        // Editar deshabilitado por requisitos (no permitir edición desde UI)
                        IconButton(
                          icon: Icon(Icons.delete,
                              color: Theme.of(context).colorScheme.primary),
                          tooltip: 'Eliminar evaluación',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar eliminación'),
                                content: const Text(
                                    '¿Estás seguro de que deseas eliminar esta evaluación?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      try {
                                        await _evaluationService
                                            .deleteEvaluation(evaluation.id);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                'Evaluación eliminada'),
                                            action: SnackBarAction(
                                              label: 'Deshacer',
                                              onPressed: () async {
                                                await _evaluationService
                                                    .addEvaluation(
                                                  Evaluacion(
                                                    title: evaluation.title,
                                                    note: evaluation.note,
                                                    dueDate: evaluation.dueDate,
                                                    isDone: evaluation.isDone,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error al eliminar: $e')),
                                        );
                                      }
                                    },
                                    child: const Text('Eliminar',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        tooltip: 'Agregar nueva evaluación',
        child: const Icon(Icons.add),
      ),
    );
  }
}
