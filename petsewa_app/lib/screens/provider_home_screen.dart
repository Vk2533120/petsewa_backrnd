import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  String _providerName = 'Business Owner';
  String _providerAddress = 'Lazimpat, Kathmandu';
  String _providerAbout = '';
  List<String> _selectedServices = [];

  final _aboutController = TextEditingController();
  final _addressController = TextEditingController();

  // Mock incoming bookings for the service provider
  final List<Map<String, String>> _incomingBookings = [
    {
      'petName': 'Bruno',
      'breed': 'Labrador',
      'service': 'Grooming',
      'time': 'Today, 02:00 PM',
      'client': 'Aanya Sharma',
      'status': 'Pending Confirmation'
    },
    {
      'petName': 'Luna',
      'breed': 'Persian Cat',
      'service': 'Vet Care',
      'time': 'Tomorrow, 10:30 AM',
      'client': 'Rohan Pokhrel',
      'status': 'Confirmed'
    },
    {
      'petName': 'Coco',
      'breed': 'Indie Puppy',
      'service': 'Sitting',
      'time': '21st July, 04:00 PM',
      'client': 'Siddharth Shrestha',
      'status': 'Confirmed'
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProviderData() async {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    if (currentUser != null) {
      setState(() {
        _providerName = currentUser.userMetadata?['full_name'] ?? 'Pet Care Studio';
      });
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedServices = prefs.getStringList('provider_selected_services') ?? ['Grooming', 'Sitting'];
      _providerAbout = prefs.getString('provider_about') ?? 'Professional pet care services';
      _providerAddress = prefs.getString('provider_address') ?? 'Lazimpat, Kathmandu';
      _aboutController.text = _providerAbout;
      _addressController.text = _providerAddress;
    });
  }

  Future<void> _updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('provider_about', _aboutController.text.trim());
    await prefs.setString('provider_address', _addressController.text.trim());
    await prefs.setStringList('provider_selected_services', _selectedServices);
    
    setState(() {
      _providerAbout = _aboutController.text.trim();
      _providerAddress = _addressController.text.trim();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Provider Profile Updated!'),
          backgroundColor: Color(0xFF354024),
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _acceptBooking(int index) {
    setState(() {
      _incomingBookings[index]['status'] = 'Confirmed';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking for ${_incomingBookings[index]['petName']} Confirmed!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showComingSoon(String feature) {
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
                'We are implementing advanced provider management dashboards. Stay tuned! 🐾',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
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
                    elevation: 0,
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF354024).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront, color: Color(0xFF354024), size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'PetSewa Provider',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined, color: Colors.red),
              onPressed: _handleLogout,
            )
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF354024),
            unselectedLabelColor: Color(0xFF64748B),
            indicatorColor: Color(0xFF354024),
            tabs: [
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'My Bookings'),
              Tab(icon: Icon(Icons.edit_note_outlined), text: 'Edit Services'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: BOOKINGS
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _incomingBookings.length,
              itemBuilder: (context, index) {
                final booking = _incomingBookings[index];
                final isPending = booking['status'] == 'Pending Confirmation';
                return Card(
                  color: const Color(0xFFF8FAFC),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              booking['service']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF354024)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPending ? Colors.amber.shade50 : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                booking['status']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isPending ? Colors.amber.shade800 : Colors.green.shade800,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Client: ${booking['client']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 4),
                        Text('Pet details: ${booking['petName']} (${booking['breed']})', style: const TextStyle(color: Color(0xFF64748B))),
                        Text('Time: ${booking['time']}', style: const TextStyle(color: Color(0xFF64748B))),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (isPending) ...[
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _acceptBooking(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Accept Booking'),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showComingSoon('Client Chat'),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Chat Client', style: TextStyle(color: Color(0xFF1E293B))),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),

            // TAB 2: EDIT SERVICES
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Offering Services',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
                  // Checkboxes of services
                  ...['Grooming', 'Vet Care', 'Dog Walking', 'Pet Training', 'Hostels', 'Sitting'].map((s) {
                    final selected = _selectedServices.contains(s);
                    return CheckboxListTile(
                      activeColor: const Color(0xFF354024),
                      title: Text(s, style: const TextStyle(fontWeight: FontWeight.w600)),
                      value: selected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedServices.add(s);
                          } else {
                            _selectedServices.remove(s);
                          }
                        });
                      },
                    );
                  }),
                  const Divider(height: 32),

                  const Text(
                    'About Services & Pricing',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _aboutController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Service Address',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFF354024)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF354024),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Save Profile Updates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
