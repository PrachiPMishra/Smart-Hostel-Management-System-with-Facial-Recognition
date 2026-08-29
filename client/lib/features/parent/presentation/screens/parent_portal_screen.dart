import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/api_client.dart';

class ParentPortalScreen extends ConsumerStatefulWidget {
  const ParentPortalScreen({super.key});

  @override
  ConsumerState<ParentPortalScreen> createState() => _ParentPortalScreenState();
}

class _ParentPortalScreenState extends ConsumerState<ParentPortalScreen> {
  Map<String, dynamic>? _activityData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Get student ID from logged-in parent
      final data = await ref.read(apiClientProvider).getStudentActivity('student-id');

      if (mounted) {
        setState(() {
          _activityData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load activity: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Portal'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStudentInfoCard(),
                  const SizedBox(height: 24),
                  Text(
                    'Activity Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildAttendanceCard(),
                  const SizedBox(height: 12),
                  _buildMessCard(),
                  const SizedBox(height: 12),
                  _buildLeaveCard(),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildRecentActivity(),
                ],
              ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    final student = _activityData?['student'] ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                (student['name'] ?? 'S')[0].toUpperCase(),
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'] ?? 'Student Name',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Room: ${student['room_no'] ?? 'N/A'} • ${student['hostel_name'] ?? 'N/A'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student['email'] ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard() {
    final attendance = _activityData?['attendance'] ?? {};
    final percentage = attendance['percentage'] ?? 0.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Attendance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: percentage >= 75 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This Month',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Last Seen',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      attendance['last_seen'] ?? 'N/A',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessCard() {
    final mess = _activityData?['mess'] ?? {};
    final balance = mess['balance'] ?? 0.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.restaurant,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mess Balance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current balance',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              '₹${balance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: balance >= 200 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveCard() {
    final leave = _activityData?['leave'] ?? {};
    final active = leave['active'] ?? false;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.event_busy,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leave Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    active ? leave['dates'] ?? 'On leave' : 'No active leave',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                active ? 'ON LEAVE' : 'PRESENT',
                style: TextStyle(
                  color: active ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = _activityData?['recent_activity'] as List? ?? [];
    
    if (activities.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No recent activity',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: activities.map((activity) {
          final timestamp = DateTime.parse(activity['timestamp']);
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                _getActivityIcon(activity['type']),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(activity['title'] ?? ''),
            subtitle: Text(DateFormat('MMM d, y • h:mm a').format(timestamp)),
          );
        }).toList(),
      ),
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'attendance':
        return Icons.check_circle;
      case 'mess':
        return Icons.restaurant;
      case 'leave':
        return Icons.event_busy;
      default:
        return Icons.info;
    }
  }
}
