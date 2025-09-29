import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/colors.dart';

class NavigationBottomBar extends StatelessWidget {
  final int currentIndex;
  final int? visibleItemCount;
  final ValueChanged<int> onTap;

  const NavigationBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.visibleItemCount,
  });

  static const _allItems = <_BottomItem>[
    _BottomItem(label: 'Home', icon: Icons.grid_view_rounded),
    _BottomItem(label: 'Product', icon: Icons.inventory_2_outlined),
    _BottomItem(label: 'Subscription', icon: Icons.add),
    _BottomItem(label: 'Cart', icon: Icons.shopping_cart_outlined),
    _BottomItem(label: 'Profile', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final items = _allItems.take(visibleItemCount ?? _allItems.length).toList();

    final selectedColor = AllColors.buttonColor;
    const unselectedColor = Color(0xFF2F3A40);

    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(top: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kBottomNavigationBarHeight,
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final totalW = c.maxWidth;
              final itemW = totalW / items.length;
              const indicatorH = 3.0;
              const indicatorW = 30.0;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    top: 0,
                    left: currentIndex * itemW + (itemW - indicatorW) / 2,
                    child: Container(
                      width: indicatorW,
                      height: indicatorH,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  Row(
                    children: List.generate(items.length, (i) {
                      final item = items[i];
                      final selected = i == currentIndex;

                      return Expanded(
                        child: InkWell(
                          onTap: () => onTap(i),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 4.w,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _IconWithExtras(
                                  item: item,
                                  color: selected
                                      ? selectedColor
                                      : unselectedColor,
                                ),
                                SizedBox(height: 4.h),
                                DefaultTextStyle.merge(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: selected
                                        ? selectedColor
                                        : unselectedColor,
                                  ),
                                  child: Text(item.label, softWrap: false),
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
    const iconSize = 24.0;

    if (item.label == 'Subscription') {
      return Container(
        width: 28.w,
        height: 28.h,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF39434A),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.add, size: 22.sp, color: Colors.white),
      );
    }

    return Icon(item.icon, size: iconSize, color: color);
  }
}

class _BottomItem {
  final String label;
  final IconData icon;

  const _BottomItem({required this.label, required this.icon});
}
