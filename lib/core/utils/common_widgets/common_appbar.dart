import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum BarTitleAlignment { left, center }

const _mint = Color(0xFF6C8E82);
const _hairline = Color(0x1A000000);

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final BarTitleAlignment titleAlignment;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  final double height;
  final EdgeInsets padding;
  final double leadingWidth;
  final double leadingGap;

  final Color? backgroundColor;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final bool showBottomLine;

  const CommonAppBar({
    super.key,
    required this.title,
    this.titleAlignment = BarTitleAlignment.left,
    this.showBack = false,
    this.onBack,
    this.actions,
    this.height = 40,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.leadingWidth = 48,
    this.leadingGap = 8,
    this.backgroundColor,
    this.iconColor,
    this.titleStyle,
    this.showBottomLine = true,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.white;
    final fg = iconColor ?? _mint;

    final double leftTitleInset =
        (titleAlignment == BarTitleAlignment.left && showBack)
        ? (leadingWidth + leadingGap)
        : 0;

    final titleWidget = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style:
          titleStyle ??
          TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: fg,
            letterSpacing: 0.2,
          ),
    );

    final content = SafeArea(
      bottom: false,
      child: Container(
        color: bg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height,
              child: Padding(
                padding: padding,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (showBack)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: leadingWidth,
                          child: IconButton(
                            splashRadius: 22,
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 22,
                            ),
                            color: fg,
                            onPressed:
                                onBack ?? () => Navigator.maybePop(context),
                          ),
                        ),
                      ),
                    Align(
                      alignment: titleAlignment == BarTitleAlignment.center
                          ? Alignment.center
                          : Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: leftTitleInset),
                        child: titleWidget,
                      ),
                    ),
                    if (actions != null && actions!.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (showBottomLine) Container(height: 1, color: _hairline),
          ],
        ),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: bg,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Material(color: bg, child: content),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + (showBottomLine ? 1 : 0));
}

class BarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final double size;
  final bool tinyDot;

  const BarIcon({
    super.key,
    required this.icon,
    this.onTap,
    this.color = _mint,
    this.size = 24,
    this.tinyDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final btn = IconButton(
      splashRadius: 22,
      icon: Icon(icon, size: size.sp, color: color),
      onPressed: onTap,
    );

    if (!tinyDot) return btn;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        btn,
        Positioned(
          right: 10,
          bottom: 10,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A3D),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
