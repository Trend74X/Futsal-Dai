import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:futsal_dai/src/helper/styles.dart';
import 'package:futsal_dai/src/views/owner/owner_dashboard.dart';
import 'package:futsal_dai/src/views/player/player_bookings.dart';
import 'package:futsal_dai/src/views/player/player_profile.dart';

class OwnerBottomsheet extends StatefulWidget {
  const OwnerBottomsheet({super.key});

  @override
  State<OwnerBottomsheet> createState() => _OwnerBottomsheetState();
}

class _OwnerBottomsheetState extends State<OwnerBottomsheet> {

  int _currentIndex = 0;

  // Replace these placeholders with your actual screen widgets
  final List<Widget> _screens = [
    OwnerDashboard(),
    PlayerBookingPage(),
    PlayerProfilePage(),
  ];

  final Color indicatorColor = const Color(0xFF1B4D14); // Dark green pill background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // decoration: bgImg(),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        // Matches the top rounded corner radius seen in your design
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          // clipBehavior: Clip.antiAlias,
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF0D1B0A), // Slightly lighter container background
          indicatorColor: indicatorColor,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          // height: 80, 
          destinations: [
            NavigationDestination(
              icon: _buildCustomTab(
                isSelected: _currentIndex == 0,
                iconPath: 'assets/icons/dashboard.svg',
                label: 'Dashboard',
                activeColor: Color(0xFF1B4D14),
                inactiveColor: subtitleTextColor,
                indicatorColor: Color(0xFF79FF5B),
              ),
              label: '', // Left blank because we built it into the custom tab
            ),
            NavigationDestination(
              icon: _buildCustomTab(
                isSelected: _currentIndex == 1,
                iconPath: 'assets/icons/booking.svg',
                label: 'Bookings',
                activeColor: Color(0xFF1B4D14),
                inactiveColor: subtitleTextColor,
                indicatorColor: Color(0xFF79FF5B),
              ),
              label: '',
            ),
            NavigationDestination(
              icon: _buildCustomTab(
                isSelected: _currentIndex == 2,
                iconPath: 'assets/icons/profile.svg',
                label: 'Profile',
                activeColor: Color(0xFF1B4D14),
                inactiveColor: subtitleTextColor,
                indicatorColor: Color(0xFF79FF5B),
              ),
              label: '',
            ),
          ],
          // Styling the text labels to match your custom theme colors
          animationDuration: const Duration(milliseconds: 300),
        ),
      )
    );
  }

  Widget _buildCustomTab({
    required bool isSelected,
    required String iconPath,
    required String label,
    required Color activeColor,
    required Color inactiveColor,
    required Color indicatorColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        // Applies the background color to the WHOLE block if selected
        color: isSelected ? indicatorColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            colorFilter: ColorFilter.mode(
              isSelected ? activeColor : inactiveColor, 
              BlendMode.srcIn,
            ),
            height: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }

}