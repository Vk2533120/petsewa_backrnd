import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/ngo_service.dart';

class MyAdoptionRequestsScreen extends StatefulWidget {
  const MyAdoptionRequestsScreen({super.key});

  @override
  State<MyAdoptionRequestsScreen> createState() =>
      _MyAdoptionRequestsScreenState();
}

class _MyAdoptionRequestsScreenState extends State<MyAdoptionRequestsScreen> {
  final _ngoService = NgoService();
  List<dynamic> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    try {
      final requests = await _ngoService.getUserRequests();
      if (mounted) setState(() => _requests = requests);
    } catch (_) {
      if (mounted) setState(() => _requests = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return const Color(0xFF2E7D32);
      case 'rejected': return AppColors.accentRose;
      case 'adopted': return AppColors.accentBlue;
      default: return const Color(0xFF9A7A00);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'accepted': return Icons.check_circle_rounded;
      case 'rejected': return Icons.cancel_rounded;
      case 'adopted': return Icons.favorite_rounded;
      default: return Icons.hourglass_top_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted': return 'Accepted — Schedule Meet';
      case 'rejected': return 'Rejected';
      case 'adopted': return '🎉 Adopted!';
      default: return 'Pending Review';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('My Adoption Requests',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.pets_rounded,
                            size: 52, color: AppColors.accentBone),
                      ),
                      const SizedBox(height: 20),
                      const Text("No Adoption Requests Yet",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark)),
                      const SizedBox(height: 8),
                      const Text(
                          "Browse the NGO Hub and request\nto adopt a pet!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, color: AppColors.textMuted)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/ngo-hub'),
                        icon: const Icon(Icons.volunteer_activism_rounded,
                            color: Colors.white),
                        label: const Text('Browse NGO Hub',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (ctx, i) {
                      final req = _requests[i] as Map<String, dynamic>;
                      final status = req['status'] ?? 'pending';
                      final color = _statusColor(status);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppShadows.softCard,
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1.2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF889063),
                                          Color(0xFF354024)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.pets_rounded,
                                        color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pet ID #${req['petId']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppColors.textDark),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Request #${req['id']} · NGO ID #${req['ngoId']}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: color.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_statusIcon(status),
                                        color: color, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      _statusLabel(status),
                                      style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              // Meet info when accepted
                              if (status == 'accepted' &&
                                  req['meetScheduledAt'] != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentBlue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded,
                                          color: AppColors.accentBlue, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Meet scheduled: ${req['meetScheduledAt']}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.accentBlue,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              // Rejection reason
                              if (status == 'rejected' &&
                                  req['rejectionReason'] != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentRose.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Reason: ${req['rejectionReason']}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            AppColors.accentRose.withOpacity(0.85)),
                                  ),
                                ),
                              ],
                              // My message
                              if (req['message'] != null &&
                                  (req['message'] as String).isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 10),
                                Text('"${req['message']}"',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontStyle: FontStyle.italic)),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                'Submitted: ${DateTime.tryParse(req['createdAt'] ?? '')?.toLocal().toString().split('.')[0] ?? 'N/A'}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
