import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> _exercises = [];
  Map<String, List<dynamic>> _history = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final names = await ApiService.getAllExercises();
      final history = <String, List<dynamic>>{};
      for (final name in names) {
        history[name] = await ApiService.getExerciseHistory(name);
      }
      setState(() {
        _exercises = List<String>.from(names);
        _history = history;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

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
                    final latest = logs[0]['weight'] as num;
                    final oldest = logs.last['weight'] as num;
                    final delta = latest - oldest;
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
                              delta >= 0 ? '+${delta.toStringAsFixed(1)}kg' : '${delta.toStringAsFixed(1)}kg',
                              style: TextStyle(fontSize: 11, color: delta >= 0 ? const Color(0xFF6EE7B7) : const Color(0xFFF87171)),
                            ),
                          ]),
                        ),
                        const Divider(height: 1, color: Color(0xFF2A2A2A)),
                        ...logs.take(4).map((log) {
                          final date = DateTime.parse(log['createdAt']).toLocal();
                          final idx = logs.indexOf(log);
                          final prev = idx < logs.length - 1 ? logs[idx + 1]['weight'] as num : log['weight'] as num;
                          final d = (log['weight'] as num) - prev;
                          final splitDay = log['splitDay'] ?? '—';
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFF252525))),
                            ),
                            child: Row(children: [
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('${date.day} ${_month(date.month)} ${date.year}',
                                    style: const TextStyle(fontSize: 9, color: Color(0xFF555555))),
                                  const SizedBox(height: 2),
                                  Text(splitDay,
                                    style: const TextStyle(fontSize: 8, color: Color(0xFF444444), letterSpacing: 0.5)),
                                ]),
                              ),
                              Text('${log['weight']}kg',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8))),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 36,
                                child: Text(
                                  idx == logs.length - 1 ? '—' : d >= 0 ? '+${d.toStringAsFixed(1)}' : d.toStringAsFixed(1),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 9, color: d > 0 ? const Color(0xFF6EE7B7) : d < 0 ? const Color(0xFFF87171) : const Color(0xFF444444)),
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
