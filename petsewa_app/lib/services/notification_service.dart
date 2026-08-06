import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_theme.dart';
import '../api_config.dart';

class NotificationModel {

  final int id;
  final int userId;
  final String type; // 'BOOKING' | 'REWARD' | 'ORDER' | 'EMERGENCY' | 'SYSTEM' | 'COMMUNITY'
  final String title;
  final String body;
  final bool isRead;
  final String? deepLink;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.deepLink,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 1,
      type: (json['type'] ?? 'SYSTEM').toString().toUpperCase(),
      title: json['title'] ?? 'PetSewa Alert',
      body: json['body'] ?? '',
      isRead: json['isRead'] ?? false,
      deepLink: json['deepLink'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type,
        'title': title,
        'body': body,
        'isRead': isRead,
        'deepLink': deepLink,
        'createdAt': createdAt.toIso8601String(),
      };

  String get formattedTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  IconData get iconData {
    switch (type) {
      case 'BOOKING':
        return Icons.calendar_today_rounded;
      case 'REWARD':
        return Icons.stars_rounded;
      case 'ORDER':
        return Icons.shopping_bag_rounded;
      case 'EMERGENCY':
        return Icons.warning_amber_rounded;
      case 'COMMUNITY':
        return Icons.people_rounded;
      case 'SYSTEM':
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'BOOKING':
        return AppColors.primary;
      case 'REWARD':
        return AppColors.secondary;
      case 'ORDER':
        return Colors.green;
      case 'EMERGENCY':
        return AppColors.accentRose;
      case 'COMMUNITY':
        return Colors.teal;
      case 'SYSTEM':
      default:
        return Colors.purple;
    }
  }
}
class NotificationService {

  static String get baseUrl => ApiConfig.notificationsUrl;

  int _getNumericUserId() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        return user.id.hashCode.abs() % 1000000 + 1;
      }
    } catch (_) {}
    return 1;
  }

  // Local fallback storage
  Future<List<NotificationModel>> _getLocalNotifications(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('notifications_$userId');
    if (raw != null) {
      return raw.map((e) => NotificationModel.fromJson(jsonDecode(e))).toList();
    }

    // Default notifications seed
    final init = [
      NotificationModel(
        id: 101,
        userId: userId,
        type: 'REWARD',
        title: 'Referral Bonus Unlocked! 🎁',
        body: 'Your friend joined PetSewa! You earned +100 Pet Points.',
        isRead: false,
        deepLink: '/wallet',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      NotificationModel(
        id: 102,
        userId: userId,
        type: 'BOOKING',
        title: 'Grooming Appointment Confirmed 🐾',
        body: 'Your appointment at PawCare Studio is scheduled for tomorrow at 11:00 AM.',
        isRead: false,
        deepLink: '/my-bookings',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 103,
        userId: userId,
        type: 'ORDER',
        title: 'Order Out for Delivery 📦',
        body: 'Royal Canin Adult Food is out for delivery. Track driver in real time.',
        isRead: true,
        deepLink: '/cart',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 104,
        userId: userId,
        type: 'EMERGENCY',
        title: 'Emergency SOS Vet Alert 🚨',
        body: 'Dr. Sharma has accepted your emergency request and is en route.',
        isRead: true,
        deepLink: '/emergency',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: 105,
        userId: userId,
        type: 'SYSTEM',
        title: 'Welcome to PetSewa Ecosystem! 🐶',
        body: 'Explore nearby vets, grooming, adoption listings, lost & found, and earn points.',
        isRead: true,
        deepLink: '/home',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
    await _saveLocalNotifications(userId, init);
    return init;
  }

  Future<void> _saveLocalNotifications(int userId, List<NotificationModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('notifications_$userId', serialized);
  }

  // Fetch Notifications
  Future<List<NotificationModel>> fetchNotifications({String? category}) async {
    final userId = _getNumericUserId();
    try {
      String url = '$baseUrl/user/$userId';
      if (category != null && category.isNotEmpty && category != 'ALL') {
        url += '?category=$category';
      }
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final list = data.map((e) => NotificationModel.fromJson(e)).toList();
        if (category == null || category == 'ALL') {
          await _saveLocalNotifications(userId, list);
        }
        return list;
      }
    } catch (e) {
      if (kDebugMode) print('API unavailable, using local notification fallback: $e');
    }

    final local = await _getLocalNotifications(userId);
    if (category != null && category.isNotEmpty && category != 'ALL') {
      return local.where((n) => n.type == category.toUpperCase()).toList();
    }
    return local;
  }

  // Fetch Unread Count
  Future<int> fetchUnreadCount() async {
    final userId = _getNumericUserId();
    try {
      final res = await http.get(Uri.parse('$baseUrl/user/$userId/unread-count')).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['unreadCount'] ?? 0;
      }
    } catch (_) {}
    final local = await _getLocalNotifications(userId);
    return local.where((n) => !n.isRead).length;
  }

  // Mark single as read
  Future<void> markAsRead(int id) async {
    final userId = _getNumericUserId();
    try {
      await http.patch(
        Uri.parse('$baseUrl/$id/read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      ).timeout(const Duration(seconds: 2));
    } catch (_) {}

    final local = await _getLocalNotifications(userId);
    final updated = local.map((n) {
      if (n.id == id) {
        return NotificationModel(
          id: n.id,
          userId: n.userId,
          type: n.type,
          title: n.title,
          body: n.body,
          isRead: true,
          deepLink: n.deepLink,
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();
    await _saveLocalNotifications(userId, updated);
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    final userId = _getNumericUserId();
    try {
      await http.patch(Uri.parse('$baseUrl/user/$userId/read-all')).timeout(const Duration(seconds: 2));
    } catch (_) {}

    final local = await _getLocalNotifications(userId);
    final updated = local.map((n) => NotificationModel(
          id: n.id,
          userId: n.userId,
          type: n.type,
          title: n.title,
          body: n.body,
          isRead: true,
          deepLink: n.deepLink,
          createdAt: n.createdAt,
        )).toList();
    await _saveLocalNotifications(userId, updated);
  }

  // Delete notification
  Future<void> deleteNotification(int id) async {
    final userId = _getNumericUserId();
    try {
      await http.delete(Uri.parse('$baseUrl/$id?userId=$userId')).timeout(const Duration(seconds: 2));
    } catch (_) {}

    final local = await _getLocalNotifications(userId);
    local.removeWhere((n) => n.id == id);
    await _saveLocalNotifications(userId, local);
  }

  // Clear all notifications
  Future<void> clearAll() async {
    final userId = _getNumericUserId();
    try {
      await http.delete(Uri.parse('$baseUrl/user/$userId/clear-all')).timeout(const Duration(seconds: 2));
    } catch (_) {}

    await _saveLocalNotifications(userId, []);
  }
}
