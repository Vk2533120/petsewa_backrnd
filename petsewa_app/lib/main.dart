import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_preview/device_preview.dart';
import 'supabase_config.dart';
import 'utils/app_theme.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/create_pet_profile_screen.dart';
import 'screens/customer_home.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_pet_profile_screen.dart';
import 'screens/service_discovery_screen.dart';
import 'screens/service_details_screen.dart';
import 'screens/booking_flow_screen.dart';
import 'screens/booking_success_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/adoption_screen.dart';
import 'screens/lost_found_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/notifications_screen.dart';
// Provider Screens
import 'screens/provider_service_select_screen.dart';
import 'screens/provider_register_screen.dart';
import 'screens/provider_verification_screen.dart';
import 'screens/provider_pending_screen.dart';
import 'screens/provider_home_screen.dart';
// NGO Screens
import 'screens/ngo_registration_screen.dart';
import 'screens/ngo_pending_screen.dart';
import 'screens/ngo_login_screen.dart';
import 'screens/ngo_dashboard_screen.dart';
import 'screens/ngo_add_pet_screen.dart';
import 'screens/ngo_hub_screen.dart';
import 'screens/ngo_detail_screen.dart';
import 'screens/adoption_request_screen.dart';
import 'screens/my_adoption_requests_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(
    DevicePreview(
      enabled: true,
      storage: DevicePreviewStorage.none(),
      defaultDevice: Devices.android.samsungGalaxyS20,
      devices: Devices.android.all,
      data: DevicePreviewData(
        deviceIdentifier: Devices.android.samsungGalaxyS20.identifier.toString(),
        isVirtualKeyboardVisible: true,
      ),
      tools: const [
        AccessibilitySection(),
        SettingsSection(),
      ],
      builder: (context) => const PetSewaApp(),
    ),
  );
}

class PetSewaApp extends StatelessWidget {
  const PetSewaApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final prefs = await SharedPreferences.getInstance();

    final isGuest = prefs.getBool('is_guest') ?? false;
    if (isGuest) {
      final hasPetProfile = prefs.getBool('has_pet_profile') ?? false;
      return hasPetProfile ? const CustomerHomeScreen() : const CreatePetProfileScreen();
    }

    if (user == null) {
      return const SplashScreen();
    }

    final isProvider = await AuthService().resolveIsProvider(
      user,
      fallback: prefs.getBool('is_provider'),
    );
    await prefs.setBool('is_provider', isProvider);

    if (isProvider) {
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

      if (status == 'approved' ||
          status == 'verified' ||
          prefs.getBool('provider_verified') == true) {
        return const ProviderHomeScreen();
      } else if (status == 'pending' || prefs.getBool('provider_submitted') == true) {
        return const ProviderPendingScreen();
      } else {
        return const ProviderVerificationScreen();
      }
    } else {
      bool hasPetProfile = prefs.getBool('has_pet_profile') ?? false;
      if (!hasPetProfile) {
        try {
          final petDoc = await supabase
              .from('pets')
              .select('id')
              .eq('user_id', user.id)
              .maybeSingle();
          if (petDoc != null) {
            hasPetProfile = true;
          }
        } catch (_) {}
      }

      if (hasPetProfile) {
        return const CustomerHomeScreen();
      } else {
        return const CreatePetProfileScreen();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'PetSewa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          return snapshot.data ?? const SplashScreen();
        },
      ),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/create-pet-profile': (context) => const CreatePetProfileScreen(),
        '/home': (context) => const CustomerHomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-pet-profile': (context) => const EditPetProfileScreen(),
        '/service-discovery': (context) => const ServiceDiscoveryScreen(),
        '/service-details': (context) => const ServiceDetailsScreen(),
        '/booking-flow': (context) => const BookingFlowScreen(),
        '/booking-success': (context) => const BookingSuccessScreen(),
        '/my-bookings': (context) => const MyBookingsScreen(),
        '/shop': (context) => const ShopScreen(),
        '/product-details': (context) => const ProductDetailsScreen(),
        '/cart': (context) => const CartScreen(),
        '/adoption': (context) => const AdoptionScreen(),
        '/lost-found': (context) => const LostFoundScreen(),
        '/emergency': (context) => const EmergencyScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        // Provider Routes
        '/provider-service-select': (context) => const ProviderServiceSelectScreen(),
        '/provider-register': (context) => const ProviderRegisterScreen(),
        '/provider-verification': (context) => const ProviderVerificationScreen(),
        '/provider-pending': (context) => const ProviderPendingScreen(),
        '/provider-home': (context) => const ProviderHomeScreen(),
        // NGO Routes
        '/ngo-register': (context) => const NgoRegistrationScreen(),
        '/ngo-pending': (context) => const NgoPendingScreen(),
        '/ngo-login': (context) => const NgoLoginScreen(),
        '/ngo-dashboard': (context) => const NgoDashboardScreen(),
        '/ngo-hub': (context) => const NgoHubScreen(),
        '/my-adoption-requests': (context) => const MyAdoptionRequestsScreen(),
      },
    );
  }
}
