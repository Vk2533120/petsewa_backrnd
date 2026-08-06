import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

enum LoginRole { customer, provider }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  LoginRole _selectedRole = LoginRole.customer;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final emailError = Validators.validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() => _errorMessage = emailError);
      return;
    }
    final passwordError = Validators.validatePassword(_passwordController.text);
    if (passwordError != null) {
      setState(() => _errorMessage = passwordError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null && mounted) {
        final supabase = Supabase.instance.client;
        final prefs = await SharedPreferences.getInstance();

        // Resolve the account's ACTUAL role from Supabase.
        // Priority: 'provider' metadata -> 'providers' table (authoritative,
        // overrides metadata corrupted to 'customer' by the old login bug
        // and self-heals it) -> 'customer' metadata -> 'profiles' table.
        final bool isProviderAccount = await _authService.resolveIsProvider(user);
        final bool wantsProvider = _selectedRole == LoginRole.provider;

        // Enforce role separation: the selected tab must match the account role.
        if (wantsProvider != isProviderAccount) {
          await supabase.auth.signOut();
          if (mounted) {
            setState(() {
              _errorMessage = isProviderAccount
                  ? 'This email is registered as a Service Provider account. Please switch to the "Service Provider" tab to login.'
                  : 'This email is registered as a Customer account. Please switch to the "Customer" tab to login.';
            });
          }
          return;
        }

        await prefs.remove('is_guest');
        await prefs.setBool('is_provider', isProviderAccount);

        // Backfill the role in metadata + database for legacy accounts.
        await _authService.persistUserRole(isProvider: isProviderAccount);

        if (!mounted) return;

        if (isProviderAccount) {
          String status = 'unsubmitted';
          try {
            final providerDoc = await supabase
                .from('providers')
                .select('status')
                .eq('user_id', user.id)
                .maybeSingle();
            if (providerDoc != null && providerDoc['status'] != null) {
              status = providerDoc['status'].toString().toLowerCase();
            }
          } catch (_) {}

          if (!mounted) return;

          if (status == 'approved' ||
              status == 'verified' ||
              prefs.getBool('provider_verified') == true) {
            await prefs.setBool('provider_verified', true);
            await prefs.setBool('provider_submitted', true);
            Navigator.pushReplacementNamed(context, '/provider-home');
          } else if (status == 'pending' ||
              prefs.getBool('provider_submitted') == true) {
            await prefs.setBool('provider_submitted', true);
            Navigator.pushReplacementNamed(context, '/provider-pending');
          } else {
            Navigator.pushReplacementNamed(context, '/provider-verification');
          }
        } else {
          bool hasProfile = prefs.getBool('has_pet_profile') ?? false;
          if (!hasProfile) {
            try {
              final petDoc = await supabase
                  .from('pets')
                  .select('id')
                  .eq('user_id', user.id)
                  .maybeSingle();
              if (petDoc != null) {
                hasProfile = true;
                await prefs.setBool('has_pet_profile', true);
              }
            } catch (_) {}
          }

          if (!mounted) return;

          if (hasProfile) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            Navigator.pushReplacementNamed(context, '/create-pet-profile');
          }
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSkipLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/create-pet-profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: _handleSkipLogin,
              child: const Row(
                children: [
                  Text(
                    'Skip Login',
                    style: TextStyle(
                      color: Color(0xFF354024),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF354024)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF354024).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pets, size: 54, color: Color(0xFF354024)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedRole == LoginRole.provider
                          ? 'Login to your Provider Account'
                          : 'Login to your Customer Account',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Role Selection Segmented Bar (Customer vs Service Provider)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = LoginRole.customer),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == LoginRole.customer
                                ? const Color(0xFF354024)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _selectedRole == LoginRole.customer
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF354024).withOpacity(0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 18,
                                color: _selectedRole == LoginRole.customer
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Customer',
                                style: TextStyle(
                                  color: _selectedRole == LoginRole.customer
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = LoginRole.provider),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == LoginRole.provider
                                ? const Color(0xFF354024)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _selectedRole == LoginRole.provider
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF354024).withOpacity(0.25),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.storefront_outlined,
                                size: 18,
                                color: _selectedRole == LoginRole.provider
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Service Provider',
                                style: TextStyle(
                                  color: _selectedRole == LoginRole.provider
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Error Banner
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF354024)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF354024), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF354024)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF354024), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF354024),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF354024).withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _selectedRole == LoginRole.provider
                            ? 'Login as Provider'
                            : 'Login as Customer',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 24),

              // Register Options
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_selectedRole == LoginRole.provider) {
                        Navigator.pushNamed(context, '/provider-service-select');
                      } else {
                        Navigator.pushNamed(context, '/register');
                      }
                    },
                    child: Text(
                      _selectedRole == LoginRole.provider ? 'Sign Up Provider' : 'Register',
                      style: const TextStyle(
                        color: Color(0xFF354024),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
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
