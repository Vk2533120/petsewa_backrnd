import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderServiceSelectScreen extends StatefulWidget {
  const ProviderServiceSelectScreen({super.key});

  @override
  State<ProviderServiceSelectScreen> createState() => _ProviderServiceSelectScreenState();
}

class _ProviderServiceSelectScreenState extends State<ProviderServiceSelectScreen> {
  final Map<String, bool> _services = {
    'Grooming': false,
    'Vet Care': false,
    'Dog Walking': false,
    'Pet Training': false,
    'Hostels': false,
    'Sitting': false,
  };

  String? _error;

  void _handleNext() async {
    final selectedServices = _services.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedServices.isEmpty) {
      setState(() {
        _error = 'Please select at least one service you provide';
      });
      return;
    }

    // Save selected services to SharedPreferences temporarily
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('provider_selected_services', selectedServices);
    await prefs.setBool('is_provider', true);

    if (mounted) {
      Navigator.pushNamed(context, '/provider-register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Which services do you provide?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select all services you wish to offer to customers on PetSewa.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 28),

              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),

              Expanded(
                child: ListView(
                  children: _services.keys.map((serviceName) {
                    IconData iconData = Icons.pets;
                    switch (serviceName) {
                      case 'Grooming':
                        iconData = Icons.cut_outlined;
                        break;
                      case 'Vet Care':
                        iconData = Icons.local_hospital_outlined;
                        break;
                      case 'Dog Walking':
                        iconData = Icons.directions_walk_outlined;
                        break;
                      case 'Pet Training':
                        iconData = Icons.school_outlined;
                        break;
                      case 'Hostels':
                        iconData = Icons.home_work_outlined;
                        break;
                      case 'Sitting':
                        iconData = Icons.weekend_outlined;
                        break;
                    }
                    return Card(
                      color: const Color(0xFFF8FAFC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: _services[serviceName]!
                              ? const Color(0xFF354024)
                              : Colors.grey.shade200,
                          width: _services[serviceName]! ? 2 : 1,
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: CheckboxListTile(
                        title: Row(
                          children: [
                            Icon(iconData, color: const Color(0xFF354024)),
                            const SizedBox(width: 12),
                            Text(
                              serviceName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        activeColor: const Color(0xFF354024),
                        value: _services[serviceName],
                        onChanged: (bool? val) {
                          setState(() {
                            _services[serviceName] = val ?? false;
                            _error = null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF354024),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Next',
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
