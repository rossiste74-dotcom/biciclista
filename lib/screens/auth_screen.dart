import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:biciclistico/screens/onboarding_screen.dart';
import 'package:biciclistico/screens/main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final supabase = Supabase.instance.client;

    try {
      if (_isLogin) {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        await supabase.auth.signUp(
          email: email,
          password: password,
        );
      }

      if (mounted) {
        final user = supabase.auth.currentUser;
        if (user != null) {
          // Check if profile exists
          final data = await supabase
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          if (mounted) {
            if (data == null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              );
            }
          }
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Assuming you have an icon asset
              Image.asset('assets/icon.png', height: 100, errorBuilder: (_,__,___) => const Icon(Icons.directions_bike, size: 100)),
              const SizedBox(height: 32),
              Text(
                _isLogin ? 'Bentornato!' : 'Crea Account',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Text(_isLogin ? 'Accedi' : 'Registrati'),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin
                          ? 'Non hai un account? Registrati'
                          : 'Hai già un account? Accedi'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
