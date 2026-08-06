import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.pets,
      'color': AppColors.secondary,
      'title': 'Welcome to PetSewa! 🐾',
      'subtitle': 'Account created successfully',
      'time': 'Just now',
      'unread': true,
    },
    {
      'icon': Icons.local_offer,
      'color': Colors.green,
      'title': 'Special Offer!',
      'subtitle': '20% off first grooming',
      'time': '2 hours ago',
      'unread': true,
    },
    {
      'icon': Icons.favorite,
      'color': Colors.red,
      'title': 'Adoption Alert',
      'subtitle': 'New pets near you!',
      'time': '1 day ago',
      'unread': false,
    },
    {
      'icon': Icons.search,
      'color': Colors.blue,
      'title': 'Lost Pet Alert',
      'subtitle': 'Golden Retriever reported near you',
      'time': '2 days ago',
      'unread': false,
    },
    {
      'icon': Icons.star,
      'color': Colors.purple,
      'title': 'Earn Rewards',
      'subtitle': 'Complete profile for 50 points',
      'time': '3 days ago',
      'unread': false,
    },
  ];

  void _markAllRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['unread'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Color(0xFF354024)),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          final bool isUnread = notification['unread'] as bool;
          return ListTile(
            tileColor: isUnread ? AppColors.secondarySoft : null,
            leading: CircleAvatar(
              backgroundColor: (notification['color'] as Color).withOpacity(0.15),
              child: Icon(
                notification['icon'] as IconData,
                color: notification['color'] as Color,
              ),
            ),
            title: Text(
              notification['title'] as String,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(notification['subtitle'] as String),
            trailing: Text(
              notification['time'] as String,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () {
              setState(() {
                _notifications[index]['unread'] = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(notification['title'] as String),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
