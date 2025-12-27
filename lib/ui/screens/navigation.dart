import 'package:flutter/material.dart';
import 'package:nanonime/ui/screens/manga/manga.dart';
import 'package:nanonime/ui/screens/schedule/schedule.dart';
import '../../core/theme/colors.dart';
import 'main.dart';
import 'settings/settings.dart';

/// Main navigation wrapper with ultra-modern bottom navigation bar
class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({Key? key}) : super(key: key);

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    MainScreen(),
    ScheduleScreen(),
    MangaScreen(),
    SettingsScreen(),
  ];

  final List<_NavItemData> _navItems = const [
    _NavItemData(icon: Icons.home_rounded, label: 'Home'),
    _NavItemData(icon: Icons.explore_rounded, label: 'Explore'),
    _NavItemData(icon: Icons.bookmarks_rounded, label: 'Library'),
    _NavItemData(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navItems.length,
                (index) => _buildNavItem(
                  data: _navItems[index],
                  index: index,
                  isSelected: _currentIndex == index,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required _NavItemData data,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                child: Icon(
                  data.icon,
                  color: isSelected ? AppColors.primary : Colors.grey.shade600,
                  size: isSelected ? 27 : 24,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.grey.shade600,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: isSelected ? 0.3 : 0,
                ),
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;

  const _NavItemData({required this.icon, required this.label});
}
