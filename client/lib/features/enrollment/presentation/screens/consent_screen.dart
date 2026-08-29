import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _consentGiven = false;
  bool _isLoading = false;

  Future<void> _handleConsent() async {
    if (!_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the consent to proceed'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(apiClientProvider).giveConsent();
      if (mounted) {
        context.push('/enrollment');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save consent. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Consent'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.privacy_tip_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Facial Recognition Consent',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Before we proceed with face enrollment, please read and understand the following:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildConsentSection(
              'Data Collection',
              'We will capture and store your facial features (embeddings) for attendance tracking purposes only.',
            ),
            _buildConsentSection(
              'Data Usage',
              'Your facial data will be used exclusively for:\n'
              '• Automated attendance marking via CCTV\n'
              '• Identity verification\n'
              '• Security and access control',
            ),
            _buildConsentSection(
              'Data Security',
              '• All facial embeddings are encrypted at rest\n'
              '• Data is stored securely in our database\n'
              '• Access is restricted to authorized personnel only\n'
              '• TLS encryption for all data transfers',
            ),
            _buildConsentSection(
              'Your Rights',
              '• You can withdraw consent at any time\n'
              '• Request deletion of your facial data\n'
              '• Access your stored data\n'
              '• File complaints about data misuse',
            ),
            _buildConsentSection(
              'Data Retention',
              'Your facial data will be retained for the duration of your hostel stay and up to 1 year after departure, unless you request deletion earlier.',
            ),
            _buildConsentSection(
              'Opt-Out',
              'If you choose not to enroll, manual attendance marking will be used. This may require additional time and effort.',
            ),
            const SizedBox(height: 32),
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: CheckboxListTile(
                value: _consentGiven,
                onChanged: (value) {
                  setState(() => _consentGiven = value ?? false);
                },
                title: const Text(
                  'I have read and agree to the facial recognition data collection and usage terms',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'By checking this box, you provide explicit consent for facial data processing.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleConsent,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Accept & Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
