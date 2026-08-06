import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../services/ngo_service.dart';

class NgoAddPetScreen extends StatefulWidget {
  final int ngoId;
  const NgoAddPetScreen({super.key, required this.ngoId});

  @override
  State<NgoAddPetScreen> createState() => _NgoAddPetScreenState();
}

class _NgoAddPetScreenState extends State<NgoAddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _healthCtrl = TextEditingController();
  String _gender = 'Male';
  bool _isVaccinated = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _descCtrl.dispose();
    _healthCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await NgoService().addPet(
        widget.ngoId,
        petName: _nameCtrl.text.trim(),
        breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
        age: _ageCtrl.text.trim().isEmpty ? null : _ageCtrl.text.trim(),
        gender: _gender,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        isVaccinated: _isVaccinated,
        healthNotes: _healthCtrl.text.trim().isEmpty ? null : _healthCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pet listing added successfully! 🐾'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true); // Return true to trigger refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.accentRose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Add Pet for Adoption',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet icon header
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF889063), Color(0xFF354024)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.softCard,
                  ),
                  child: const Icon(Icons.pets_rounded, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel('Pet Information'),
              const SizedBox(height: 12),
              _buildField(
                controller: _nameCtrl,
                label: 'Pet Name *',
                icon: Icons.pets_rounded,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Pet name is required' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _breedCtrl,
                label: 'Breed (optional)',
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _ageCtrl,
                label: 'Age (e.g. 2 years, 6 months)',
                icon: Icons.cake_rounded,
              ),
              const SizedBox(height: 14),
              // Gender selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Gender'),
                  const SizedBox(height: 10),
                  Row(
                    children: ['Male', 'Female', 'Unknown'].map((g) {
                      final selected = _gender == g;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(g),
                          selected: selected,
                          onSelected: (_) => setState(() => _gender = g),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                              color: selected ? AppColors.primary : AppColors.accentBone),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Description
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'About this pet',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child:
                        Icon(Icons.description_rounded, color: AppColors.primary),
                  ),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.accentBone),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
              ),
              const SizedBox(height: 16),
              _sectionLabel('Health & Vaccination'),
              const SizedBox(height: 10),
              // Vaccination toggle
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accentBone),
                ),
                child: SwitchListTile(
                  title: const Text('Vaccinated',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  subtitle: const Text('Has received all required vaccinations',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  value: _isVaccinated,
                  onChanged: (v) => setState(() => _isVaccinated = v),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _healthCtrl,
                label: 'Health Notes (optional)',
                icon: Icons.medical_services_rounded,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline_rounded,
                                color: Colors.white),
                            SizedBox(width: 8),
                            Text('Add Pet Listing',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.5));
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentBone),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      validator: validator,
    );
  }
}
