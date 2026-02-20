import 'package:flutter_svg/flutter_svg.dart';
import 'package:care_agent/features/medicine/screen/medicine_screen.dart';
import 'package:care_agent/features/doctor/screen/doctor_screen.dart';
import 'package:care_agent/features/profile/screen/profile_screen.dart';
import '../../features/home/ui/screen/home_screen.dart';
import '../../features/home/ui/screen/notification_screen.dart';
import 'buttom_tab_item.dart';

final List<BottomTabItem> bottomTabs = [
  BottomTabItem(
    label: "Home",
    icon: SvgPicture.asset("assets/homes.svg"),
    page: HomeScreen(),
    isCenter: true,
  ),
  BottomTabItem(
    label: "Medicine",
    icon: SvgPicture.asset("assets/medicine.svg"),
    page: MedicineScreen(),
  ),
  BottomTabItem(
    label: "Doctor",
    icon: SvgPicture.asset("assets/doctor.svg"),
    page: DoctorScreen(),
  ),
  BottomTabItem(
    label: "Chat",
    icon: SvgPicture.asset("assets/chat.svg"),
    page: NotificationScreen(),
  ),
  BottomTabItem(
    label: "Profile",
    icon: SvgPicture.asset("assets/profile.svg"),
    page: ProfileScreen(),
  ),
];
