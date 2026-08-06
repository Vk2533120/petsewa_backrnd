import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String? phone;
  final bool isProvider;

  const OtpScreen({
    super.key,
    required this.email,
    this.phone,
    this.isProvider = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;
  int _secondsRemaining = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() async {
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });

    for (int i = 30; i > 0; i--) {
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _secondsRemaining = i - 1;
      });
    }

    if (mounted) {
      setState(() {
        _canResend = true;
      });
    }
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  Future<void> _completeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_provider', widget.isProvider);

    // Now that the email is verified and a session exists, persist the role
    // chosen at registration in Supabase metadata + database.
    await AuthService().persistUserRole(isProvider: widget.isProvider);

    if (!mounted) return;
    if (widget.isProvider) {
      Navigator.pushNamedAndRemoveUntil(context, '/provider-verification', (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/create-pet-profile', (route) => false);
    }
  }

  Future<void> _verifyEmailOtp() async {
    final code = _otpCode;
    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit OTP code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // Real Supabase Email OTP Verification Call
      await supabase.auth.verifyOTP(
        email: widget.email.trim(),
        token: code,
        type: OtpType.signup,
      );

      await _completeLogin();
    } on AuthException catch (e) {
      // Only proceed if the email is already confirmed and a session exists;
      // otherwise show the error instead of silently logging the user in.
      if (Supabase.instance.client.auth.currentSession != null) {
        await _completeLogin();
      } else {
        setState(() => _errorMessage = e.message);
      }
    } catch (e) {
      if (Supabase.instance.client.auth.currentSession != null) {
        await _completeLogin();
      } else {
        setState(() => _errorMessage = 'Verification failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendEmailOtp() async {
    if (!_canResend) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.resend(
        type: OtpType.signup,
        email: widget.email.trim(),
      );
      setState(() {
        _successMessage = 'Verification code/email resent to ${widget.email}!';
      });
      _startCountdown();
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to resend email. Please try again.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Email Icon Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF354024).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 64,
                    color: Color(0xFF354024),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Email Verification',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'Enter the 6-digit verification code or check the link sent to your email address:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
              ),
              const SizedBox(height: 6),
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF354024),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),

              // 6-digit Email OTP Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 44,
                    height: 54,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF354024), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_otpCode.length == 6) {
                          _verifyEmailOtp();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Success Message Box
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green.shade600, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(color: Colors.green.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Error Message Box
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Primary Button: Verify Email OTP
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyEmailOtp,
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
                    : const Text(
                        'Verify Email Code & Login',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 14),

              // Secondary Button: Resend Email Code
              Center(
                child: TextButton.icon(
                  onPressed: _canResend && !_isResending ? _resendEmailOtp : null,
                  icon: _isResending
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF354024)),
                        )
                      : Icon(
                          Icons.email_outlined,
                          size: 18,
                          color: _canResend ? const Color(0xFF354024) : Colors.grey,
                        ),
                  label: Text(
                    _canResend
                        ? 'Resend Email Verification'
                        : 'Resend Email in ${_secondsRemaining}s',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _canResend ? const Color(0xFF354024) : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back to Login
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
