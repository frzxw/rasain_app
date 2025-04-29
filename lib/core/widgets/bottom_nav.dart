import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

class ScaffoldWithBottomNavBar extends StatefulWidget {
  final Widget child;
  
  const ScaffoldWithBottomNavBar({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ScaffoldWithBottomNavBar> createState() => _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  int _currentIndex = 0;

  static final List<(String, String, IconData)> _tabs = [
    ('/', 'Home', Icons.home_outlined),
    ('/pantry', 'Pantry', Icons.kitchen_outlined),
    ('/chat', 'Chat', Icons.chat_outlined),
    ('/community', 'Community', Icons.people_outline),
    ('/profile', 'Profile', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    // Get index from current location
    final GoRouter router = GoRouter.of(context);
    final String location = router.location;
    
    _currentIndex = _getIndexFromLocation(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => _onItemTapped(index, router),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: _tabs.map((tab) {
            return BottomNavigationBarItem(
              icon: Icon(tab.$3),
              label: tab.$2,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onItemTapped(int index, GoRouter router) {
    // If already on the page, don't navigate
    if (index == _currentIndex) return;
    
    // Navigate to selected tab
    router.go(_tabs[index].$1);
    
    setState(() {
      _currentIndex = index;
    });
  }

  int _getIndexFromLocation(String location) {
    final index = _tabs.indexWhere((tab) => location == tab.$1);
    return index >= 0 ? index : 0;
  }
}
