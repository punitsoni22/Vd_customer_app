import 'package:flutter/material.dart';
import 'package:vd_customer_app/theme/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? colors;
  final TextStyle? textStyle;
  final bool islineNeeded;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.colors,
    this.textStyle,
    required this.islineNeeded,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: colors ?? AllColors.backgroundColor,
      toolbarHeight: 80,
      centerTitle: true,
      title: Text(
        title,
        style:
            textStyle ??
            TextStyle(
              color: AllColors.buttonColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
      ),
      leading: leading,
      actions: actions,
      bottom: islineNeeded
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(color: Colors.grey.shade300, height: 1.0),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
