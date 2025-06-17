import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rasain_app/services/auth_service.dart';
import 'package:rasain_app/features/auth/login_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;

        if (index == 2) {
          // Pantry Screen index
          if (authService.currentUser == null) {
            // User is not logged in, show login prompt
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Login Required'),
                  content: const Text(
                    'You need to be logged in to access your pantry.',
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Login'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
            return; // Do not navigate
          }
        }

        switch (index) {
          case 0:
            // Navigate to Home
            break;
          case 1:
            // Navigate to Search
            break;
          case 2:
            // Navigate to Pantry
            break;
          case 3:
            // Navigate to Profile
            break;
        }
        onTap(index);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Pantry'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
