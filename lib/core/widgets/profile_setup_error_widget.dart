import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../debug_check.dart';

class ProfileSetupErrorWidget extends StatelessWidget {
  final String? error;

  const ProfileSetupErrorWidget({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Profile Setup Incomplete',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ??
                'Your profile could not be created automatically. This may be due to database permissions.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await DebugCheck.fixUserProfilesIssues();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Profile fix attempted. Check console for details.',
                          ),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Fix failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.build),
                  label: const Text('Debug Fix'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final authService = context.read<AuthService>();
                    try {
                      await authService.retryProfileCreation();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile creation retried'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Retry failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Technical Details'),
                      content: SingleChildScrollView(
                        child: Text(
                          'This error typically occurs due to Row Level Security (RLS) policies in the database.\n\n'
                          'Solutions:\n'
                          '1. Run the SQL fix in Supabase dashboard\n'
                          '2. Check database permissions\n'
                          '3. Verify authentication is working\n\n'
                          'Error: ${error ?? "Unknown error"}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
            child: const Text(
              'Technical Details',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
