import 'package:flutter_test/flutter_test.dart';
import 'package:petsewa_app/services/auth_service.dart';

void main() {
  group('AuthService.isProviderFromMetadata', () {
    test('given role provider in metadata when resolving role then returns provider', () {
      expect(
        AuthService.isProviderFromMetadata({'role': 'provider'}),
        isTrue,
      );
    });

    test('given is_provider true in metadata when resolving role then returns provider', () {
      expect(
        AuthService.isProviderFromMetadata({'is_provider': true}),
        isTrue,
      );
    });

    test('given full provider signup metadata when resolving role then returns provider', () {
      expect(
        AuthService.isProviderFromMetadata({
          'full_name': 'Pet Care Studio',
          'is_provider': true,
          'role': 'provider',
        }),
        isTrue,
      );
    });

    test('given role customer in metadata when resolving role then returns customer', () {
      expect(
        AuthService.isProviderFromMetadata({'role': 'customer'}),
        isFalse,
      );
    });

    test('given is_provider false in metadata when resolving role then returns customer', () {
      expect(
        AuthService.isProviderFromMetadata({'is_provider': false}),
        isFalse,
      );
    });

    test('given full customer signup metadata when resolving role then returns customer', () {
      expect(
        AuthService.isProviderFromMetadata({
          'full_name': 'Pet Owner',
          'is_provider': false,
          'role': 'customer',
        }),
        isFalse,
      );
    });

    test('given null metadata when resolving role then returns unknown', () {
      expect(AuthService.isProviderFromMetadata(null), isNull);
    });

    test('given empty metadata when resolving role then returns unknown', () {
      expect(AuthService.isProviderFromMetadata({}), isNull);
    });

    test('given metadata without role keys when resolving role then returns unknown', () {
      expect(
        AuthService.isProviderFromMetadata({'full_name': 'Legacy User'}),
        isNull,
      );
    });

    test('given conflicting metadata when resolving role then provider flag wins', () {
      // is_provider is the primary flag written at sign-up; if it says
      // provider the account must never be downgraded silently.
      expect(
        AuthService.isProviderFromMetadata({
          'is_provider': true,
          'role': 'customer',
        }),
        isTrue,
      );
    });

    test('given unexpected role value when resolving role then returns unknown', () {
      expect(
        AuthService.isProviderFromMetadata({'role': 'admin'}),
        isNull,
      );
    });
  });

  group('AuthService.combineRoleSignals', () {
    test('given provider metadata when combining signals then returns provider', () {
      expect(
        AuthService.combineRoleSignals(
          fromMetadata: true,
          hasProviderRecord: false,
        ),
        isTrue,
      );
    });

    test('given customer metadata but existing providers row when combining signals then providers row wins', () {
      // Vendor account whose metadata was overwritten to 'customer' by the
      // old login bug: the providers row is authoritative proof, so the
      // account must be treated as a provider (and the Customer tab must
      // reject it).
      expect(
        AuthService.combineRoleSignals(
          fromMetadata: false,
          hasProviderRecord: true,
        ),
        isTrue,
      );
    });

    test('given no metadata but existing providers row when combining signals then returns provider', () {
      expect(
        AuthService.combineRoleSignals(
          fromMetadata: null,
          hasProviderRecord: true,
        ),
        isTrue,
      );
    });

    test('given customer metadata and no providers row when combining signals then returns customer', () {
      expect(
        AuthService.combineRoleSignals(
          fromMetadata: false,
          hasProviderRecord: false,
        ),
        isFalse,
      );
    });

    test('given no metadata and no providers row when combining signals then returns unknown', () {
      expect(
        AuthService.combineRoleSignals(
          fromMetadata: null,
          hasProviderRecord: false,
        ),
        isNull,
      );
    });
  });
}
