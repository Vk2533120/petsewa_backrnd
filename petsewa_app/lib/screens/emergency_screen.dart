import 'package:flutter/material.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _isSOSActive = false;

  final List<Map<String, String>> _emergencyNumbers = [
    {
      'name': 'PetSewa Emergency',
      'number': '1800-PET-HELP',
      'icon': 'emergency',
    },
    {
      'name': 'Animal Rescue Nepal',
      'number': 'Contact',
      'icon': 'volunteer_activism',
    },
    {
      'name': '24/7 Vet Helpline',
      'number': 'Contact',
      'icon': 'medical_services',
    },
  ];

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

  IconData _getEmergencyIcon(String iconName) {
    switch (iconName) {
      case 'emergency':
        return Icons.emergency;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'medical_services':
        return Icons.medical_services;
      default:
        return Icons.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Connect'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Warning Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '⚠️ Use the SOS button only in genuine emergencies. This will alert nearby vets and rescue teams.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
              ),
            ),

            const SizedBox(height: 32),

            // SOS Button
            GestureDetector(
              onTap: () {
                setState(() {
                  _isSOSActive = !_isSOSActive;
                });
                if (_isSOSActive) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('SOS Triggered!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: _isSOSActive ? const Color(0xFF8B0000) : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: _isSOSActive
                      ? const Text(
                          'ACTIVE\nTAP TO CANCEL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        )
                      : const Text(
                          'SOS',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Emergency Numbers Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency Numbers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  ..._emergencyNumbers.map((item) => Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getEmergencyIcon(item['icon']!),
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        item['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      subtitle: Text(
                        item['number']!,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _showComingSoon(context, 'Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Call', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Chat with Vet
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showComingSoon(context, 'Live Chat with Vet'),
                  icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF354024)),
                  label: const Text(
                    'Live Chat with Vet',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF354024), fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF354024), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
