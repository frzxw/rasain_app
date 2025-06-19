# Dokumentasi Perbaikan Masalah Nama User di Postingan

## Masalah

Ketika user sudah login dan membuat postingan/ulasan, nama yang muncul di postingan masih menampilkan "user" atau "Current User" bukannya nama user yang sebenarnya.

## Root Cause

1. **CommunityCubit menggunakan data hardcoded**: Fungsi `createPost` di `CommunityCubit` menggunakan:

   ```dart
   userId: 'current_user_id', // hardcoded
   userName: 'Current User', // hardcoded
   ```

2. **Tidak ada integrasi dengan AuthService**: `CommunityCubit` tidak memiliki akses ke data user yang sedang login dari `AuthService`.

3. **Tidak ada metode untuk menyimpan post ke database**: Postingan hanya dibuat secara lokal tanpa disimpan ke Supabase.

## Solusi yang Diterapkan

### 1. Menambahkan metode `createCommunityPost` ke DataService

**File**: `lib/services/data_service.dart`

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

### 2. Menambahkan getter untuk Supabase User di AuthService

**File**: `lib/services/auth_service.dart`

```dart
// Getters
UserProfile? get currentUser => _currentUser;
bool get isAuthenticated => _isAuthenticated;
bool get isLoading => _isLoading;
String? get error => _error;
User? get supabaseUser => _supabase.auth.currentUser; // ✅ Ditambahkan
```

### 3. Memperbaiki CommunityCubit

**File**: `lib/cubits/community/community_cubit.dart`

#### a. Menambahkan dependency ke AuthService:

```dart
import '../../services/auth_service.dart'; // ✅ Ditambahkan

class CommunityCubit extends Cubit<CommunityState> {
  final DataService _dataService;
  final AuthService _authService; // ✅ Ditambahkan

  CommunityCubit(this._dataService, this._authService) : super(const CommunityState());
```

#### b. Memperbaiki fungsi createPost:

```dart
Future<void> createPost({
  required String content,
  Uint8List? imageBytes,
  String? fileName,
  String? category,
  List<String>? taggedIngredients,
}) async {
  emit(state.copyWith(status: CommunityStatus.posting));

  try {
    // ✅ Mengambil data user yang sebenarnya dari AuthService
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

    // ✅ Menggunakan data user yang sebenarnya
    final newPost = await _dataService.createCommunityPost(
      userId: currentUserAuth.id,
      userName: userProfile.name,
      userImageUrl: userProfile.imageUrl,
      content: content,
      imageUrl: imageBytes != null ? 'mock_image_url' : null,
      category: category,
      taggedIngredients: taggedIngredients,
    );

    if (newPost != null) {
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

### 4. Memperbarui dependency injection

**File**: `lib/main.dart`

```dart
// ✅ Menambahkan AuthService sebagai dependency untuk CommunityCubit
BlocProvider(create: (context) => CommunityCubit(dataService, authService)),
```

### 5. Memperbaiki syntax error di mock_data.dart

**File**: `lib/services/mock_data.dart`

Menambahkan closing brace yang hilang untuk class MockData.

## Struktur Database

Tabel `community_posts` sudah memiliki kolom yang diperlukan:

- `user_id`: UUID reference ke auth.users
- `user_name`: TEXT NOT NULL
- `user_image_url`: TEXT nullable
- `content`: TEXT untuk isi postingan
- `category`: TEXT untuk kategori
- `tagged_ingredients`: TEXT[] untuk bahan yang di-tag

## Hasil Setelah Perbaikan

1. ✅ Ketika user yang sudah login membuat postingan, nama user yang sebenarnya akan muncul
2. ✅ Postingan disimpan ke database Supabase dengan data user yang benar
3. ✅ User ID dan nama user diambil dari AuthService yang sudah terautentikasi
4. ✅ Tidak ada lagi hardcoded "Current User" atau "user"

## Testing

- ✅ Code berhasil di-compile tanpa syntax error
- ✅ Flutter analyze menunjukkan tidak ada error kritis
- 🔄 Testing manual sedang berlangsung untuk memastikan fitur berfungsi dengan benar

## Catatan

- Image upload masih menggunakan mock URL, implementasi upload gambar sebenarnya dapat ditambahkan kemudian
- Fitur ini memerlukan user sudah login untuk dapat membuat postingan
- Error handling telah ditambahkan untuk kasus user tidak login
