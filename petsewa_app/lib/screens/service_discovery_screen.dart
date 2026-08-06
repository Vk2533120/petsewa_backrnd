import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ServiceDiscoveryScreen extends StatefulWidget {
  const ServiceDiscoveryScreen({super.key});

  @override
  State<ServiceDiscoveryScreen> createState() => _ServiceDiscoveryScreenState();
}

class _ServiceDiscoveryScreenState extends State<ServiceDiscoveryScreen> {
  String _selectedFilter = 'Nearest';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['Nearest', 'Top Rated ⭐', 'Verified Vets 🩺', 'Budget Friendly 💰'];

  final List<Map<String, dynamic>> _providers = [
    {
      'id': '1',
      'name': 'Kathmandu Pet Care & Clinic',
      'rating': 4.9,
      'reviews': 124,
      'distance': '0.8 km',
      'priceRange': 'Rs. 500 - 2,000',
      'category': 'Vet & Grooming',
      'image': 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?auto=format&fit=crop&w=600&q=80',
      'isVerified': true,
      'isOpen': true,
    },
    {
      'id': '2',
      'name': 'Happy Paws Luxury Spa',
      'rating': 4.8,
      'reviews': 98,
      'distance': '1.2 km',
      'priceRange': 'Rs. 800 - 3,000',
      'category': 'Full Grooming',
      'image': 'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?auto=format&fit=crop&w=600&q=80',
      'isVerified': true,
      'isOpen': true,
    },
    {
      'id': '3',
      'name': 'Royal Companion Kennel',
      'rating': 4.7,
      'reviews': 76,
      'distance': '2.1 km',
      'priceRange': 'Rs. 1,000 - 4,500',
      'category': 'Boarding & Hostel',
      'image': 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?auto=format&fit=crop&w=600&q=80',
      'isVerified': false,
      'isOpen': true,
    },
    {
      'id': '4',
      'name': 'Alpha K9 Training Center',
      'rating': 4.9,
      'reviews': 210,
      'distance': '3.5 km',
      'priceRange': 'Rs. 1,500 - 6,000',
      'category': 'Dog Training',
      'image': 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=600&q=80',
      'isVerified': true,
      'isOpen': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Nearby Providers',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.softCard,
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search vets, groomers, dog walkers...',
                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8, bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected ? AppShadows.primaryGlow : AppShadows.subtle,
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Provider Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: _providers.length,
              itemBuilder: (context, index) {
                final provider = _providers[index];
                return _buildProviderCard(context, provider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, Map<String, dynamic> provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.softCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  provider['image'],
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 160,
                    color: AppColors.surfaceSubtle,
                    child: const Icon(Icons.pets, size: 40, color: AppColors.textMuted),
                  ),
                ),
              ),
              // Rating Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.secondary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${provider['rating']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        ' (${provider['reviews']})',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              // Status Pill
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: provider['isOpen'] ? AppColors.secondary : AppColors.textMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    provider['isOpen'] ? 'OPEN NOW' : 'CLOSED',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          // Provider Info Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        provider['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (provider['isVerified'])
                      const Icon(Icons.verified_rounded, color: AppColors.secondary, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  provider['category'],
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      provider['distance'],
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.payments_outlined, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      provider['priceRange'],
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/service-details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Book Care', style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
