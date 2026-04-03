import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/prefs_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> _exercises = [];
  Map<String, List<dynamic>> _history = {};
  bool _loading = true;
  bool _useKg = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final useKg = await PrefsService.getUseKg();
    try {
      final names = await ApiService.getAllExercises();
      final history = <String, List<dynamic>>{};
      for (final name in names) {
        history[name] = await ApiService.getExerciseHistory(name);
      }
      setState(() {
        _exercises = List<String>.from(names);
        _history = history;
        _useKg = useKg;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _displayWeight(num kg) => PrefsService.formatWeight(kg.toDouble(), _useKg);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8E8E8)))
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFE8E8E8),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                children: [
                  const Text('PROGRESS', style: TextStyle(fontSize: 9, color: Color(0xFF444444), letterSpacing: 2, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('History', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8), letterSpacing: -0.5)),
                  const SizedBox(height: 24),
                  if (_exercises.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Text('No sessions logged yet', style: TextStyle(fontSize: 11, color: Color(0xFF444444))),
                      ),
                    ),
                  ..._exercises.map((name) {
                    final logs = _history[name] ?? [];
                    if (logs.isEmpty) return const SizedBox.shrink();
                    final latestKg = (logs[0]['weight'] as num).toDouble();
                    final oldestKg = (logs.last['weight'] as num).toDouble();
                    final deltaKg = latestKg - oldestKg;
                    final deltaDisplay = _useKg ? deltaKg : PrefsService.kgToLbs(deltaKg);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF202020),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFE8E8E8))),
                              const SizedBox(height: 3),
                              Text('${logs.length} ${logs.length == 1 ? 'SESSION' : 'SESSIONS'}',
                                style: const TextStyle(fontSize: 9, color: Color(0xFF444444), letterSpacing: 1)),
                            ])),
                            Text(
                              deltaDisplay >= 0
                                ? '+${deltaDisplay.toStringAsFixed(1)}${_useKg ? 'kg' : 'lbs'}'
                                : '${deltaDisplay.toStringAsFixed(1)}${_useKg ? 'kg' : 'lbs'}',
                              style: TextStyle(fontSize: 11, color: deltaDisplay >= 0 ? const Color(0xFF6EE7B7) : const Color(0xFFF87171)),
                            ),
                          ]),
                        ),
                        const Divider(height: 1, color: Color(0xFF2A2A2A)),
                        ...logs.take(4).map((log) {
                          final date = DateTime.parse(log['createdAt']).toLocal();
                          final idx = logs.indexOf(log);
                          final currKg = (log['weight'] as num).toDouble();
                          final prevKg = idx < logs.length - 1 ? (logs[idx + 1]['weight'] as num).toDouble() : currKg;
                          final dKg = currKg - prevKg;
                          final dDisplay = _useKg ? dKg : PrefsService.kgToLbs(dKg);
                          final splitDay = log['splitDay'] ?? '—';

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF252525)))),
                            child: Row(children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('${date.day} ${_month(date.month)} ${date.year}',
                                  style: const TextStyle(fontSize: 9, color: Color(0xFF555555))),
                                const SizedBox(height: 2),
                                Text(splitDay, style: const TextStyle(fontSize: 8, color: Color(0xFF444444), letterSpacing: 0.5)),
                              ])),
                              Text(_displayWeight(log['weight'] as num),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8))),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 42,
                                child: Text(
                                  idx == logs.length - 1 ? '—'
                                    : dDisplay >= 0 ? '+${dDisplay.toStringAsFixed(1)}'
                                    : dDisplay.toStringAsFixed(1),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 9, color: dDisplay > 0 ? const Color(0xFF6EE7B7) : dDisplay < 0 ? const Color(0xFFF87171) : const Color(0xFF444444)),
                                ),
                              ),
                            ]),
                          );
                        }),
                      ]),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  String _month(int m) => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m-1];
}
