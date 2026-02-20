import 'package:flutter/material.dart';
import 'buttom_tab_item.dart';

class CustomBottomNav extends StatelessWidget {
  final List<BottomTabItem> tabs;
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final centerIndex = tabs.indexWhere((e) => e.isCenter);

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          if (i == centerIndex) {
            return _centerButton(i);
          }
          return _navItem(i);
        }),
      ),
    );
  }

  Widget _navItem(int index) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 65 : 45,
            height: isActive ? 55 : 45,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xffE0712D) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: ColorFiltered(
                colorFilter: isActive
                    ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                    : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: tabs[index].icon,
              ),
            ),
          ),
          if (!isActive)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                tabs[index].label,
                style: const TextStyle(fontSize: 11,  color: Color(0xffE0712D)),
              ),
            )
        ],
      ),
    );
  }

  Widget _centerButton(int index) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 65 : 45,
            height: isActive ? 55 : 45,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xffE0712D) : Colors.transparent,
              borderRadius: BorderRadius.circular(15),

            ),
            child: Center(
              child: ColorFiltered(
                colorFilter: isActive
                    ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                    : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: tabs[index].icon,
              ),
            ),
          ),
          if (!isActive)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                tabs[index].label,
                style: const TextStyle(fontSize: 11,  color: Color(0xffE0712D)),
              ),
            )
        ],
      ),
    );
  }
}
