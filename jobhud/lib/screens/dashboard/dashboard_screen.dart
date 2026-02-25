import 'package:flutter/material.dart';
import 'package:jobhud/screens/dashboard/explore_jobs_screen.dart';
import 'package:jobhud/screens/dashboard/saved_jobs_screen.dart';
import 'package:jobhud/screens/dashboard/interview_prep_screen.dart';
import 'package:jobhud/screens/dashboard/profile_screen.dart';
import 'package:jobhud/screens/dashboard/tech_trends_screen.dart';
import 'package:jobhud/screens/dashboard/daily_tip_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const ExploreJobsScreen(),
    const SavedJobsScreen(),
    const TechTrendsScreen(),
    const DailyTipScreen(),
    const InterviewPrepScreen(companyName: 'Interview', position: 'Preparation'),
    const ProfileScreen(),
  ];
  
  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.explore_outlined),
      activeIcon: Icon(Icons.explore),
      label: 'Explore',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.bookmark_border),
      activeIcon: Icon(Icons.bookmark),
      label: 'Saved',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.trending_up_outlined),
      activeIcon: Icon(Icons.trending_up),
      label: 'Tech Trends',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.lightbulb_outline),
      activeIcon: Icon(Icons.lightbulb),
      label: 'Daily Tips',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.assignment_outlined),
      activeIcon: Icon(Icons.assignment),
      label: 'Interview',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: _bottomNavItems,
      ),
    );
  }
}
