import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _sessions = [];
  String _userName = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userName = prefs.getString('userName') ?? '');
    try {
      final sessions = await ApiService.getSessions();
      setState(() { _sessions = sessions; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<dynamic> get _thisWeekSessions {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return _sessions.where((s) {
      final d = DateTime.parse(s['createdAt']).toLocal();
      return d.isAfter(weekStart.subtract(const Duration(seconds: 1)));
    }).toList();
  }

  String get _todaySplit {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final todaySession = _sessions.where((s) {
      final d = DateTime.parse(s['createdAt']).toLocal();
      return DateTime(d.year, d.month, d.day) == todayDate;
    }).toList();
    if (todaySession.isNotEmpty) return todaySession.first['splitDay'] ?? 'Rest day';
    return 'Rest day';
  }

  String get _lastLift {
    if (_sessions.isEmpty) return '—';
    final last = DateTime.parse(_sessions[0]['createdAt']).toLocal();
    final diff = DateTime.now().difference(last).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return '1d ago';
    return '${diff}d ago';
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  String _dayLabel(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final weekSessions = _thisWeekSessions;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8E8E8)))
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFFE8E8E8),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                children: [
                  Text(
                    _todaySplit == 'Rest day' ? 'REST DAY' : _todaySplit.toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Color(0xFF555555), letterSpacing: 2, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Good $_greeting,\n$_userName.',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8), letterSpacing: -0.5, height: 1.15),
                  ),
                  const SizedBox(height: 28),
                  Row(children: [
                    _statCard(weekSessions.length.toString().padLeft(2, '0'), 'THIS WEEK'),
                    const SizedBox(width: 10),
                    _statCard(_lastLift, 'LAST LIFT'),
                    const SizedBox(width: 10),
                    _statCard(_sessions.length.toString(), 'TOTAL'),
                  ]),
                  const SizedBox(height: 28),
                  const Text('THIS WEEK', style: TextStyle(fontSize: 9, color: Color(0xFF444444), letterSpacing: 2, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  if (weekSessions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('No sessions logged this week yet', style: TextStyle(fontSize: 12, color: Color(0xFF444444))),
                      ),
                    )
                  else
                    ...weekSessions.map((s) {
                      final date = DateTime.parse(s['createdAt']).toLocal();
                      final isToday = DateTime(date.year, date.month, date.day) == today;
                      final splitDay = s['splitDay'] ?? '—';
                      final exerciseCount = (s['exercises'] as List?)?.length ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF202020),
                          border: Border.all(color: isToday ? const Color(0xFF555555) : const Color(0xFF2A2A2A)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(children: [
                          Text(_dayLabel(date.weekday), style: TextStyle(fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w600, color: isToday ? const Color(0xFFE8E8E8) : const Color(0xFF555555))),
                          const SizedBox(width: 16),
                          Expanded(child: Text(splitDay, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isToday ? const Color(0xFFE8E8E8) : const Color(0xFF888888)))),
                          Text('$exerciseCount exercises', style: const TextStyle(fontSize: 9, color: Color(0xFF444444))),
                          const SizedBox(width: 12),
                          const Text('DONE', style: TextStyle(fontSize: 9, color: Color(0xFF6EE7B7), letterSpacing: 1, fontWeight: FontWeight.w600)),
                        ]),
                      );
                    }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          border: Border.all(color: const Color(0xFF2A2A2A)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 8, color: Color(0xFF444444), letterSpacing: 1)),
        ]),
      ),
    );
  }
}
