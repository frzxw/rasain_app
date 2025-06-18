import 'package:flutter/material.dart';
import '../core/config/supabase_config.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  String _testResult = 'Belum ditest...';
  bool _isLoading = false;

  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing connection...';
    });

    try {
      // Test langsung ke table recipes
      final response = await SupabaseConfig.client
          .from('recipes')
          .select('id, title, description')
          .limit(5);

      setState(() {
        _testResult = '''
✅ SUCCESS! Found ${response.length} recipes:

${response.map((recipe) => '• ${recipe['title']}: ${recipe['description']}').join('\n')}

Database connection working perfectly!
        ''';
      });
    } catch (e) {
      setState(() {
        _testResult = '''
❌ ERROR: $e

This indicates a database permission issue.
        ''';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testDatabaseConnection,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Test Database Connection'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResult,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
