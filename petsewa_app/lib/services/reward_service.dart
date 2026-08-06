import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api_config.dart';

class RewardStatusModel {

  final int userId;
  final String referralCode;
  final String? referredByCode;
  final int points;
  final int totalEarnedPoints;
  final String level; // 'Bronze' | 'Silver' | 'Gold' | 'Platinum'
  final int referralsCount;
  final String? lastCheckInDate;
  final int streakDays;

  RewardStatusModel({
    required this.userId,
    required this.referralCode,
    this.referredByCode,
    required this.points,
    required this.totalEarnedPoints,
    required this.level,
    required this.referralsCount,
    this.lastCheckInDate,
    required this.streakDays,
  });

  factory RewardStatusModel.fromJson(Map<String, dynamic> json) {
    return RewardStatusModel(
      userId: json['userId'] ?? 1,
      referralCode: json['referralCode'] ?? 'PET-USER-892',
      referredByCode: json['referredByCode'],
      points: (json['points'] as num?)?.toInt() ?? 0,
      totalEarnedPoints: (json['totalEarnedPoints'] as num?)?.toInt() ?? 0,
      level: json['level'] ?? 'Bronze',
      referralsCount: (json['referralsCount'] as num?)?.toInt() ?? 0,
      lastCheckInDate: json['lastCheckInDate'],
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'referralCode': referralCode,
        'referredByCode': referredByCode,
        'points': points,
        'totalEarnedPoints': totalEarnedPoints,
        'level': level,
        'referralsCount': referralsCount,
        'lastCheckInDate': lastCheckInDate,
        'streakDays': streakDays,
      };
}

class RewardTransactionModel {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String? description;
  final int points;
  final DateTime createdAt;

  RewardTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.description,
    required this.points,
    required this.createdAt,
  });

  factory RewardTransactionModel.fromJson(Map<String, dynamic> json) {
    return RewardTransactionModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 1,
      type: json['type'] ?? 'BONUS',
      title: json['title'] ?? 'Reward Points',
      description: json['description'],
      points: (json['points'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CouponModel {
  final int id;
  final String code;
  final double discountAmount;
  final int pointsSpent;
  final String description;
  final bool isUsed;

  CouponModel({
    required this.id,
    required this.code,
    required this.discountAmount,
    required this.pointsSpent,
    required this.description,
    required this.isUsed,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      pointsSpent: (json['pointsSpent'] as num?)?.toInt() ?? 0,
      description: json['description'] ?? '',
      isUsed: json['isUsed'] ?? false,
    );
  }
}
class RewardService {

  // Backend API URL mapping (NestJS server)
  static String get baseUrl => ApiConfig.rewardsUrl;

  int _getNumericUserId() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Hash Supabase UUID to positive 32-bit integer for relational backend ID
        return user.id.hashCode.abs() % 1000000 + 1;
      }
    } catch (_) {}
    return 1; // Default guest/fallback userId
  }

  // Local state persistence for seamless fallback
  Future<RewardStatusModel> _getLocalStatus(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('reward_status_$userId');
    if (raw != null) {
      try {
        return RewardStatusModel.fromJson(jsonDecode(raw));
      } catch (_) {}
    }
    // Default initial reward state
    final initStatus = RewardStatusModel(
      userId: userId,
      referralCode: 'PET-PS${userId.toString().padLeft(4, '0')}',
      points: 120,
      totalEarnedPoints: 120,
      level: 'Bronze',
      referralsCount: 1,
      lastCheckInDate: null,
      streakDays: 0,
    );
    await _saveLocalStatus(initStatus);
    return initStatus;
  }

  Future<void> _saveLocalStatus(RewardStatusModel status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reward_status_${status.userId}', jsonEncode(status.toJson()));
  }

  Future<List<RewardTransactionModel>> _getLocalTransactions(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('reward_txs_$userId');
    if (raw != null) {
      return raw.map((e) => RewardTransactionModel.fromJson(jsonDecode(e))).toList();
    }
    // Default sample transaction history
    final initTxs = [
      RewardTransactionModel(
        id: 1,
        userId: userId,
        type: 'REFERRAL_WELCOME',
        title: 'Welcome Reward',
        description: 'Joined PetSewa platform bonus points',
        points: 100,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      RewardTransactionModel(
        id: 2,
        userId: userId,
        type: 'DAILY_CHECKIN',
        title: 'Daily Check-In',
        description: 'Claimed Day 1 login reward',
        points: 20,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    await _saveLocalTransactions(userId, initTxs);
    return initTxs;
  }

  Future<void> _saveLocalTransactions(int userId, List<RewardTransactionModel> txs) async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = txs.map((e) => jsonEncode({
      'id': e.id,
      'userId': e.userId,
      'type': e.type,
      'title': e.title,
      'description': e.description,
      'points': e.points,
      'createdAt': e.createdAt.toIso8601String(),
    })).toList();
    await prefs.setStringList('reward_txs_$userId', serialized);
  }

  // Fetch Reward Status
  Future<RewardStatusModel> fetchRewardStatus() async {
    final userId = _getNumericUserId();
    try {
      final res = await http.get(Uri.parse('$baseUrl/user/$userId')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final status = RewardStatusModel.fromJson(jsonDecode(res.body));
        await _saveLocalStatus(status);
        return status;
      }
    } catch (e) {
      if (kDebugMode) print('API unavailable, using local reward status fallback: $e');
    }
    return _getLocalStatus(userId);
  }

  // Claim Daily Check-in Reward
  Future<Map<String, dynamic>> claimDailyCheckIn() async {
    final userId = _getNumericUserId();
    try {
      final res = await http.post(Uri.parse('$baseUrl/user/$userId/daily-checkin')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final status = RewardStatusModel.fromJson(data['reward']);
        await _saveLocalStatus(status);
        return {
          'success': true,
          'message': data['message'] ?? 'Daily check-in reward claimed!',
          'pointsEarned': data['pointsEarned'] ?? 10,
          'status': status,
        };
      } else {
        final err = jsonDecode(res.body);
        return {'success': false, 'message': err['message'] ?? 'Already checked in today.'};
      }
    } catch (_) {
      // Local fallback logic
      final status = await _getLocalStatus(userId);
      final todayStr = DateTime.now().toIso8601String().split('T')[0];

      if (status.lastCheckInDate == todayStr) {
        return {'success': false, 'message': 'You have already claimed your daily check-in reward today!'};
      }

      int newStreak = status.streakDays + 1;
      int pointsEarned = 10 + (newStreak * 5);
      if (pointsEarned > 50) pointsEarned = 50;

      int newPoints = status.points + pointsEarned;
      int newTotal = status.totalEarnedPoints + pointsEarned;

      String newLevel = 'Bronze';
      if (newPoints >= 1000) newLevel = 'Platinum';
      else if (newPoints >= 500) newLevel = 'Gold';
      else if (newPoints >= 200) newLevel = 'Silver';

      final updatedStatus = RewardStatusModel(
        userId: userId,
        referralCode: status.referralCode,
        referredByCode: status.referredByCode,
        points: newPoints,
        totalEarnedPoints: newTotal,
        level: newLevel,
        referralsCount: status.referralsCount,
        lastCheckInDate: todayStr,
        streakDays: newStreak,
      );

      await _saveLocalStatus(updatedStatus);

      // Add local tx
      final txs = await _getLocalTransactions(userId);
      txs.insert(
        0,
        RewardTransactionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          userId: userId,
          type: 'DAILY_CHECKIN',
          title: 'Daily Check-In (Day $newStreak)',
          description: 'Claimed daily streak bonus of +$pointsEarned Pet Points!',
          points: pointsEarned,
          createdAt: DateTime.now(),
        ),
      );
      await _saveLocalTransactions(userId, txs);

      return {
        'success': true,
        'message': 'Awesome! You earned +$pointsEarned points for Day $newStreak streak! 🐾',
        'pointsEarned': pointsEarned,
        'status': updatedStatus,
      };
    }
  }

  // Apply Referral Code
  Future<Map<String, dynamic>> applyReferralCode(String code) async {
    final userId = _getNumericUserId();
    final cleanCode = code.trim().toUpperCase();

    if (cleanCode.isEmpty) {
      return {'success': false, 'message': 'Please enter a valid referral code.'};
    }

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/user/$userId/apply-referral'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'referralCode': cleanCode}),
      ).timeout(const Duration(seconds: 3));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        await fetchRewardStatus();
        return {'success': true, 'message': data['message'] ?? 'Referral code applied!'};
      } else {
        final err = jsonDecode(res.body);
        return {'success': false, 'message': err['message'] ?? 'Invalid referral code.'};
      }
    } catch (_) {
      // Local fallback logic
      final status = await _getLocalStatus(userId);
      if (status.referredByCode != null) {
        return {'success': false, 'message': 'You have already redeemed a referral code.'};
      }
      if (status.referralCode == cleanCode) {
        return {'success': false, 'message': 'You cannot use your own referral code.'};
      }

      int newPoints = status.points + 50;
      int newTotal = status.totalEarnedPoints + 50;
      String newLevel = status.level;
      if (newPoints >= 1000) newLevel = 'Platinum';
      else if (newPoints >= 500) newLevel = 'Gold';
      else if (newPoints >= 200) newLevel = 'Silver';

      final updatedStatus = RewardStatusModel(
        userId: userId,
        referralCode: status.referralCode,
        referredByCode: cleanCode,
        points: newPoints,
        totalEarnedPoints: newTotal,
        level: newLevel,
        referralsCount: status.referralsCount,
        lastCheckInDate: status.lastCheckInDate,
        streakDays: status.streakDays,
      );

      await _saveLocalStatus(updatedStatus);

      final txs = await _getLocalTransactions(userId);
      txs.insert(
        0,
        RewardTransactionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          userId: userId,
          type: 'REFERRAL_WELCOME',
          title: 'Referral Welcome Bonus',
          description: 'Earned +50 bonus points using code $cleanCode',
          points: 50,
          createdAt: DateTime.now(),
        ),
      );
      await _saveLocalTransactions(userId, txs);

      return {
        'success': true,
        'message': 'Referral code applied successfully! You received +50 bonus points. 🎉',
      };
    }
  }

  // Fetch Reward Transactions
  Future<List<RewardTransactionModel>> fetchTransactions() async {
    final userId = _getNumericUserId();
    try {
      final res = await http.get(Uri.parse('$baseUrl/user/$userId/transactions')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((e) => RewardTransactionModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return _getLocalTransactions(userId);
  }

  // Redeem Points for Voucher
  Future<Map<String, dynamic>> redeemPoints(int pointsToRedeem, double discountAmount, String description) async {
    final userId = _getNumericUserId();
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/user/$userId/redeem'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pointsToRedeem': pointsToRedeem,
          'discountAmount': discountAmount,
          'description': description,
        }),
      ).timeout(const Duration(seconds: 3));

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        await fetchRewardStatus();
        return {'success': true, 'message': data['message'], 'coupon': CouponModel.fromJson(data['coupon'])};
      } else {
        final err = jsonDecode(res.body);
        return {'success': false, 'message': err['message'] ?? 'Failed to redeem voucher.'};
      }
    } catch (_) {
      // Local fallback logic
      final status = await _getLocalStatus(userId);
      if (status.points < pointsToRedeem) {
        return {'success': false, 'message': 'Insufficient Pet Points. You need $pointsToRedeem points.'};
      }

      int newPoints = status.points - pointsToRedeem;
      final updatedStatus = RewardStatusModel(
        userId: userId,
        referralCode: status.referralCode,
        referredByCode: status.referredByCode,
        points: newPoints,
        totalEarnedPoints: status.totalEarnedPoints,
        level: status.level,
        referralsCount: status.referralsCount,
        lastCheckInDate: status.lastCheckInDate,
        streakDays: status.streakDays,
      );
      await _saveLocalStatus(updatedStatus);

      final code = 'PET-VO-${Random().nextInt(900000) + 100000}';
      final txs = await _getLocalTransactions(userId);
      txs.insert(
        0,
        RewardTransactionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          userId: userId,
          type: 'REDEMPTION',
          title: 'Voucher Redemption',
          description: 'Redeemed $pointsToRedeem points for ₹${discountAmount.toStringAsFixed(0)} voucher ($code)',
          points: -pointsToRedeem,
          createdAt: DateTime.now(),
        ),
      );
      await _saveLocalTransactions(userId, txs);

      final coupon = CouponModel(
        id: DateTime.now().millisecondsSinceEpoch,
        code: code,
        discountAmount: discountAmount,
        pointsSpent: pointsToRedeem,
        description: description,
        isUsed: false,
      );

      return {
        'success': true,
        'message': 'Successfully redeemed $pointsToRedeem points for voucher $code! 🎟️',
        'coupon': coupon,
      };
    }
  }
}
