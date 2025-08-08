import 'package:dukoavote/src/core/core.dart';
import 'package:dukoavote/src/features/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/poll.dart';
import '../providers/poll_providers.dart';
import 'package:dukoavote/src/core/ui/feedback_service.dart';
import 'package:dukoavote/src/features/auth/presentation/providers/auth_provider.dart';

class CreatePollPage extends ConsumerStatefulWidget {
  const CreatePollPage({super.key});

  @override
  ConsumerState<CreatePollPage> createState() => _CreatePollPageState();
}

class _CreatePollPageState extends ConsumerState<CreatePollPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  static const int _maxOptions = 5;
  
  @override
  void initState() {
    super.initState();
    // Écouter les changements d'état pour détecter le succès
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen(createPollNotifierProvider, (previous, next) {
        next.whenData((result) {
          result.fold(
            (failure) {
              // Erreur déjà gérée dans le widget
            },
            (_) {
              // Succès - afficher le message et naviguer
              if (mounted) {
                FeedbackService.showSuccess(context, 'Sondage créé avec succès !');
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (mounted) {
                    context.go('/home');
                    ref.invalidate(pollsProvider);
                  }
                });
              }
            },
          );
        });
      });
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < _maxOptions) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers.removeAt(index);
      });
    }
  }

  DateTime? _combineDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String? _validateOptions() {
    final filled = _optionControllers.where((c) => c.text.trim().isNotEmpty).length;
    if (filled < 2) return 'Au moins 2 options requises';
    return null;
  }

  String? _validateDates() {
    final start = _combineDateTime(_startDate, _startTime);
    final end = _combineDateTime(_endDate, _endTime);
    if (start == null || end == null) return 'Dates requises';
    if (!end.isAfter(start)) return 'La fin doit être après le début';
    return null;
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;
    setState(() {
      if (isStart) {
        _startDate = pickedDate;
        _startTime = pickedTime;
      } else {
        _endDate = pickedDate;
        _endTime = pickedTime;
      }
    });
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return '';
    final d = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} à ${time.format(context)}';
  }

  @override
  Widget build(BuildContext context) {
    final createPollState = ref.watch(createPollNotifierProvider);
    final authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un sondage'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Section Question avec design amélioré
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre de section avec icône
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.quiz,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Votre question',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Champ de saisie amélioré
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _questionController,
                            maxLines: 3,
                            minLines: 2,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Ex: Quel est votre plat préféré ?',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.red[300]!,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.red[400]!,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              prefixIcon: Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.help_outline,
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
                                  size: 24,
                                ),
                              ),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
                          ),
                        ),
                        // Indicateur de caractères
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            '${_questionController.text.length} caractères',
                            style: TextStyle(
                              fontSize: 12,
                              color: _questionController.text.length > 100 
                                ? Colors.orange[600] 
                                : Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._optionControllers.asMap().entries.map((entry) {
                    final i = entry.key;
                    final c = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: c,
                              decoration: InputDecoration(
                                labelText: 'Option ${i + 1}',
                                prefixIcon: const Icon(Icons.circle_outlined, size: 18),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_optionControllers.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removeOption(i),
                              tooltip: 'Supprimer',
                            ),
                        ],
                      ),
                    );
                  }),
                  if (_optionControllers.length < _maxOptions)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addOption,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter une option'),
                      ),
                    ),
                  if (_validateOptions() != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(_validateOptions()!, style: const TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(_startDate == null || _startTime == null
                        ? 'Date et heure de début'
                        : 'Début : ${_formatDateTime(_startDate, _startTime)}'),
                    onTap: () => _pickDateTime(isStart: true),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(_endDate == null || _endTime == null
                        ? 'Date et heure de fin'
                        : 'Fin : ${_formatDateTime(_endDate, _endTime)}'),
                    onTap: () => _pickDateTime(isStart: false),
                  ),
                  if (_validateDates() != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(_validateDates()!, style: const TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: createPollState.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() != true) return;
                            final start = _combineDateTime(_startDate, _startTime) ?? DateTime.now();
                            final end = _combineDateTime(_endDate, _endTime) ?? DateTime.now().add(const Duration(days: 1));
                            // Utiliser l'ID de l'utilisateur
                            final userCreatedBy = authState.user?.id;
                            
                            // Debug: afficher les informations de l'utilisateur
                            AppLogger.d('Création de sondage - User ID: ${authState.user?.id}');
                            AppLogger.d('Création de sondage - User Email: ${authState.user?.email}');
                            
                            if (userCreatedBy == null || userCreatedBy.isEmpty) {
                              FeedbackService.showError(context, 'Erreur: Utilisateur non connecté');
                              return;
                            }
                            
                            final poll = Poll(
                              question: _questionController.text.trim(),
                              options: _optionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
                              startDate: start,
                              endDate: end,
                              isClosed: false,
                              createdBy: userCreatedBy,
                            );
                            await ref.read(createPollNotifierProvider.notifier).submit(poll);
                          },
                    child: createPollState.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Créer le sondage'),
                  ),
                  // Gestion des erreurs et succès
                  createPollState.when(
                    data: (result) => result.fold(
                      (failure) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          failure.message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      (_) => const SizedBox.shrink(),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        error.toString(),
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 