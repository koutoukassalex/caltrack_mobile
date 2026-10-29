import 'package:flutter/material.dart';
import '../../models/exercise_entry.dart';
import '../../models/user_profile.dart';
import '../../services/ai_service.dart';

class AddExerciseModal extends StatefulWidget {
  final UserProfile profile;
  final Function(ExerciseEntry) onAddExercise;

  const AddExerciseModal({
    super.key,
    required this.profile,
    required this.onAddExercise,
  });

  @override
  State<AddExerciseModal> createState() => _AddExerciseModalState();
}

class _AddExerciseModalState extends State<AddExerciseModal> {
  final _nameController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _caloriesController = TextEditingController();
  bool _isEstimating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _estimateCalories() async {
    final activity = _nameController.text.trim();
    final duration = int.tryParse(_durationController.text) ?? 30;

    if (activity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an activity name first')),
      );
      return;
    }

    setState(() => _isEstimating = true);
    try {
      final burned = await AIService.estimateExerciseCalories(
        activityName: activity,
        durationMinutes: duration,
        userWeightKg: widget.profile.weightKg,
        profile: widget.profile,
      );
      _caloriesController.text = burned.round().toString();
    } catch (_) {
      // Fallback
      _caloriesController.text = (duration * 6).toString();
    } finally {
      if (mounted) setState(() => _isEstimating = false);
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final duration = int.tryParse(_durationController.text) ?? 0;
    final calories = double.tryParse(_caloriesController.text) ?? 0.0;

    if (name.isEmpty || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid exercise details')),
      );
      return;
    }

    final entry = ExerciseEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      durationMinutes: duration,
      caloriesBurned: calories,
    );

    widget.onAddExercise(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🏃', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    'Log Exercise',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Activity Name',
              hintText: 'e.g. HIIT Workout, Running, Cycling',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (min)',
                    hintText: '30',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Burned (kcal)',
                    hintText: '220',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isEstimating ? null : _estimateCalories,
              icon: _isEstimating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(_isEstimating
                  ? 'Calculating with AI...'
                  : '✨ Estimate Calories with AI'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: const Text('Add Exercise to Log'),
            ),
          ),
        ],
      ),
    );
  }
}
