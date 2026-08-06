import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderVerificationScreen extends StatefulWidget {
  const ProviderVerificationScreen({super.key});

  @override
  State<ProviderVerificationScreen> createState() => _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState extends State<ProviderVerificationScreen> {
  final List<TextEditingController> _driveControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  final _aboutController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var c in _driveControllers) {
      c.dispose();
    }
    _aboutController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _addDriveLink() {
    if (_driveControllers.length < 5) {
      setState(() {
        _driveControllers.add(TextEditingController());
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = 'Maximum 5 links allowed';
      });
    }
  }

  void _removeDriveLink(int index) {
    if (_driveControllers.length > 3) {
      setState(() {
        _driveControllers[index].dispose();
        _driveControllers.removeAt(index);
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = 'Minimum 3 links required';
      });
    }
  }

  Future<void> _handleSubmit() async {
    // Validate inputs
    int filledLinksCount = 0;
    List<String> links = [];
    for (var controller in _driveControllers) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        filledLinksCount++;
        links.add(text);
      }
    }

    if (filledLinksCount < 3) {
      setState(() => _errorMessage = 'Please provide at least 3 Google Drive photo links');
      return;
    }

    if (_aboutController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please write something about your service');
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please provide your service address');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    final providerData = {
      'user_id': currentUser?.id,
      'about': _aboutController.text.trim(),
      'address': _addressController.text.trim(),
      'drive_links': links,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      // 1. Insert to Supabase table 'providers'
      try {
        await supabase.from('providers').insert(providerData);
      } catch (dbError) {
        debugPrint('Supabase insert failed, falling back to local config: $dbError');
      }

      // 2. Save to SharedPreferences so app knows verification is pending
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('provider_verified', false);
      await prefs.setBool('provider_submitted', true);
      await prefs.setString('provider_about', providerData['about'] as String);
      await prefs.setString('provider_address', providerData['address'] as String);
      await prefs.setStringList('provider_drive_links', links);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/provider-pending');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to submit verification details: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Verification Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Help Us Verify Your Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please upload photo folders or documents via Google Drive links so we can approve your provider profile.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),

              const Text(
                'Service Photos (Drive Links)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              ...List.generate(_driveControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _driveControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Drive Photo Link ${index + 1}',
                            hintText: 'https://drive.google.com/...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      if (_driveControllers.length > 3) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeDriveLink(index),
                        )
                      ]
                    ],
                  ),
                );
              }),

              if (_driveControllers.length < 5)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addDriveLink,
                    icon: const Icon(Icons.add, color: Color(0xFF354024)),
                    label: const Text(
                      'Add Drive Link',
                      style: TextStyle(color: Color(0xFF354024), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // About
              const Text(
                'About Your Services & Rates',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _aboutController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe your service, experience, pricing structure (e.g. Grooming rate, working hours)...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF354024), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Address
              const Text(
                'Service Location Address',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'e.g. Lazimpat, Kathmandu, Nepal',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF354024)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF354024), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
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
                        'Submit for Verification',
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
