# Perbaikan Masalah Login - Authentication Race Condition

## Masalah yang Ditemukan

### 1. Race Condition dalam AuthService

- **Masalah**: Metode `login()` tidak menunggu listener `onAuthStateChange` selesai memproses
- **Dampak**: AuthCubit melakukan check `isAuthenticated` sebelum user profile selesai dimuat
- **Gejala**: Login tampak gagal meskipun autentikasi berhasil di Supabase

### 2. Timing Issue di AuthCubit

- **Masalah**: AuthCubit langsung mengecek `_authService.isAuthenticated` tanpa menunggu profile loading
- **Dampak**: State `authenticated` di-emit sebelum user profile benar-benar dimuat
- **Gejala**: User baru terdeteksi ketika berpindah ke halaman profile

### 3. Tidak Ada Sinkronisasi

- **Masalah**: Tidak ada mekanisme untuk menunggu semua proses autentikasi selesai
- **Dampak**: Inconsistent state antara AuthService dan AuthCubit

## Solusi yang Diterapkan

### 1. Perbaikan AuthService

#### A. Membuat Handler Auth State Change Asinkron

```dart
// Handle auth state changes
void _handleAuthStateChange(AuthState event) async {
  if (event.event == AuthChangeEvent.signedIn) {
    await _loadUserProfile(event.session?.user.id);
  } else if (event.event == AuthChangeEvent.signedOut) {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
```

#### B. Menambahkan Waiting Mechanism

```dart
// Wait for auth state processing to complete
Future<void> _waitForAuthStateProcessing() async {
  int attempts = 0;
  const maxAttempts = 50; // 5 seconds max wait
  const delayMs = 100;

  while (attempts < maxAttempts) {
    if (_isAuthenticated && _currentUser != null) {
      return; // Auth processing complete
    }
    await Future.delayed(const Duration(milliseconds: delayMs));
    attempts++;
  }

  // Force load profile if user exists but profile not loaded
  final user = _supabase.auth.currentUser;
  if (user != null && _currentUser == null) {
    await _loadUserProfile(user.id);
  }
}
```

#### C. Perbaikan Metode signInWithEmail

```dart
Future<void> signInWithEmail(String email, String password) async {
  _setLoading(true);
  try {
    final AuthResponse res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (res.user == null) {
      _setError('Sign in failed: No user returned.');
      return;
    }

    // Wait for auth state change to complete loading user profile
    await _waitForAuthStateProcessing();

  } on AuthException catch (e) {
    _setError(e.message);
    rethrow;
  } catch (e) {
    _setError('An unexpected error occurred during sign in.');
    rethrow;
  } finally {
    _setLoading(false);
  }
}
```

#### D. Perbaikan Metode login

```dart
Future<bool> login(String email, String password) async {
  try {
    await signInWithEmail(email, password);

    // Double check authentication state after sign in
    return _isAuthenticated && _currentUser != null;
  } catch (e) {
    debugPrint('Login error: $e');
    return false;
  }
}
```

### 2. Perbaikan AuthCubit

#### A. Robust Sign In Method

```dart
Future<bool> signIn(String email, String password) async {
  emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
  try {
    final success = await _authService.login(email, password);

    if (success && _authService.currentUser != null) {
      emit(
        state.copyWith(
          user: _authService.currentUser,
          status: AuthStatus.authenticated,
          errorMessage: null,
        ),
      );
      return true;
    } else {
      // Give one more chance - sometimes there's a slight delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (_authService.isAuthenticated && _authService.currentUser != null) {
        emit(
          state.copyWith(
            user: _authService.currentUser,
            status: AuthStatus.authenticated,
            errorMessage: null,
          ),
        );
        return true;
      }

      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _authService.error ?? "Login failed - please try again",
        ),
      );
      return false;
    }
  } catch (e) {
    emit(
      state.copyWith(
        status: AuthStatus.error,
        errorMessage: "Login error: ${e.toString()}"
      ),
    );
    return false;
  }
}
```

#### B. Perbaikan Initialize Method

```dart
Future<void> initialize() async {
  emit(state.copyWith(status: AuthStatus.loading));
  try {
    final isLoggedIn = await _authService.checkAuth();

    if (isLoggedIn && _authService.currentUser != null) {
      emit(
        state.copyWith(
          user: _authService.currentUser,
          status: AuthStatus.authenticated,
        ),
      );
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  } catch (e) {
    emit(
      state.copyWith(
        status: AuthStatus.error,
        errorMessage: "Authentication check failed: ${e.toString()}"
      ),
    );
  }
}
```

### 3. Perbaikan AuthDialog

#### A. Handling Return Value dari signIn

```dart
ElevatedButton(
  onPressed: state.status == AuthStatus.loading ? null : () async {
    if (formKey.currentState!.validate()) {
      final success = await context.read<AuthCubit>().signIn(
        emailController.text.trim(),
        passwordController.text,
      );

      // Check if login was successful
      if (success && context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil masuk!'),
            backgroundColor: Colors.green,
          ),
        );
        if (onLoginSuccess != null) {
          onLoginSuccess();
        }
      }
    }
  },
  child: const Text('Masuk'),
),
```

### 4. Perbaikan LoginScreen

#### A. Menggunakan BlocListener dan BlocBuilder

```dart
return BlocListener<AuthCubit, auth_state.AuthState>(
  listener: (context, state) {
    if (state.status == auth_state.AuthStatus.error) {
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      }
    }
  },
  child: BlocBuilder<AuthCubit, auth_state.AuthState>(
    builder: (context, state) {
      final isLoading = (state.status == auth_state.AuthStatus.loading) || _isLoading;
      // ... UI components
    },
  ),
);
```

## Hasil Perbaikan

### 1. Login Konsisten

- Login sekarang berhasil dengan data yang benar
- Tidak ada lagi masalah "login failed" pada data yang valid
- State authentication konsisten di seluruh aplikasi

### 2. Error Handling yang Lebih Baik

- Error message yang lebih deskriptif
- Loading state yang tepat
- UI feedback yang responsif

### 3. Reliability yang Meningkat

- Mengatasi race condition antara auth state dan profile loading
- Sinkronisasi yang tepat antara AuthService dan AuthCubit
- Fallback mechanism untuk edge cases

### 4. User Experience yang Lebih Baik

- Loading indicator yang akurat
- Error display yang jelas
- Success feedback yang tepat waktu

## Testing

Untuk menguji perbaikan:

1. **Test Login Normal**:

   ```
   Email: test@example.com
   Password: password123
   ```

2. **Test Login dengan Data Salah**:

   - Pastikan error message muncul dengan jelas
   - UI tetap responsive

3. **Test Navigation**:

   - Login berhasil langsung redirect
   - Profile page menampilkan user data dengan benar

4. **Test State Consistency**:
   - Pindah antar halaman tidak mengubah status login
   - Refresh aplikasi tetap maintain login state

## PowerShell Commands yang Digunakan

Untuk cleanup dan deployment:

```powershell
# Menghapus file korup dan replace dengan yang baru
Remove-Item "path\to\corrupted\file.dart" -Force
Move-Item "path\to\new\file.dart" "path\to\target\file.dart"

# Menjalankan aplikasi
flutter run -d windows
```
