import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _occupationController = TextEditingController();
  DateTime? _birthDate;
  bool _isLogin = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _show('Please fill in email and password');
      return;
    }

    if (!_isLogin) {
      if (_nameController.text.trim().isEmpty ||
          _birthDate == null ||
          _occupationController.text.trim().isEmpty) {
        _show('Please fill in all profile fields');
        return;
      }
    }

    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      if (_isLogin) {
        await supabase.auth.signInWithPassword(email: email, password: password);
      } else {
        final res = await supabase.auth.signUp(
          email: email,
          password: password,
          // 💾 Extra profile info saved to the Supabase account
          data: {
            'full_name': _nameController.text.trim(),
            'date_of_birth': DateFormat('yyyy-MM-dd').format(_birthDate!),
            'occupation': _occupationController.text.trim(),
          },
        );
        if (res.session == null) {
          _show('Account created! Check your email to confirm.');
        }
      }
    } catch (e) {
      _show('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _textField(AppThemeExtension ext, TextEditingController controller,
      String hint,
      {bool obscure = false, TextInputType? keyboard, IconData? icon}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: TextStyle(color: ext.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: ext.textTertiary),
        prefixIcon: icon != null ? Icon(icon, color: ext.textTertiary, size: 20) : null,
        filled: true,
        fillColor: ext.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: ext.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🎯 YOUR REAL APP ICON
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset('assets/icon/icon.png', width: 96, height: 96),
              ),
              const SizedBox(height: 16),
              Text('Tempo',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ext.textPrimary)),
              const SizedBox(height: 8),
              Text(
                _isLogin
                    ? 'Sign in to see your saved tasks'
                    : 'Create an account to save your tasks',
                style: TextStyle(fontSize: 14, color: ext.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              _textField(ext, _emailController, 'Email',
                  keyboard: TextInputType.emailAddress, icon: Icons.mail_outline),
              const SizedBox(height: 12),
              _textField(ext, _passwordController, 'Password',
                  obscure: true, icon: Icons.lock_outline),
              const SizedBox(height: 12),

              // 📝 Extra fields only when creating an account
              if (!_isLogin) ...[
                _textField(ext, _nameController, 'Full name',
                    icon: Icons.person_outline),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickBirthDate,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: ext.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cake_outlined, color: ext.textTertiary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _birthDate == null
                              ? 'Date of birth'
                              : DateFormat('dd MMM yyyy').format(_birthDate!),
                          style: TextStyle(
                            fontSize: 15,
                            color: _birthDate == null
                                ? ext.textTertiary
                                : ext.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _textField(ext, _occupationController, 'Occupation (e.g. Student)',
                    icon: Icons.work_outline),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isLogin ? 'Sign In' : 'Create Account',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? 'No account? Create one' : 'Have an account? Sign in',
                  style: TextStyle(color: primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}