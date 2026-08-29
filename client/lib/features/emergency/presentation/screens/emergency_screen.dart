import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/api/api_client.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key};

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  List<dynamic> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);

    try {
      final contacts = await ref.read(apiClientProvider).getEmergencyContacts();

      if (mounted) {
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load contacts: $e')),
        );
      }
    }
  }

  Future<void> _triggerEmergency() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
          size: 64,
        ),
        title: const Text('Trigger Emergency Alert?'),
        content: const Text(
          'This will immediately notify hostel authorities, security, and your emergency contacts.\n\nOnly use in case of genuine emergency.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('TRIGGER ALERT'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(apiClientProvider).triggerEmergencyAlert({
          'location': 'User Location', // TODO: Get actual location
          'timestamp': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              icon: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              title: const Text('Alert Sent'),
              content: const Text(
                'Emergency alert has been triggered. Help is on the way.\n\nStay safe and stay where you are.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send alert: $e')),
          );
        }
      }
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot make phone call')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.red.shade50,
            child: Column(
              children: [
                Icon(
                  Icons.emergency,
                  size: 80,
                  color: Colors.red.shade700,
                ),
                const SizedBox(height: 16),
                Text(
                  'SOS EMERGENCY',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Press the button below only in case of genuine emergency',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _triggerEmergency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.warning_amber_rounded, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'TRIGGER EMERGENCY ALERT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Emergency Contacts',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildQuickDialSection(),
                      const SizedBox(height: 24),
                      if (_contacts.isNotEmpty) ...[
                        Text(
                          'Your Emergency Contacts',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        ..._contacts.map((contact) => _buildContactCard(contact)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDialSection() {
    final quickContacts = [
      {'name': 'Police', 'number': '100', 'icon': Icons.local_police},
      {'name': 'Ambulance', 'number': '102', 'icon': Icons.local_hospital},
      {'name': 'Fire', 'number': '101', 'icon': Icons.local_fire_department},
      {'name': 'Women Helpline', 'number': '1091', 'icon': Icons.support_agent},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: quickContacts.length,
      itemBuilder: (context, index) {
        final contact = quickContacts[index];
        return InkWell(
          onTap: () => _makeCall(contact['number'] as String),
          borderRadius: BorderRadius.circular(12),
          child: Card(
            color: Colors.red.shade50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  contact['icon'] as IconData,
                  size: 40,
                  color: Colors.red.shade700,
                ),
                const SizedBox(height: 8),
                Text(
                  contact['name'] as String,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  contact['number'] as String,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(contact['name'] ?? 'Unknown'),
        subtitle: Text(contact['relationship'] ?? ''),
        trailing: IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () => _makeCall(contact['phone']),
          color: Colors.green,
        ),
      ),
    );
  }
}
