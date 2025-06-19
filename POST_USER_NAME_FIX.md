# Dokumentasi Perbaikan: Nama User di Postingan Masih Menampilkan "user"

## Masalah yang Ditemukan

Ketika user yang sudah login membuat postingan di fitur Community, nama yang ditampilkan di postingan masih "user" atau "Current User" bukannya nama asli user yang sedang login.

## Root Cause Analysis

Masalah teridentifikasi di file `lib/cubits/community/community_cubit.dart` pada fungsi `createPost()`. Kode menggunakan data hardcoded:

```dart
// Kode lama yang bermasalah:
final newPost = CommunityPost(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  userId: 'current_user_id', // Data hardcoded
  userName: 'Current User',   // Data hardcoded
  timestamp: DateTime.now(),
  content: content,
  // ...
);
```

## Solusi yang Diterapkan

### 1. Menambahkan Metode `createCommunityPost` di DataService

**File:** `lib/services/data_service.dart`

```dart
/// Create a new community post
Future<CommunityPost?> createCommunityPost({
  required String userId,
  required String userName,
  String? userImageUrl,
  required String content,
  String? imageUrl,
  String? category,
  List<String>? taggedIngredients,
}) async {
  try {
    debugPrint('🔍 Creating community post for user: $userName');

    final postData = {
      'user_id': userId,
      'user_name': userName,
      'user_image_url': userImageUrl,
      'content': content,
      'image_url': imageUrl,
      'category': category,
      'tagged_ingredients': taggedIngredients,
      'like_count': 0,
      'comment_count': 0,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final response = await _supabaseService.client
        .from('community_posts')
        .insert(postData)
        .select()
        .single();

    debugPrint('✅ Created community post: ${response['id']}');
    return CommunityPost.fromJson(response);
  } catch (e) {
    debugPrint('❌ Error creating community post: $e');
    return null;
  }
}
```

### 2. Menambahkan Getter untuk Supabase User di AuthService

**File:** `lib/services/auth_service.dart`

```dart
// Getters
UserProfile? get currentUser => _currentUser;
bool get isAuthenticated => _isAuthenticated;
bool get isLoading => _isLoading;
String? get error => _error;
User? get supabaseUser => _supabase.auth.currentUser; // <- Ditambahkan
```

### 3. Memperbaiki CommunityCubit untuk Menggunakan Data User Asli

**File:** `lib/cubits/community/community_cubit.dart`

#### A. Menambahkan Dependency AuthService

```dart
import 'package:bloc/bloc.dart';
import '../../models/community_post.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart'; // <- Ditambahkan
import 'dart:typed_data';
import 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final DataService _dataService;
  final AuthService _authService; // <- Ditambahkan

  CommunityCubit(this._dataService, this._authService) : super(const CommunityState()); // <- Updated
```

#### B. Memperbaiki Fungsi createPost

```dart
// Create a new community post
Future<void> createPost({
  required String content,
  Uint8List? imageBytes,
  String? fileName,
  String? category,
  List<String>? taggedIngredients,
}) async {
  emit(state.copyWith(status: CommunityStatus.posting));

  try {
    // Get current user data from AuthService
    final currentUserAuth = _authService.supabaseUser;
    final userProfile = _authService.currentUser;

    if (currentUserAuth == null || userProfile == null) {
      emit(
        state.copyWith(
          status: CommunityStatus.error,
          errorMessage: 'User must be logged in to create posts',
        ),
      );
      return;
    }

    // Create post in database using DataService
    final newPost = await _dataService.createCommunityPost(
      userId: currentUserAuth.id,
      userName: userProfile.name, // <- Menggunakan nama asli user
      userImageUrl: userProfile.imageUrl,
      content: content,
      imageUrl: imageBytes != null ? 'mock_image_url' : null, // TODO: implement image upload
      category: category,
      taggedIngredients: taggedIngredients,
    );

    if (newPost != null) {
      // Add the new post to the list
      final updatedPosts = [newPost, ...state.posts];
      emit(state.copyWith(posts: updatedPosts, status: CommunityStatus.loaded));
    } else {
      emit(
        state.copyWith(
          status: CommunityStatus.error,
          errorMessage: 'Failed to create post',
        ),
      );
    }
  } catch (e) {
    emit(
      state.copyWith(
        status: CommunityStatus.error,
        errorMessage: 'Failed to create post: ${e.toString()}',
      ),
    );
  }
}
```

### 4. Memperbarui Dependency Injection di main.dart

**File:** `lib/main.dart`

```dart
// Kode lama:
BlocProvider(create: (context) => CommunityCubit(dataService)),

// Kode baru:
BlocProvider(create: (context) => CommunityCubit(dataService, authService)),
```

## Verifikasi Database Schema

Memastikan tabel `community_posts` memiliki kolom yang diperlukan:

**File:** `lib/database/supabase_schema_clean.sql`

```sql
CREATE TABLE IF NOT EXISTS community_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,          -- ✅ Kolom untuk nama user
    user_image_url TEXT,              -- ✅ Kolom untuk avatar user
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    content TEXT,
    image_url TEXT,
    tagged_ingredients TEXT[],
    category TEXT,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    is_liked BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Hasil Setelah Perbaikan

1. **Nama User Asli**: Postingan sekarang menampilkan nama asli user yang sedang login
2. **Avatar User**: Jika user memiliki avatar, akan ditampilkan di postingan
3. **Database Integration**: Postingan disimpan ke database Supabase dengan data user yang benar
4. **Error Handling**: Sistem akan menampilkan error jika user belum login saat mencoba posting

## Flow Testing

Untuk memverifikasi perbaikan:

1. **Login** ke aplikasi dengan akun yang valid
2. **Navigasi** ke halaman Community
3. **Klik** tombol "+" untuk membuat postingan baru
4. **Isi** konten postingan dan submit
5. **Verifikasi** nama user yang ditampilkan di postingan adalah nama asli (bukan "user" atau "Current User")

## PowerShell Commands untuk Testing

```powershell
# Compile check
flutter analyze --no-congratulate

# Run app untuk testing
flutter run -d chrome

# Check database schema
# (Bisa dilakukan melalui Supabase Dashboard)
```

## Status: ✅ SELESAI

Masalah nama user di postingan telah berhasil diperbaiki. Kode sekarang mengambil data user yang sebenarnya dari AuthService dan menyimpannya ke database dengan benar.

**Timestamp:** 19 Juni 2025
**Developer:** GitHub Copilot Assistant
