import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  static const String roleProvider = 'provider';
  static const String roleCustomer = 'customer';

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Stream of auth state
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Email & Password - Sign In
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return response.user;
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw Exception('Incorrect email or password.');
      } else if (e.message.contains('Email not confirmed')) {
        throw Exception('Please confirm your email first.');
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      throw Exception('Login failed. Check your internet connection.');
    }
  }

  // Email & Password - Register
  Future<AuthResponse> registerWithEmail(
    String email,
    String password,
    String name, {
    bool isProvider = false,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {
          'full_name': name.trim(),
          'is_provider': isProvider,
          'role': isProvider ? roleProvider : roleCustomer,
        },
      );

      // Supabase returns an empty identities array if the email is already registered
      if (response.user != null && response.user!.identities != null && response.user!.identities!.isEmpty) {
        throw Exception('This email is already registered. Please login instead.');
      }

      // If email auto-confirm is enabled a session already exists, so the role
      // can be persisted to the database right away. Otherwise the OTP screen
      // persists it right after the email is verified.
      if (response.session != null) {
        await persistUserRole(isProvider: isProvider, fullName: name);
      }

      return response;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') || msg.contains('already exists') || msg.contains('user_already_exists')) {
        throw Exception('This email is already registered. Please login instead.');
      } else if (msg.contains('password')) {
        throw Exception('Password must be at least 6 characters.');
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      if (e.toString().contains('already registered')) {
        rethrow;
      }
      throw Exception('Registration failed. Check your internet connection.');
    }
  }

  // Pure role decision based on auth user metadata alone.
  // Returns null when the metadata carries no role information
  // (e.g. legacy accounts created before roles were introduced).
  static bool? isProviderFromMetadata(Map<String, dynamic>? metadata) {
    final data = metadata ?? {};
    final dynamic rawIsProvider = data['is_provider'];
    final dynamic rawRole = data['role'];

    if (rawIsProvider == true || rawRole == roleProvider) return true;
    if (rawIsProvider == false || rawRole == roleCustomer) return false;
    return null;
  }

  // Pure decision combining the two strongest role signals.
  // A row in the 'providers' table is authoritative proof of a provider
  // account: it is only created when a provider submits verification, so it
  // overrides metadata that the old login bug may have overwritten to
  // 'customer'. Returns null when neither signal is conclusive.
  static bool? combineRoleSignals({
    required bool? fromMetadata,
    required bool hasProviderRecord,
  }) {
    if (fromMetadata == true) return true;
    if (hasProviderRecord) return true;
    if (fromMetadata == false) return false;
    return null;
  }

  // Resolve the account's actual role.
  // Priority: 'provider' metadata -> 'providers' table (authoritative proof,
  // overrides corrupted 'customer' metadata and self-heals it) ->
  // 'customer' metadata -> 'profiles' table.
  // Returns [fallback] (or false) when the role cannot be determined.
  Future<bool> resolveIsProvider(User user, {bool? fallback}) async {
    final bool? fromMetadata = isProviderFromMetadata(user.userMetadata);
    if (fromMetadata == true) return true;

    final bool? verdict = combineRoleSignals(
      fromMetadata: fromMetadata,
      hasProviderRecord: await hasProviderRecord(user.id),
    );
    if (verdict == true) {
      // Metadata said 'customer' (or nothing) but a providers row exists —
      // the old login bug corrupted this vendor account. Repair it.
      await persistUserRole(isProvider: true);
      return true;
    }
    if (verdict == false) return false;

    // No conclusive signal (legacy account) — check the profiles table.
    try {
      final profileDoc = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      if (profileDoc != null && profileDoc['role'] != null) {
        return profileDoc['role'].toString().toLowerCase() == roleProvider;
      }
    } catch (_) {}

    return fallback ?? false;
  }

  // True when the user has a row in the 'providers' table (created when a
  // provider submits verification), which proves the account is a provider.
  Future<bool> hasProviderRecord(String userId) async {
    try {
      final providerDoc = await _supabase
          .from('providers')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();
      return providerDoc != null;
    } catch (_) {
      return false;
    }
  }

  // Persist the role both in Supabase auth user metadata and in the
  // 'profiles' database table so it survives across devices and can be
  // queried by the backend. Never throws — role persistence must not
  // break the auth flow itself.
  Future<void> persistUserRole({required bool isProvider, String? fullName}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final role = isProvider ? roleProvider : roleCustomer;

    // 1. Auth user metadata (drives routing on app start).
    try {
      await _supabase.auth.updateUser(
        UserAttributes(data: {
          'is_provider': isProvider,
          'role': role,
          if (fullName != null && fullName.trim().isNotEmpty)
            'full_name': fullName.trim(),
        }),
      );
    } catch (_) {}

    // 2. Database row (see supabase/profiles_role_setup.sql).
    try {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'role': role,
        'is_provider': isProvider,
        if (fullName != null && fullName.trim().isNotEmpty)
          'full_name': fullName.trim(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {}
  }

  // Resend Verification Email
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to resend email. Check your internet connection.');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
    await _supabase.auth.signOut();
  }
}
