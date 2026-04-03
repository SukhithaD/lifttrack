import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});
  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  String? _activeSplit;
  final List<Map<String, dynamic>> _exercises = [];
  bool _saving = false;
  List<String> _allExerciseNames = [];

  final List<String> _splitOptions = ['Push', 'Pull', 'Legs', 'Upper'];

  Future<void> _startWorkout(String split) async {
    // Load existing exercise names for autocomplete
    try {
      final names = await ApiService.getAllExercises();
      _allExerciseNames = List<String>.from(names);
    } catch (_) {
      _allExerciseNames = [];
    }
    setState(() {
      _activeSplit = split;
      _exercises.clear();
    });
    if (mounted) Navigator.pop(context);
  }

  void _showSplitPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("WHAT'S TODAY?", style: TextStyle(fontSize: 11, color: Color(0xFF555555), letterSpacing: 2, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ..._splitOptions.map((s) => GestureDetector(
              onTap: () => _startWorkout(s),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  border: Border.all(color: const Color(0xFF333333)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(s, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFE8E8E8))),
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _addExercise() {
    setState(() {
      _exercises.add({
        'nameController': TextEditingController(),
        'weightController': TextEditingController(),
        'setsController': TextEditingController(),
        'repsController': TextEditingController(),
      });
    });
  }

  Future<void> _finishSession() async {
    final valid = _exercises.where((e) {
      return (e['nameController'] as TextEditingController).text.isNotEmpty &&
             (e['weightController'] as TextEditingController).text.isNotEmpty;
    }).map((e) => {
      'name': (e['nameController'] as TextEditingController).text.trim(),
      'weight': double.tryParse((e['weightController'] as TextEditingController).text.replaceAll(',', '.')) ?? 0,
      if ((e['setsController'] as TextEditingController).text.isNotEmpty)
        'sets': int.tryParse((e['setsController'] as TextEditingController).text),
      if ((e['repsController'] as TextEditingController).text.isNotEmpty)
        'reps': int.tryParse((e['repsController'] as TextEditingController).text),
    }).toList();

    if (valid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise with a weight'), backgroundColor: Color(0xFF2A2A2A)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ApiService.saveSession(_activeSplit!, valid);
      setState(() { _activeSplit = null; _exercises.clear(); });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_activeSplit session saved'),
            backgroundColor: const Color(0xFF1E2A1E),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save — check connection'), backgroundColor: Color(0xFF2A1A1A)),
        );
      }
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_activeSplit == null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LOG', style: TextStyle(fontSize: 11, color: Color(0xFF444444), letterSpacing: 2, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Ready to\ntrain?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8), letterSpacing: -0.5, height: 1.1)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showSplitPicker,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18)),
                  child: const Text('START WORKOUT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_activeSplit!.toUpperCase(), style: const TextStyle(fontSize: 11, color: Color(0xFF555555), letterSpacing: 2, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Log exercises', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8), letterSpacing: -0.5)),
              ])),
              GestureDetector(
                onTap: () {
                  showDialog(context: context, builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    title: const Text('Discard session?', style: TextStyle(color: Color(0xFFE8E8E8), fontSize: 16)),
                    content: const Text('All exercises will be lost.', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep', style: TextStyle(color: Color(0xFFE8E8E8)))),
                      TextButton(
                        onPressed: () { Navigator.pop(context); setState(() { _activeSplit = null; _exercises.clear(); }); },
                        child: const Text('Discard', style: TextStyle(color: Color(0xFFF87171))),
                      ),
                    ],
                  ));
                },
                child: const Text('DISCARD', style: TextStyle(fontSize: 10, color: Color(0xFFF87171), letterSpacing: 1.5)),
              ),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              children: [
                ..._exercises.asMap().entries.map((entry) {
                  final i = entry.key;
                  final ex = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF202020),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text('EXERCISE ${i + 1}', style: const TextStyle(fontSize: 9, color: Color(0xFF555555), letterSpacing: 1.5)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _exercises.removeAt(i)),
                          child: const Icon(Icons.close, size: 16, color: Color(0xFF555555)),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      // Autocomplete exercise name field
                      Autocomplete<String>(
                        optionsBuilder: (textEditingValue) {
                          if (textEditingValue.text.isEmpty) return const [];
                          return _allExerciseNames.where((name) =>
                            name.toLowerCase().contains(textEditingValue.text.toLowerCase())
                          );
                        },
                        onSelected: (selected) {
                          (ex['nameController'] as TextEditingController).text = selected;
                        },
                        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                          // Sync with our stored controller
                          controller.text = (ex['nameController'] as TextEditingController).text;
                          controller.addListener(() {
                            (ex['nameController'] as TextEditingController).text = controller.text;
                          });
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            style: const TextStyle(fontSize: 14, color: Color(0xFFE8E8E8)),
                            decoration: const InputDecoration(
                              hintText: 'Exercise name',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            textCapitalization: TextCapitalization.words,
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(4),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 180, maxWidth: 280),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: options.length,
                                  itemBuilder: (_, index) {
                                    final option = options.elementAt(index);
                                    return InkWell(
                                      onTap: () => onSelected(option),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        child: Text(option, style: const TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _fieldInput('WEIGHT (KG)', ex['weightController'], keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                        const SizedBox(width: 8),
                        Expanded(child: _fieldInput('SETS', ex['setsController'], hint: 'optional')),
                        const SizedBox(width: 8),
                        Expanded(child: _fieldInput('REPS', ex['repsController'], hint: 'optional')),
                      ]),
                    ]),
                  );
                }),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _addExercise,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text('+ ADD EXERCISE', style: TextStyle(fontSize: 10, color: Color(0xFF555555), letterSpacing: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_exercises.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _finishSession,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _saving
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF111111)))
                          : const Text('FINISH SESSION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldInput(String label, TextEditingController controller, {String hint = '', TextInputType keyboardType = TextInputType.number}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 8, color: Color(0xFF555555), letterSpacing: 1)),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: Color(0xFFE8E8E8)),
        decoration: InputDecoration(
          hintText: hint.isEmpty ? '0' : hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
    ]);
  }
}
