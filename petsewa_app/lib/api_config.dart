// Centralized API Configuration for PetSewa Backend
// You can set your deployed online backend URL here or pass it at build time using:
// flutter run --dart-define=API_URL=https://your-online-backend.com

class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000', // Change this to your online backend URL
  );

  static String get rewardsUrl => '$baseUrl/rewards';
  static String get notificationsUrl => '$baseUrl/notifications';
  static String get authUrl => '$baseUrl/auth';
  static String get bookingsUrl => '$baseUrl/bookings';
  static String get vendorsUrl => '$baseUrl/vendors';
  static String get ecommerceUrl => '$baseUrl/ecommerce';
}
