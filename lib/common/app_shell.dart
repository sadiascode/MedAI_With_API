import 'package:care_agent/features/chat/screen/chats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../features/home/ui/screen/home_screen.dart';
import 'navbar/buttom_tab_item.dart';
import 'navbar/custom_bottom_nav.dart';
import '../features/medicine/screen/medicine_screen.dart';
import '../features/doctor/screen/doctor_screen.dart';
import '../features/profile/screen/profile_screen.dart';

class AppShell extends StatefulWidget {
  final int initialIndex;
  
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;
  late final List<BottomTabItem> _bottomTabs;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    

    _bottomTabs = [
      BottomTabItem(
        label: "Home",
        icon: SvgPicture.asset("assets/homes.svg"),
        page: const HomeScreenContent(),
        isCenter: true,
      ),
      BottomTabItem(
        label: "Medicine",
        icon: SvgPicture.asset("assets/medicine.svg"),
        page: const MedicineScreenContent(),
      ),
      BottomTabItem(
        label: "Doctor",
        icon: SvgPicture.asset("assets/doctor.svg"),
        page: const DoctorScreenContent(),
      ),
      BottomTabItem(
        label: "Chat",
        icon: SvgPicture.asset("assets/chat.svg"),
        page: const ChatsScreenContent(), // This is just a placeholder now
      ),
      BottomTabItem(
        label: "Profile",
        icon: SvgPicture.asset("assets/profile.svg"),
        page: const ProfileScreenContent(),
      ),
    ];
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate pages dynamically to pass current state (like isActive) to children
    final pages = [
      const HomeScreenContent(),
      const MedicineScreenContent(),
      const DoctorScreenContent(),
      ChatsScreenContent(isActive: _currentIndex == 3),
      const ProfileScreenContent(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        tabs: _bottomTabs,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class SubPageScaffold extends StatelessWidget {
  final Widget body;
  final int parentTabIndex;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;

  const SubPageScaffold({
    super.key,
    required this.body,
    required this.parentTabIndex,
    this.appBar,
    this.backgroundColor,
  });


  static List<BottomTabItem> get _bottomTabs => [
    BottomTabItem(
      label: "Home",
      icon: SvgPicture.asset("assets/homes.svg"),
      page: const SizedBox(),
      isCenter: true,
    ),
    BottomTabItem(
      label: "Medicine",
      icon: SvgPicture.asset("assets/medicine.svg"),
      page: const SizedBox(),
    ),
    BottomTabItem(
      label: "Doctor",
      icon: SvgPicture.asset("assets/doctor.svg"),
      page: const SizedBox(),
    ),
    BottomTabItem(
      label: "Chat",
      icon: SvgPicture.asset("assets/chat.svg"),
      page: const SizedBox(),
    ),
    BottomTabItem(
      label: "Profile",
      icon: SvgPicture.asset("assets/profile.svg"),
      page: const SizedBox(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFFFFFAF7),
      appBar: appBar,
      body: body,
      bottomNavigationBar: CustomBottomNav(
        tabs: _bottomTabs,
        currentIndex: parentTabIndex,
        onTap: (index) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => AppShell(initialIndex: index),
            ),
            (route) => false,
          );
        },
      ),
    );
  }
}
