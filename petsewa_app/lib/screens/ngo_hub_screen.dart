import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_theme.dart';
import '../services/ngo_service.dart';
import 'ngo_detail_screen.dart';
import 'adoption_request_screen.dart';

class NgoHubScreen extends StatefulWidget {
  const NgoHubScreen({super.key});

  @override
  State<NgoHubScreen> createState() => _NgoHubScreenState();
}

class _NgoHubScreenState extends State<NgoHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _ngoService = NgoService();

  List<dynamic> _ngos = [];
  List<dynamic> _pets = [];
  bool _ngosLoading = true;
  bool _petsLoading = true;

  String _petFilter = 'All';
  final List<String> _petFilters = ['All', 'Dogs', 'Cats', 'Others'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNgos();
    _loadPets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNgos() async {
    setState(() => _ngosLoading = true);
    try {
      final ngos = await _ngoService.getAllApprovedNgos();
      if (mounted) setState(() => _ngos = ngos);
    } catch (_) {
      if (mounted) setState(() => _ngos = []);
    } finally {
      if (mounted) setState(() => _ngosLoading = false);
    }
  }

  Future<void> _loadPets() async {
    setState(() => _petsLoading = true);
    try {
      final pets = await _ngoService.getAllAvailablePets();
      if (mounted) setState(() => _pets = pets);
    } catch (_) {
      if (mounted) setState(() => _pets = []);
    } finally {
      if (mounted) setState(() => _petsLoading = false);
    }
  }

  List<dynamic> get _filteredPets {
    if (_petFilter == 'All') return _pets;
    final filterLower = _petFilter.toLowerCase();
    return _pets.where((p) {
      final breed = ((p as Map<String, dynamic>)['breed'] ?? '').toString().toLowerCase();
      final name = (p['petName'] ?? '').toString().toLowerCase();
      if (_petFilter == 'Dogs') {
        return breed.contains('lab') ||
            breed.contains('retriev') ||
            breed.contains('indie') ||
            breed.contains('shepherd') ||
            breed.contains('huskey') ||
            name.contains('dog');
      } else if (_petFilter == 'Cats') {
        return breed.contains('cat') ||
            breed.contains('persian') ||
            breed.contains('siamese') ||
            name.contains('cat') ||
            name.contains('kitten');
      } else {
        return true;
      }
    }).toList();
  }

  void _openAdoptionRequest(Map<String, dynamic> pet) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login to submit an adoption request.'),
          backgroundColor: AppColors.accentRose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdoptionRequestScreen(pet: pet),
      ),
    ).then((_) => _loadPets());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.my_library_books_rounded,
                    color: Colors.white),
                tooltip: 'My Adoption Requests',
                onPressed: () =>
                    Navigator.pushNamed(context, '/my-adoption-requests'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppGradients.ngoGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🐾 NGO Hub',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('Support NGOs & Adopt Pets',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.business_rounded, size: 18), text: 'NGOs'),
                Tab(icon: Icon(Icons.pets_rounded, size: 18), text: 'Pets'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNgosTab(),
            _buildPetsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildNgosTab() {
    if (_ngosLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_ngos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_rounded, size: 60, color: AppColors.accentBone),
            const SizedBox(height: 16),
            const Text('No NGOs available yet',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('NGOs will appear here once approved',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadNgos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _ngos.length,
        itemBuilder: (ctx, i) {
          final ngo = _ngos[i] as Map<String, dynamic>;
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => NgoDetailScreen(ngoId: ngo['id'] as int)),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadows.softCard,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF536D88), Color(0xFF354024)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.volunteer_activism_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(ngo['name'] ?? 'NGO',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.textDark)),
                              ),
                              const Icon(Icons.verified_rounded,
                                  color: AppColors.primary, size: 18),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (ngo['location'] != null &&
                              (ngo['location'] as String).isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 3),
                                Text(ngo['location'],
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.textMuted)),
                              ],
                            ),
                          if (ngo['description'] != null &&
                              (ngo['description'] as String).isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              ngo['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetsTab() {
    return Column(
      children: [
        // Filter chips
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _petFilters.map((f) {
                final selected = _petFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => setState(() => _petFilter = f),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.accentBone),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: _petsLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : _filteredPets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pets_rounded,
                              size: 60, color: AppColors.accentBone),
                          const SizedBox(height: 16),
                          const Text('No pets available',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _loadPets,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredPets.length,
                        itemBuilder: (ctx, i) {
                          final pet =
                              _filteredPets[i] as Map<String, dynamic>;
                          return _buildPetCard(pet);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.softCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet image placeholder
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withOpacity(0.8),
                  AppColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.pets_rounded,
                      color: Colors.white70, size: 44),
                ),
                if (pet['isVaccinated'] == true)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('✓ Vacc',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pet['petName'] ?? 'Pet',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    '${pet['breed'] ?? 'Mixed'} · ${pet['gender'] ?? ''}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (pet['age'] != null &&
                      (pet['age'] as String).isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(pet['age'],
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _openAdoptionRequest(pet),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Adopt',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
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
}
