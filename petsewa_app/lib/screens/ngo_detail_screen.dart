import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/ngo_service.dart';
import 'adoption_request_screen.dart';

class NgoDetailScreen extends StatefulWidget {
  final int ngoId;
  const NgoDetailScreen({super.key, required this.ngoId});

  @override
  State<NgoDetailScreen> createState() => _NgoDetailScreenState();
}

class _NgoDetailScreenState extends State<NgoDetailScreen> {
  final _ngoService = NgoService();
  Map<String, dynamic>? _ngo;
  List<dynamic> _pets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final ngo = await _ngoService.getNgoById(widget.ngoId);
      final pets = await _ngoService.getNgoPets(widget.ngoId);
      if (mounted) {
        setState(() {
          _ngo = ngo;
          _pets = pets
              .where((p) =>
                  (p as Map<String, dynamic>)['adoptionStatus'] == 'available')
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.accentRose,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _ngo == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 50, color: AppColors.accentRose),
                      const SizedBox(height: 12),
                      const Text('Could not load NGO details'),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Go back')),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 220,
                      pinned: true,
                      backgroundColor: AppColors.primary,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration:
                              const BoxDecoration(gradient: AppGradients.ngoGradient),
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: const Icon(
                                            Icons.volunteer_activism_rounded,
                                            color: Colors.white,
                                            size: 32),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    _ngo!['name'] ?? '',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 19,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    maxLines: 2,
                                                  ),
                                                ),
                                                const Icon(Icons.verified_rounded,
                                                    color: Colors.white, size: 18),
                                              ],
                                            ),
                                            if (_ngo!['location'] != null) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.location_on_rounded,
                                                      color: Colors.white70,
                                                      size: 13),
                                                  const SizedBox(width: 3),
                                                  Text(_ngo!['location'],
                                                      style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12)),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Contact info row
                            if (_ngo!['contactPhone'] != null) ...[
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: AppShadows.subtle,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.phone_rounded,
                                          color: AppColors.primary, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Contact Phone',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textMuted)),
                                        Text(_ngo!['contactPhone'],
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textDark)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            // About
                            if (_ngo!['description'] != null &&
                                (_ngo!['description'] as String).isNotEmpty) ...[
                              const Text('About',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark)),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: AppShadows.subtle,
                                ),
                                child: Text(
                                  _ngo!['description'],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                      height: 1.6),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            // Pets section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pets Available for Adoption (${_pets.length})',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_pets.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(Icons.pets_rounded,
                                        color: AppColors.accentBone, size: 40),
                                    SizedBox(height: 10),
                                    Text('No pets available right now',
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 14)),
                                  ],
                                ),
                              )
                            else
                              ...(_pets.map((pet) {
                                final p = pet as Map<String, dynamic>;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: AppShadows.softCard,
                                  ),
                                  child: ListTile(
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(14, 10, 14, 10),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF889063),
                                            Color(0xFF354024)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.pets_rounded,
                                          color: Colors.white, size: 22),
                                    ),
                                    title: Text(p['petName'] ?? 'Pet',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textDark)),
                                    subtitle: Text(
                                      '${p['breed'] ?? 'Mixed'} · ${p['gender'] ?? ''} · ${p['age'] ?? ''}',
                                      style: const TextStyle(
                                          fontSize: 12, color: AppColors.textMuted),
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  AdoptionRequestScreen(pet: p)),
                                        ).then((_) => _loadData());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('Adopt',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                );
                              }).toList()),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
