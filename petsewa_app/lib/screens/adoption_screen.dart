import 'package:flutter/material.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Dogs', 'Cats', 'Others'];

  final List<Map<String, String>> _adoptionPets = [
    {'name': 'Bruno', 'breed': 'Labrador', 'age': '2 yr', 'gender': 'Male', 'type': 'Dogs', 'icon': 'pets'},
    {'name': 'Luna', 'breed': 'Persian', 'age': '1 yr', 'gender': 'Female', 'type': 'Cats', 'icon': 'pets'},
    {'name': 'Coco', 'breed': 'Indie Puppy', 'age': '3 mo', 'gender': 'Male', 'type': 'Dogs', 'icon': 'pets'},
    {'name': 'Milo', 'breed': 'Golden Retriever', 'age': '8 mo', 'gender': 'Female', 'type': 'Dogs', 'icon': 'pets'},
    {'name': 'Simba', 'breed': 'Indie Cat', 'age': '2 yr', 'gender': 'Male', 'type': 'Cats', 'icon': 'pets'},
    {'name': 'Bella', 'breed': 'Shih Tzu', 'age': '1 yr', 'gender': 'Female', 'type': 'Dogs', 'icon': 'pets'},
  ];

  List<Map<String, String>> get _filteredPets {
    if (_selectedFilter == 'All') return _adoptionPets;
    return _adoptionPets.where((pet) => pet['type'] == _selectedFilter).toList();
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF354024).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_outline_rounded, color: Color(0xFF354024), size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                '$feature Coming Soon!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),
              const Text(
                'We are working hard on this. Stay tuned! 🐾',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF354024),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Got it!', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Adoption'),
        backgroundColor: const Color(0xFF354024),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF354024), Color(0xFF889063)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Give a Home',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Find your perfect companion',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.favorite, color: Colors.white, size: 48),
                ],
              ),
            ),

            // Filter Chips
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: const Color(0xFF354024),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: Colors.grey.shade100,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
            ),

            // Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: _filteredPets.length,
                itemBuilder: (context, index) {
                  final pet = _filteredPets[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF354024).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.pets, color: Color(0xFF354024), size: 32),
                          ),
                          const SizedBox(height: 8),
                          // Name
                          Text(
                            pet['name']!,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          // Breed
                          Text(
                            pet['breed']!,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          // Age • Gender
                          Text(
                            '${pet['age']} • ${pet['gender']}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 4),
                          // Vaccinated Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Vaccinated ✓',
                              style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Adopt Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showComingSoon(context, 'Adopt'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF354024),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Adopt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
