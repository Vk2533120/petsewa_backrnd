import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Aanya Sharma';
  String _userEmail = 'aanya@example.com';
  String _petName = 'Milo';
  String _petBreed = 'Golden Retriever';
  String _petAge = '2 Yrs 4 Mos';
  String _petWeight = '24 kg';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    if (currentUser != null) {
      setState(() {
        _userEmail = currentUser.email ?? _userEmail;
        _userName = currentUser.userMetadata?['full_name'] ?? _userName;
      });
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final name = prefs.getString('pet_name');
      final breed = prefs.getString('pet_breed');
      if (name != null && name.isNotEmpty) _petName = name;
      if (breed != null && breed.isNotEmpty) _petBreed = breed;
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Pet Passport & Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Pet Passport Header Card
            _buildPetPassportCard(context),

            const SizedBox(height: 16),

            // Health Metrics Row
            _buildHealthMetricsRow(),

            const SizedBox(height: 20),

            // User Profile Card
            _buildUserInfoCard(),

            const SizedBox(height: 20),

            // Options List
            _buildOptionTile(
              icon: Icons.calendar_today_rounded,
              iconColor: AppColors.primary,
              title: 'My Service Bookings',
              subtitle: 'Active & past appointments',
              onTap: () => Navigator.pushNamed(context, '/my-bookings'),
            ),
            _buildOptionTile(
              icon: Icons.medical_services_rounded,
              iconColor: AppColors.secondary,
              title: 'Vaccination & Medical Records',
              subtitle: 'Digital vet certificates & history',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pet Passport Records synced! 🐾')),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: AppColors.accentBlue,
              title: 'PetSewa Wallet & Rewards',
              subtitle: 'Cashback & points balance',
              onTap: () => Navigator.pushNamed(context, '/wallet'),
            ),
            _buildOptionTile(
              icon: Icons.card_giftcard_rounded,
              iconColor: AppColors.secondary,
              title: 'Refer Friends & Earn Rewards',
              subtitle: 'Get +100 Pet Points per referral',
              onTap: () => Navigator.pushNamed(context, '/referral'),
            ),
            _buildOptionTile(
              icon: Icons.shopping_bag_rounded,
              iconColor: AppColors.primaryDark,
              title: 'Cart & Orders History',
              subtitle: 'Track pet product deliveries',
              onTap: () => Navigator.pushNamed(context, '/cart'),
            ),

            const SizedBox(height: 20),


            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout_rounded, color: AppColors.accentRose),
                label: const Text(
                  'Log Out',
                  style: TextStyle(color: AppColors.accentRose, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.accentRose),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPetPassportCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.warmBanner,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.primaryGlow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=300&q=80',
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _petName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '#892',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _petBreed,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, color: AppColors.secondary, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Vaccinated',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Passport: ACTIVE 🟢',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/edit-pet-profile'),
                child: const Text(
                  'Edit Passport →',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile('Age', _petAge, Icons.cake_rounded, AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile('Weight', _petWeight, Icons.fitness_center_rounded, AppColors.secondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile('Blood', 'DEA 1.1', Icons.bloodtype_rounded, AppColors.accentRose),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.softCard,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.softCard,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.accentBone,
            child: Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _userEmail,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentBone,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Pet Parent 🐾',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.subtle,
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
      ),
    );
  }
}
