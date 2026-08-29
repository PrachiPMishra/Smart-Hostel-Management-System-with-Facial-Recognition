import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/api_client.dart';

class MessScreen extends ConsumerStatefulWidget {
  const MessScreen({super.key});

  @override
  ConsumerState<MessScreen> createState() => _MessScreenState();
}

class _MessScreenState extends ConsumerState<MessScreen> {
  List<dynamic> _messRecords = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final records = await ref.read(apiClientProvider).getMessRecords();
      final stats = await ref.read(apiClientProvider).getMessStats();

      if (mounted) {
        setState(() {
          _messRecords = records;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load mess data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mess Management'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_stats != null) ...[
                    _buildBalanceCard(),
                    const SizedBox(height: 16),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Meals',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Show full history
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_messRecords.isEmpty)
                    _buildEmptyState()
                  else
                    ..._messRecords.take(10).map((record) => _buildMealCard(record)),
                ],
              ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final balance = _stats?['balance'] ?? 0.0;
    final isLow = balance < 200;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLow
                ? [Colors.red.shade400, Colors.red.shade600]
                : [Colors.green.shade400, Colors.green.shade600],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '₹${balance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (isLow) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.warning_amber, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Low Balance - Please recharge',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'This Month',
            '₹${(_stats?['monthly_spent'] ?? 0).toStringAsFixed(0)}',
            Icons.calendar_month,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Meals',
            '${_stats?['meals_count'] ?? 0}',
            Icons.restaurant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
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
        ),
      ),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> record) {
    final timestamp = DateTime.parse(record['timestamp']);
    final mealType = record['meal_type'] ?? 'general';
    final amount = record['amount'] ?? 0.0;

    IconData icon;
    String mealName;
    
    switch (mealType) {
      case 'breakfast':
        icon = Icons.free_breakfast;
        mealName = 'Breakfast';
        break;
      case 'lunch':
        icon = Icons.lunch_dining;
        mealName = 'Lunch';
        break;
      case 'dinner':
        icon = Icons.dinner_dining;
        mealName = 'Dinner';
        break;
      default:
        icon = Icons.restaurant;
        mealName = 'Meal';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(mealName),
        subtitle: Text(DateFormat('MMM d, y • h:mm a').format(timestamp)),
        trailing: Text(
          '-₹${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
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
              Icons.restaurant_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No meal records',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your meal history will appear here',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
