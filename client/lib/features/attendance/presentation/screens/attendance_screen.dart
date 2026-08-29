import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/api_client.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  List<dynamic> _attendanceRecords = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String _selectedFilter = 'week';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      String? startDate;

      if (_selectedFilter == 'week') {
        startDate = now.subtract(const Duration(days: 7)).toIso8601String();
      } else if (_selectedFilter == 'month') {
        startDate = DateTime(now.year, now.month, 1).toIso8601String();
      }

      final records = await ref.read(apiClientProvider).getAttendanceHistory(
            startDate: startDate,
            endDate: now.toIso8601String(),
          );

      final stats = await ref.read(apiClientProvider).getAttendanceStats();

      if (mounted) {
        setState(() {
          _attendanceRecords = records;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load attendance: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedFilter,
            onSelected: (value) {
              setState(() => _selectedFilter = value);
              _loadData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'week', child: Text('This Week')),
              const PopupMenuItem(value: 'month', child: Text('This Month')),
              const PopupMenuItem(value: 'all', child: Text('All Time')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_stats != null) ...[
                    _buildStatsCard(),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Attendance History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (_attendanceRecords.isEmpty)
                    _buildEmptyState()
                  else
                    ..._attendanceRecords.map((record) => _buildAttendanceCard(record)),
                ],
              ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final percentage = _stats?['percentage'] ?? 0.0;
    final present = _stats?['present'] ?? 0;
    final total = _stats?['total'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Attendance Rate',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Present', '$present', Icons.check_circle, Colors.green),
                _buildStatItem('Absent', '${total - present}', Icons.cancel, Colors.red),
                _buildStatItem('Total', '$total', Icons.calendar_today, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    final timestamp = DateTime.parse(record['timestamp']);
    final method = record['method'] ?? 'face';
    final confidence = record['confidence'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(
            method == 'face' ? Icons.face : Icons.touch_app,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(DateFormat('EEEE, MMM d, y').format(timestamp)),
        subtitle: Text(
          '${DateFormat('h:mm a').format(timestamp)} • ${(confidence * 100).toStringAsFixed(0)}% match',
        ),
        trailing: Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No attendance records',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your attendance will appear here',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
