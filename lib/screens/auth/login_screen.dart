import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_nav.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.login(_emailController.text.trim(), _passwordController.text);
      if (res['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', res['token']);
        await prefs.setString('userName', res['user']['name']);
        await prefs.setString('userEmail', res['user']['email']);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNav()));
        }
      } else {
        setState(() { _error = res['error'] ?? 'Login failed'; });
      }
    } catch (e) {
      setState(() { _error = 'Connection error'; });
    }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              const Text('LiftTrack', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8), letterSpacing: -1)),
              const SizedBox(height: 6),
              const Text('TRACK SMARTER. LIFT HARDER.', style: TextStyle(fontSize: 9, color: Color(0xFF555555), letterSpacing: 2)),
              const Spacer(flex: 2),
              const Text('EMAIL', style: TextStyle(fontSize: 9, color: Color(0xFF555555), letterSpacing: 1.5)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 13, color: Color(0xFFE8E8E8)),
                decoration: const InputDecoration(hintText: 'you@email.com'),
              ),
              const SizedBox(height: 16),
              const Text('PASSWORD', style: TextStyle(fontSize: 9, color: Color(0xFF555555), letterSpacing: 1.5)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(fontSize: 13, color: Color(0xFFE8E8E8)),
                decoration: const InputDecoration(hintText: '••••••••'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(fontSize: 10, color: Color(0xFFF87171))),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF111111))) : const Text('SIGN IN'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE8E8E8),
                    side: const BorderSide(color: Color(0xFF333333)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 11, letterSpacing: 1.5)),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
