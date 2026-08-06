import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPetProfileScreen extends StatefulWidget {
  const EditPetProfileScreen({super.key});

  @override
  State<EditPetProfileScreen> createState() => _EditPetProfileScreenState();
}

class _EditPetProfileScreenState extends State<EditPetProfileScreen> {
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _healthController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedVaccination = 'Fully Vaccinated';

  final List<String> _vaccinationOptions = [
    'Fully Vaccinated',
    'Partially Vaccinated',
    'Not Vaccinated',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('pet_name') ?? '';
      _breedController.text = prefs.getString('pet_breed') ?? '';
      _ageController.text = prefs.getString('pet_age') ?? '';
      _selectedGender = prefs.getString('pet_gender') ?? 'Male';
      _selectedVaccination =
          prefs.getString('pet_vaccination') ?? 'Fully Vaccinated';
      _healthController.text = prefs.getString('pet_health') ?? '';
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pet_name', _nameController.text);
    await prefs.setString('pet_breed', _breedController.text);
    await prefs.setString('pet_age', _ageController.text);
    await prefs.setString('pet_gender', _selectedGender);
    await prefs.setString('pet_vaccination', _selectedVaccination);
    await prefs.setString('pet_health', _healthController.text);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated!')),
    );
    Navigator.pop(context);
  }

  Future<void> _deleteProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet Profile'),
        content: const Text(
            'Are you sure you want to delete this pet profile? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pet_name');
      await prefs.remove('pet_breed');
      await prefs.remove('pet_age');
      await prefs.remove('pet_gender');
      await prefs.remove('pet_vaccination');
      await prefs.remove('pet_health');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/create-pet-profile');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFF354024);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pet Profile'),
        foregroundColor: Colors.white,
        backgroundColor: orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Pet Name',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: orange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Breed
            TextField(
              controller: _breedController,
              decoration: const InputDecoration(
                labelText: 'Breed',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: orange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Age
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: orange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gender
            const Text(
              'Gender',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Male'),
                  selected: _selectedGender == 'Male',
                  selectedColor: orange.withOpacity(0.2),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedGender = 'Male');
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Female'),
                  selected: _selectedGender == 'Female',
                  selectedColor: orange.withOpacity(0.2),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedGender = 'Female');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vaccination Status
            const Text(
              'Vaccination Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedVaccination,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: orange, width: 2),
                ),
              ),
              items: _vaccinationOptions
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedVaccination = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Health Info
            TextField(
              controller: _healthController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Health Information',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: orange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Delete Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _deleteProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Delete Pet Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
