import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/prefs_service.dart';
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
  List<bool> _activeDays = [true, true, true, false, true, true, false];
  String _notifTime = '07:00';
  bool _loading = true;

  final List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final days = await PrefsService.getWorkoutDays();
    final notifTime = await PrefsService.getNotifTime();
    final useKg = await PrefsService.getUseKg();
    final notifEnabled = await PrefsService.getNotificationsEnabled();
    setState(() {
      _name = prefs.getString('userName') ?? '';
      _email = prefs.getString('userEmail') ?? '';
      _activeDays = days;
      _notifTime = notifTime;
      _useKg = useKg;
      _notifications = notifEnabled;
      _loading = false;
    });
  }

  Future<void> _toggleDay(int i) async {
    setState(() => _activeDays[i] = !_activeDays[i]);
    await PrefsService.setWorkoutDays(_activeDays);
  }

  Future<void> _toggleUseKg(bool val) async {
    setState(() => _useKg = val);
    await PrefsService.setUseKg(val);
  }

  Future<void> _toggleNotifications(bool val) async {
    setState(() => _notifications = val);
    await PrefsService.setNotificationsEnabled(val);
  }

  Future<void> _pickTime() async {
    final parts = _notifTime.split(':');
    final initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final t = await showTimePicker(context: context, initialTime: initial);
    if (t != null) {
      final formatted = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      setState(() => _notifTime = formatted);
      await PrefsService.setNotifTime(formatted);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFFE8E8E8)));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // Profile row
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                border: Border.all(color: const Color(0xFF333333)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(child: Text(
                _name.isNotEmpty ? _name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8)),
              )),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFE8E8E8))),
              const SizedBox(height: 3),
              Text(_email, style: const TextStyle(fontSize: 10, color: Color(0xFF444444), letterSpacing: 0.5)),
            ])),
          ]),

          const SizedBox(height: 32),
          const Text('WORKOUT DAYS', style: TextStyle(fontSize: 9, color: Color(0xFF444444), letterSpacing: 2, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Select the days you usually train', style: TextStyle(fontSize: 11, color: Color(0xFF555555))),
          const SizedBox(height: 12),
          Row(children: List.generate(7, (i) => Expanded(
            child: GestureDetector(
              onTap: () => _toggleDay(i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: _activeDays[i] ? const Color(0xFFE8E8E8) : const Color(0xFF1E1E1E),
                  border: Border.all(color: _activeDays[i] ? Colors.transparent : const Color(0xFF2A2A2A)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(child: Text(
                  _dayLabels[i],
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _activeDays[i] ? const Color(0xFF111111) : const Color(0xFF444444)),
                )),
              ),
            ),
          ))),

          const SizedBox(height: 28),
          const Text('NOTIFICATIONS', style: TextStyle(fontSize: 9, color: Color(0xFF444444), letterSpacing: 2, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF202020),
              border: Border.all(color: const Color(0xFF2A2A2A)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(children: [
              _prefRow('Daily reminders', 'Get notified on your workout days', _notifications, _toggleNotifications),
              const Divider(height: 1, color: Color(0xFF2A2A2A)),
              GestureDetector(
                onTap: _pickTime,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Remind me at', style: TextStyle(fontSize: 13, color: Color(0xFFE8E8E8))),
                      const SizedBox(height: 2),
                      const Text('TAP TO CHANGE', style: TextStyle(fontSize: 8, color: Color(0xFF444444), letterSpacing: 1)),
                    ])),
                    Text(_notifTime, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8), letterSpacing: 1)),
                  ]),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 28),
          const Text('PREFERENCES', style: TextStyle(fontSize: 9, color: Color(0xFF444444), letterSpacing: 2, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF202020),
              border: Border.all(color: const Color(0xFF2A2A2A)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _prefRow(
              'Use kilograms',
              _useKg ? 'Showing weights in kg' : 'Showing weights in lbs',
              _useKg,
              _toggleUseKg,
            ),
          ),

          const SizedBox(height: 32),
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF3A1A1A)),
                borderRadius: BorderRadius.circular(4),
              ),
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
