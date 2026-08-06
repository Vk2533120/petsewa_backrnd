import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../services/ngo_service.dart';
import 'ngo_add_pet_screen.dart';

class NgoDashboardScreen extends StatefulWidget {
  const NgoDashboardScreen({super.key});

  @override
  State<NgoDashboardScreen> createState() => _NgoDashboardScreenState();
}

class _NgoDashboardScreenState extends State<NgoDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _ngoService = NgoService();

  int _ngoId = 0;
  String _ngoName = '';
  String _ngoEmail = '';
  String _ngoLocation = '';

  List<dynamic> _pets = [];
  List<dynamic> _requests = [];

  bool _petsLoading = true;
  bool _requestsLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNgoSession();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNgoSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ngoId = prefs.getInt('ngo_id') ?? 0;
      _ngoName = prefs.getString('ngo_name') ?? 'My NGO';
      _ngoEmail = prefs.getString('ngo_email') ?? '';
      _ngoLocation = prefs.getString('ngo_location') ?? '';
    });
    if (_ngoId > 0) {
      _loadPets();
      _loadRequests();
    }
  }

  Future<void> _loadPets() async {
    setState(() => _petsLoading = true);
    try {
      final pets = await _ngoService.getNgoPets(_ngoId);
      if (mounted) setState(() => _pets = pets);
    } catch (_) {
      if (mounted) setState(() => _pets = []);
    } finally {
      if (mounted) setState(() => _petsLoading = false);
    }
  }

  Future<void> _loadRequests() async {
    setState(() => _requestsLoading = true);
    try {
      final requests = await _ngoService.getNgoRequests(_ngoId);
      if (mounted) setState(() => _requests = requests);
    } catch (_) {
      if (mounted) setState(() => _requests = []);
    } finally {
      if (mounted) setState(() => _requestsLoading = false);
    }
  }

  Future<void> _acceptRequest(int requestId) async {
    try {
      await _ngoService.acceptRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Request accepted! Contact the user to schedule a meet.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _loadRequests();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _rejectRequest(int requestId) async {
    try {
      await _ngoService.rejectRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Request rejected.'),
          backgroundColor: AppColors.textMuted,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _loadRequests();
      _loadPets(); // pet goes back to available
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _markAdopted(int requestId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Adoption',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        content: const Text(
            'Mark this pet as successfully adopted? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Yes, Adopted!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _ngoService.markAdopted(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 Pet marked as adopted successfully!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _loadRequests();
      _loadPets();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.replaceFirst('Exception: ', '')),
        backgroundColor: AppColors.accentRose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ngo_id');
    await prefs.remove('ngo_name');
    await prefs.remove('ngo_email');
    await prefs.remove('ngo_location');
    await prefs.remove('is_ngo');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/ngo-login', (route) => false);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return const Color(0xFF2E7D32);
      case 'rejected': return AppColors.accentRose;
      case 'adopted': return AppColors.accentBlue;
      default: return const Color(0xFF9A7A00);
    }
  }

  Color _petStatusColor(String status) {
    switch (status) {
      case 'available': return const Color(0xFF2E7D32);
      case 'requested': return const Color(0xFF9A7A00);
      case 'adopted': return AppColors.accentBlue;
      default: return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.volunteer_activism_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _ngoName.isEmpty ? 'NGO Dashboard' : _ngoName,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.pets_rounded, size: 18), text: 'My Pets'),
            Tab(
                icon: Icon(Icons.inbox_rounded, size: 18),
                text: 'Requests'),
            Tab(
                icon: Icon(Icons.person_rounded, size: 18),
                text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPetsTab(),
          _buildRequestsTab(),
          _buildProfileTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => NgoAddPetScreen(ngoId: _ngoId)),
                );
                if (result == true) _loadPets();
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Add Pet',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildPetsTab() {
    if (_petsLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_pets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets_rounded, size: 60, color: AppColors.accentBone),
            const SizedBox(height: 16),
            const Text('No pets listed yet',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('Tap + to add a pet for adoption',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadPets,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pets.length,
        itemBuilder: (ctx, i) {
          final pet = _pets[i] as Map<String, dynamic>;
          final status = pet['adoptionStatus'] ?? 'available';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.softCard,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              leading: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF889063), Color(0xFF354024)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.pets_rounded, color: Colors.white, size: 24),
              ),
              title: Text(pet['petName'] ?? 'Unknown',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.textDark)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${pet['breed'] ?? 'Mixed breed'} · ${pet['gender'] ?? ''} · ${pet['age'] ?? ''}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _petStatusColor(status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: _petStatusColor(status),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: pet['isVaccinated'] == true
                  ? const Icon(Icons.verified_rounded,
                      color: AppColors.primary, size: 20)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsTab() {
    if (_requestsLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 60, color: AppColors.accentBone),
            const SizedBox(height: 16),
            const Text('No adoption requests yet',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('Requests will appear here when users apply',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (ctx, i) {
          final req = _requests[i] as Map<String, dynamic>;
          final status = req['status'] ?? 'pending';
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.softCard,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(req['userName'] ?? 'User',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.textDark)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: _statusColor(status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.email_rounded,
                          size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(req['userEmail'] ?? '',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                  if (req['userPhone'] != null && (req['userPhone'] as String).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_rounded,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(req['userPhone'],
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                  if (req['message'] != null && (req['message'] as String).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('"${req['message']}"',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic)),
                    ),
                  ],
                  if (req['meetScheduledAt'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 13, color: AppColors.accentBlue),
                        const SizedBox(width: 4),
                        Text('Meet: ${req['meetScheduledAt']}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.accentBlue,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                  if (status == 'pending') ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                _rejectRequest(req['id'] as int),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.accentRose),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Reject',
                                style: TextStyle(
                                    color: AppColors.accentRose,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                _acceptRequest(req['id'] as int),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Accept',
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (status == 'accepted') ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _markAdopted(req['id'] as int),
                        icon: const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
                        label: const Text('Mark as Adopted',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF536D88), Color(0xFF354024)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: AppShadows.primaryGlow,
              ),
              child: const Icon(Icons.volunteer_activism_rounded,
                  color: Colors.white, size: 42),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(_ngoName,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(_ngoEmail,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ),
          if (_ngoLocation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(_ngoLocation,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Stats row
          Row(
            children: [
              _buildStatCard('Total Pets', _pets.length.toString(),
                  Icons.pets_rounded, AppColors.primary),
              const SizedBox(width: 12),
              _buildStatCard(
                  'Requests',
                  _requests.length.toString(),
                  Icons.inbox_rounded,
                  AppColors.secondary),
              const SizedBox(width: 12),
              _buildStatCard(
                  'Adopted',
                  _pets
                      .where((p) =>
                          (p as Map<String, dynamic>)['adoptionStatus'] == 'adopted')
                      .length
                      .toString(),
                  Icons.favorite_rounded,
                  AppColors.accentBlue),
            ],
          ),
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, color: AppColors.accentRose),
              label: const Text('Logout from NGO Portal',
                  style: TextStyle(
                      color: AppColors.accentRose, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.accentRose),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.softCard,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
