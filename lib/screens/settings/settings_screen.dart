import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _name = '';
  String _email = '';
  bool _notifications = true;
  bool _useKg = true;
  final List<String> _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<bool> _activeDays = [true, false, true, false, true, false, false];
  String _notifTime = '07:00';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('userName') ?? '';
      _email = prefs.getString('userEmail') ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFE8E8E8))),
              const SizedBox(height: 3),
              Text(_email, style: const TextStyle(fontSize: 9, color: Color(0xFF444444), letterSpacing: 1)),
            ])),
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFF222222), border: Border.all(color: const Color(0xFF333333)), borderRadius: BorderRadius.circular(4)),
              child: Center(child: Text(_name.isNotEmpty ? _name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8)))),
            ),
          ]),
          const SizedBox(height: 28),
          const Text('WORKOUT DAYS', style: TextStyle(fontSize: 9, color: Color(0xFF444444), letterSpacing: 2)),
          const SizedBox(height: 10),
          Row(children: List.generate(7, (i) => Expanded(child: GestureDetector(
            onTap: () => setState(() => _activeDays[i] = !_activeDays[i]),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _activeDays[i] ? const Color(0xFFE8E8E8) : const Color(0xFF1E1E1E),
                border: Border.all(color: _activeDays[i] ? Colors.transparent : const Color(0xFF2A2A2A)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(child: Text(_days[i], style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _activeDays[i] ? const Color(0xFF111111) : const Color(0xFF444444)))),
            ),
          )))),
          const SizedBox(height: 24),
          const Text('NOTIFICATION TIME', style: TextStyle(fontSize: 9, color: Color(0xFF444444), letterSpacing: 2)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 7, minute: 0));
              if (t != null) setState(() => _notifTime = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFF202020), border: Border.all(color: const Color(0xFF2A2A2A)), borderRadius: BorderRadius.circular(4)),
              child: Row(children: [
                const Expanded(child: Text('Remind me at', style: TextStyle(fontSize: 13, color: Color(0xFF888888)))),
                Text(_notifTime, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8), letterSpacing: 1)),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          const Text('PREFERENCES', style: TextStyle(fontSize: 9, color: Color(0xFF444444), letterSpacing: 2)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF202020), border: Border.all(color: const Color(0xFF2A2A2A)), borderRadius: BorderRadius.circular(4)),
            child: Column(children: [
              _prefRow('Kilograms', 'Weight unit', _useKg, (v) => setState(() => _useKg = v)),
              const Divider(height: 1, color: Color(0xFF2A2A2A)),
              _prefRow('Notifications', 'Daily reminders', _notifications, (v) => setState(() => _notifications = v)),
            ]),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFF3A1A1A)), borderRadius: BorderRadius.circular(4)),
              child: const Center(child: Text('LOG OUT', style: TextStyle(fontSize: 10, color: Color(0xFFF87171), letterSpacing: 2, fontWeight: FontWeight.w700))),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _prefRow(String label, String sub, bool val, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 8, color: Color(0xFF444444), letterSpacing: 1)),
        ])),
        Switch(value: val, onChanged: onChanged, activeColor: const Color(0xFFE8E8E8), activeTrackColor: const Color(0xFF444444), inactiveThumbColor: const Color(0xFF555555), inactiveTrackColor: const Color(0xFF222222)),
      ]),
    );
  }
}
