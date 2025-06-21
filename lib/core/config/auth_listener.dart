import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../cubits/auth/auth_cubit.dart';

class AuthListener {
  final AuthService _authService;
  final AuthCubit _authCubit;

  AuthListener(this._authService, this._authCubit) {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    print('AuthListener: Initializing auth state listener');

    // Listen to Supabase auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      print('AuthListener: Auth state changed - Event: $event');

      switch (event) {
        case AuthChangeEvent.signedIn:
          print('AuthListener: User signed in via deep link or direct');
          _handleSignedIn(session);
          break;
        case AuthChangeEvent.signedOut:
          print('AuthListener: User signed out');
          _handleSignedOut();
          break;
        case AuthChangeEvent.tokenRefreshed:
          print('AuthListener: Token refreshed');
          break;
        case AuthChangeEvent.userUpdated:
          print('AuthListener: User updated');
          break;
        case AuthChangeEvent.passwordRecovery:
          print('AuthListener: Password recovery');
          break;
        default:
          print('AuthListener: Unknown auth event: $event');
      }
    });
  }

  void _handleSignedIn(Session? session) {
    if (session?.user != null) {
      print('AuthListener: Processing sign in for user: ${session!.user.id}');

      // Force refresh the auth service to load user profile
      _authService
          .checkAuth()
          .then((_) {
            print('AuthListener: Auth service updated after sign in');
            // Notify AuthCubit to refresh its state
            _authCubit.handleAuthStateChange();
          })
          .catchError((error) {
            print('AuthListener: Error updating auth service: $error');
          });
    }
  }

  void _handleSignedOut() {
    print('AuthListener: Processing sign out');
    // Auth service will handle this automatically through its own listener
  }
}
