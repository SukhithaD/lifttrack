import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../widgets/bottom_nav.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.register(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text);
      if (res['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', res['token']);
        await prefs.setString('userName', res['user']['name']);
        await prefs.setString('userEmail', res['user']['email']);
        if (mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainNav()), (_) => false);
        }
      } else {
        setState(() { _error = res['error'] ?? 'Registration failed'; });
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
              const Spacer(flex: 1),
              const Text('Create\naccount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8), letterSpacing: -1, height: 1.1)),
              const SizedBox(height: 6),
              const Text('START TRACKING YOUR LIFTS', style: TextStyle(fontSize: 9, color: Color(0xFF555555), letterSpacing: 2)),
              const Spacer(flex: 1),
              const Text('NAME', style: TextStyle(fontSize: 9, color: Color(0xFF555555), letterSpacing: 1.5)),
              const SizedBox(height: 6),
              TextField(controller: _nameController, style: const TextStyle(fontSize: 13, color: Color(0xFFE8E8E8)), decoration: const InputDecoration(hintText: 'Your name')),
              const SizedBox(height: 16),
              const Text('EMAIL', style: TextStyle(fontSize: 9, color: Color(0xFF555555), letterSpacing: 1.5)),
              const SizedBox(height: 6),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, style: const TextStyle(fontSize: 13, color: Color(0xFFE8E8E8)), decoration: const InputDecoration(hintText: 'you@email.com')),
              const SizedBox(height: 16),
              const Text('PASSWORD', style: TextStyle(fontSize: 9, color: Color(0xFF555555), letterSpacing: 1.5)),
              const SizedBox(height: 6),
              TextField(controller: _passwordController, obscureText: true, style: const TextStyle(fontSize: 13, color: Color(0xFFE8E8E8)), decoration: const InputDecoration(hintText: 'Min. 8 characters')),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(fontSize: 10, color: Color(0xFFF87171))),
              ],
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF111111))) : const Text('CREATE ACCOUNT'))),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('HAVE AN ACCOUNT? SIGN IN', style: TextStyle(fontSize: 9, color: Color(0xFF555555), letterSpacing: 1)),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
