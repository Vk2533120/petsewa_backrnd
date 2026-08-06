import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePetProfileScreen extends StatefulWidget {
  const CreatePetProfileScreen({super.key});

  @override
  State<CreatePetProfileScreen> createState() => _CreatePetProfileScreenState();
}

class _CreatePetProfileScreenState extends State<CreatePetProfileScreen> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _healthController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedVaccination = 'Fully Vaccinated';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  Future<void> _savePetProfile() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter your pet\'s name');
      return;
    }
    if (_breedController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter pet breed (e.g. Labrador, Persian)');
      return;
    }
    if (_ageController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter pet age');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final petData = {
      'name': _nameController.text.trim(),
      'breed': _breedController.text.trim(),
      'age': _ageController.text.trim(),
      'gender': _selectedGender,
      'vaccination_status': _selectedVaccination,
      'health_info': _healthController.text.trim(),
      'user_id': Supabase.instance.client.auth.currentUser?.id,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      try {
        await Supabase.instance.client.from('pets').insert(petData);
      } catch (dbError) {
        debugPrint('Supabase table insert failed (falling back to SharedPreferences): $dbError');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pet_name', petData['name'] as String);
      await prefs.setString('pet_breed', petData['breed'] as String);
      await prefs.setString('pet_age', petData['age'] as String);
      await prefs.setString('pet_gender', petData['gender'] as String);
      await prefs.setString('pet_vaccination', petData['vaccination_status'] as String);
      await prefs.setString('pet_health', petData['health_info'] as String);
      await prefs.setBool('has_pet_profile', true);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to save profile. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSkip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_pet_profile', false);
    // Remove old pet details so it defaults to "your pet"
    await prefs.remove('pet_name');
    await prefs.remove('pet_breed');
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create Pet Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: _handleSkip,
              child: const Row(
                children: [
                  Text(
                    'Skip',
                    style: TextStyle(
                      color: Color(0xFF354024),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF354024)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, val, child) {
                    return Transform.scale(
                      scale: val,
                      child: child,
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF354024).withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF354024).withOpacity(0.3), width: 2),
                        ),
                        child: const Icon(
                          Icons.pets_outlined,
                          size: 60,
                          color: Color(0xFF354024),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF354024),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tell us about your companion to personalize your experience',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 32),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Pet Name',
                  hintText: 'e.g. Bruno, Bella',
                  prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF354024)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF354024), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _breedController,
                decoration: InputDecoration(
                  labelText: 'Breed',
                  hintText: 'e.g. Golden Retriever, Persian Cat',
                  prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFF354024)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF354024), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _ageController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Age',
                  hintText: 'e.g. 2 Years, 5 Months',
                  prefixIcon: const Icon(Icons.cake_outlined, color: Color(0xFF354024)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF354024), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Gender',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Male')),
                      selected: _selectedGender == 'Male',
                      selectedColor: const Color(0xFF354024).withOpacity(0.12),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedGender == 'Male' ? const Color(0xFF354024) : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      side: BorderSide(
                        color: _selectedGender == 'Male' ? const Color(0xFF354024) : Colors.grey.shade300,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedGender = 'Male');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Female')),
                      selected: _selectedGender == 'Female',
                      selectedColor: const Color(0xFF354024).withOpacity(0.12),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedGender == 'Female' ? const Color(0xFF354024) : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      side: BorderSide(
                        color: _selectedGender == 'Female' ? const Color(0xFF354024) : Colors.grey.shade300,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedGender = 'Female');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Vaccination Status',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedVaccination,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Fully Vaccinated', child: Text('Fully Vaccinated')),
                  DropdownMenuItem(value: 'Partially Vaccinated', child: Text('Partially Vaccinated')),
                  DropdownMenuItem(value: 'Not Vaccinated', child: Text('Not Vaccinated')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedVaccination = val);
                },
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _healthController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Health Info / Medical Notes (Optional)',
                  hintText: 'e.g. Food allergies, ongoing treatments, or none.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF354024), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              ElevatedButton(
                onPressed: _isLoading ? null : _savePetProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF354024),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text(
                        'Complete Profile & Start',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
