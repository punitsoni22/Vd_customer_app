import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/colors.dart';

class NavigationBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavigationBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = <_BottomItem>[
    _BottomItem(label: 'Home', icon: Icons.grid_view_rounded),
    _BottomItem(label: 'Product', icon: Icons.inventory_2_outlined),
    _BottomItem(label: 'Subscription', icon: Icons.add),
    _BottomItem(label: 'Cart', icon: Icons.shopping_cart_outlined),
    _BottomItem(label: 'Profile', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedColor = AllColors.buttonColor;
    final unselectedColor = Color(0xFF2F3A40);
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(26.r),
        topRight: Radius.circular(26.r),
      ),
      child: Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final totalW = c.maxWidth;
            final itemW = totalW / _items.length;
            final indicatorW = 30.w;

            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  top: 0,
                  left: currentIndex * itemW + (itemW - indicatorW) / 2,
                  child: Container(
                    width: indicatorW,
                    height: 3,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                Row(
                  children: List.generate(_items.length, (i) {
                    final item = _items[i];
                    final selected = i == currentIndex;

                    return Expanded(
                      child: InkWell(
                        onTap: () => onTap(i),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _IconWithExtras(
                                item: item,
                                color: selected
                                    ? selectedColor
                                    : unselectedColor,
                              ),

                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: selected
                                      ? selectedColor
                                      : unselectedColor,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}

class _IconWithExtras extends StatelessWidget {
  final _BottomItem item;
  final Color color;

  const _IconWithExtras({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    if (item.label == 'Subscription') {
      return Container(
        width: 26.w,
        height: 26.h,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF39434A),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.add, size: 20.sp, color: Colors.white),
      );
    }

    return Icon(item.icon, size: 24.w, color: color);
  }
}

class _BottomItem {
  final String label;
  final IconData icon;

  const _BottomItem({required this.label, required this.icon});
}
