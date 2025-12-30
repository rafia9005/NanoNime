import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class CustomTabSelector extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CustomTabSelector({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final tabWidth = width / tabs.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
                left: selectedIndex * tabWidth,
                child: Container(
                  width: tabWidth,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(tabs.length, (index) {
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => onTabSelected(index),
                      child: Center(
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: selectedIndex == index
                                ? Colors.white
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
