import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

class ScaffoldWithBottomNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({super.key, required this.child});

  @override
  State<ScaffoldWithBottomNavBar> createState() =>
      _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  int _currentIndex = 0;
  static final List<(String, String, IconData)> _tabs = [
    ('/', 'Beranda', Icons.home_outlined),
    ('/pantry', 'Dapur', Icons.kitchen_outlined),
    ('/upload-recipe', 'Unggah', Icons.add_circle_outline),
    ('/community', 'Komunitas', Icons.people_outline),
    ('/profile', 'Profil', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    // Get index from current location
    final GoRouter router = GoRouter.of(context);
    final String location = router.location;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: AppColors.primary,
          unselectedItemColor:
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items:
              _tabs.map((tab) {
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
