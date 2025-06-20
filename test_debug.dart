import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Simple debug script to test database connection
void main() async {
  try {
    print('🔍 Starting database debug check...');
    
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://ynbqmmkjmvtwrbtqxjhi.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InluYnFtbWtqbXZ0d3JidHF4amhpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5MDA1ODQsImV4cCI6MjA1MDQ3NjU4NH0.tEQ9IqI3sZp3pV4bL3sPBxvJJOWxvlNH9RdAF3zBaHw',
    );
    
    final supabase = Supabase.instance.client;
    print('✅ Supabase initialized');
    
    // Check user_profiles table
    print('\n👥 Checking user_profiles table...');
    final profiles = await supabase
        .from('user_profiles')
        .select('*')
        .limit(10);
    
    print('📊 Found ${profiles.length} user profiles:');
    for (int i = 0; i < profiles.length; i++) {
      final profile = profiles[i];
      print('   $i. ID: ${profile['id']?.toString().substring(0, 8)}..., Name: "${profile['name']}", Email: "${profile['email']}"');
    }
    
    // Check community_posts table
    print('\n📋 Checking community_posts table...');
    final posts = await supabase
        .from('community_posts')
        .select('*')
        .limit(10);
    
    print('📊 Found ${posts.length} community posts:');
    for (int i = 0; i < posts.length; i++) {
      final post = posts[i];
      final content = post['content']?.toString() ?? '';
      final shortContent = content.length > 30 ? '${content.substring(0, 30)}...' : content;
      print('   $i. ID: ${post['id']}, User ID: ${post['user_id']?.toString().substring(0, 8)}..., Content: "$shortContent"');
    }
    
    // Check relationships
    print('\n🔗 Checking relationships...');
    final postUserIds = posts
        .map((p) => p['user_id']?.toString())
        .where((id) => id != null)
        .toSet()
        .cast<String>()
        .toList();
    
    final profileUserIds = profiles
        .map((p) => p['id']?.toString())
        .where((id) => id != null)
        .toSet()
        .cast<String>()
        .toList();
    
    print('📊 User IDs in posts: ${postUserIds.length}');
    print('📊 User IDs in profiles: ${profileUserIds.length}');
    
    final missingProfiles = postUserIds
        .where((id) => !profileUserIds.contains(id))
        .toList();
    
    if (missingProfiles.isEmpty) {
      print('✅ All post user IDs have corresponding profiles');
    } else {
      print('❌ Posts with missing profiles (${missingProfiles.length}):');
      for (final id in missingProfiles) {
        print('   - ${id.substring(0, 8)}...');
      }
    }
    
    // Test manual join
    if (postUserIds.isNotEmpty) {
      final testUserId = postUserIds.first;
      print('\n🧪 Testing manual join for user: ${testUserId.substring(0, 8)}...');
      
      final profile = await supabase
          .from('user_profiles')
          .select('name, email')
          .eq('id', testUserId)
          .maybeSingle();
      
      if (profile != null) {
        print('✅ Manual join successful: ${profile['name']}');
      } else {
        print('❌ Manual join failed: no profile found');
      }
    }
    
    print('\n🎯 Debug check completed!');
    
  } catch (e) {
    print('❌ Error: $e');
  }
  
  exit(0);
}
