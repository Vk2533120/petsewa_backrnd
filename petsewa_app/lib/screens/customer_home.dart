import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentNavIndex = 0;
  String _petName = 'your pet';
  String _petBreed = 'Golden Retriever';

  final List<Map<String, dynamic>> _topProviders = [
    {
      'name': 'Kathmandu Pet Clinic',
      'category': 'Vet Care & Surgery',
      'rating': 4.9,
      'distance': '0.8 km',
      'price': 'Rs. 500 onwards',
      'icon': Icons.local_hospital_rounded,
      'color': AppColors.primary,
    },
    {
      'name': 'Happy Paws Grooming',
      'category': 'Spa & Full Grooming',
      'rating': 4.8,
      'distance': '1.2 km',
      'price': 'Rs. 800 onwards',
      'icon': Icons.content_cut_rounded,
      'color': AppColors.secondary,
    },
    {
      'name': 'Pawsome Dog Walkers',
      'category': 'Daily Dog Walking',
      'rating': 4.7,
      'distance': '1.5 km',
      'price': 'Rs. 300 / walk',
      'icon': Icons.directions_walk_rounded,
      'color': AppColors.accentTan,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('pet_name');
    final breed = prefs.getString('pet_breed');
    setState(() {
      if (name != null && name.isNotEmpty) _petName = name;
      if (breed != null && breed.isNotEmpty) _petBreed = breed;
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/my-bookings');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/shop');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    } else {
      setState(() => _currentNavIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            _buildHeaderBar(),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Welcome & Pet Passport Status
                      _buildGreetingBanner(),

                      const SizedBox(height: 20),

                      // Hero Service Banner (Kombu & Moss Green)
                      _buildHeroPromoBanner(),

                      const SizedBox(height: 24),

                      // Core Services Grid
                      _buildServicesSection(),

                      const SizedBox(height: 24),

                      // Quick Actions (Emergency, Wallet, Bookings)
                      _buildQuickActionsSection(),

                      const SizedBox(height: 24),

                      // Top Rated Providers Carousel
                      _buildTopProvidersSection(),

                      const SizedBox(height: 24),

                      // Explore Pet Care Options
                      _buildExploreMoreSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // 4-Tab Earth Theme Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeaderBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          // Pet Selector Pill
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentBone,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.accentTan.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.pets, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _petName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        _petBreed,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Search Trigger
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.surfaceSubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded, color: AppColors.primaryDark, size: 20),
            ),
            onPressed: () => Navigator.pushNamed(context, '/service-discovery'),
          ),

          // Notification Icon
          Stack(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_outlined, color: AppColors.primaryDark, size: 20),
                ),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, Pet Parent! 👋',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Best Care for $_petName',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, color: AppColors.secondary, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Passport Active',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppGradients.warmBanner,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppShadows.primaryGlow,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.pets_rounded,
                size: 110,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '🌿 Organic & Certified Care',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Premium Pet Care\n& Grooming Spa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Instant booking for certified vets, pet sitters & hostels.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/service-discovery'),
                  icon: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryDark),
                  label: const Text('Book Care Now', style: TextStyle(color: AppColors.primaryDark, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBone,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    final List<Map<String, dynamic>> services = [
      {'label': 'Grooming', 'icon': Icons.content_cut_rounded, 'color': AppColors.primary},
      {'label': 'Vet Care', 'icon': Icons.local_hospital_rounded, 'color': AppColors.primaryDark},
      {'label': 'Dog Walking', 'icon': Icons.directions_walk_rounded, 'color': AppColors.secondary},
      {'label': 'Training', 'icon': Icons.school_rounded, 'color': AppColors.accentTan},
      {'label': 'Hostels', 'icon': Icons.home_work_rounded, 'color': AppColors.accentBlue},
      {'label': 'Sitting', 'icon': Icons.weekend_rounded, 'color': AppColors.accentRose},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Our Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/service-discovery'),
                child: const Text(
                  'View All →',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final service = services[index];
              final Color color = service['color'];
              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/service-discovery'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.softCard,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(service['icon'], color: color, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service['label'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  title: 'Emergency\n24/7 SOS',
                  icon: Icons.emergency_rounded,
                  color: AppColors.accentRose,
                  route: '/emergency',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  title: 'My\nBookings',
                  icon: Icons.calendar_today_rounded,
                  color: AppColors.primary,
                  route: '/my-bookings',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  title: 'My\nWallet',
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.secondary,
                  route: '/wallet',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProvidersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Nearby Providers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/service-discovery'),
                child: const Text(
                  'Explore →',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _topProviders.length,
            itemBuilder: (context, index) {
              final provider = _topProviders[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShadows.softCard,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (provider['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(provider['icon'], color: provider['color'], size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            provider['category'],
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.secondary, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                '${provider['rating']}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                provider['distance'],
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/service-details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Book', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExploreMoreSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore More',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildExploreCard(
                  title: 'Pet Adoption',
                  subtitle: 'Adopt a friend 🐾',
                  icon: Icons.favorite_rounded,
                  color: AppColors.secondary,
                  route: '/adoption',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildExploreCard(
                  title: 'Lost & Found',
                  subtitle: 'Reunite pets 🔍',
                  icon: Icons.search_rounded,
                  color: AppColors.primary,
                  route: '/lost-found',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildExploreCard(
                  title: 'NGO Hub',
                  subtitle: 'Support & Adopt 💚',
                  icon: Icons.volunteer_activism_rounded,
                  color: AppColors.accentBlue,
                  route: '/ngo-hub',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildExploreCard(
                  title: 'Pet Shop',
                  subtitle: 'Food & Toys 🛍️',
                  icon: Icons.shopping_bag_rounded,
                  color: AppColors.primaryDark,
                  route: '/shop',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildExploreCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.softCard,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      backgroundColor: Colors.white,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      onTap: _onBottomNavTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_rounded),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_rounded),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
