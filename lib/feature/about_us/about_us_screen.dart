import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/colors.dart';
import '../../core/utils/common_widgets/common_appbar.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'About Us',
        titleAlignment: BarTitleAlignment.center,
        showBack: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero / top (responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 800;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Our Story',
                                    style: TextStyle(
                                      color: AllColors.olivegreenColor,
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'We Started with a Real-Life Problem',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    "We did not begin with big plans. Our first batch was only 12 bottles made at home, filled with love and shared with neighbours and friends. Within a few days people came back asking for more — they felt lighter, digestion improved, mornings felt better.",
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Colors.grey.shade800,
                                      height: 1.6,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'Sign in to view your orders, manage subscriptions, and access exclusive features',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  Container(
                                    height: 180.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 8,
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/images/Bigbottle.png',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Container(
                                    height: 140.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/images/Bottlee.png',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Our Story',
                              style: TextStyle(
                                color: AllColors.olivegreenColor,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'We Started with a Real-Life Problem',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "We did not begin with big plans. Our first batch was only 12 bottles made at home, filled with love and shared with neighbours and friends. Within a few days people came back asking for more — they felt lighter, digestion improved, mornings felt better.",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade800,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 160.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 8,
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/images/Bigbottle.png',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Container(
                                    height: 160.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/images/Bottlee.png',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                },
              ),

              SizedBox(height: 18.h),

              // Cards for Promise / Mission / Vision — responsive three-column style
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  final cardHeight = isWide ? 320.h : null;
                  final cardWidth = isWide
                      ? (constraints.maxWidth - 48) / 3
                      : double.infinity;
                  final cards = [
                    {
                      'title': 'Our Promise',
                      'icon': 'assets/images/App_Icon.png',
                      'type': 'list',
                      'items': [
                        {
                          'label': '100% Natural',
                          'text':
                              'Made only with fresh, organic ingredients and purified water.',
                        },
                        {
                          'label': 'Honest & Thoughtful',
                          'text': 'Veedasip is born from care, not marketing.',
                        },
                        {
                          'label': 'Wellness With Purpose',
                          'text':
                              'More than a drink, Veedasip is a step toward helping our loved ones.',
                        },
                      ],
                    },
                    {
                      'title': 'Our Mission',
                      'icon': 'assets/images/Bigbottle.png',
                      'type': 'text',
                      'text':
                          'To have a natural detox without effort, without rising, and a bottle at a time. We are committed to making nature your choice on a day-to-day basis.',
                    },
                    {
                      'title': 'Our Vision',
                      'icon': 'assets/images/Bottlee.png',
                      'type': 'text',
                      'text':
                          'A better city where human beings resort to nature rather than to chemicals — detox as an easy daily routine.',
                    },
                  ];

                  return Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: cards.map((c) {
                      return SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 6),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 16.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // icon
                                Container(
                                  width: 70.w,
                                  height: 70.w,
                                  decoration: BoxDecoration(
                                    color: AllColors.profileBackColor,
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage(c['icon'] as String),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  c['title'] as String,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AllColors.olivegreenColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12.h),
                                // Avoid using Expanded inside an unbounded-height parent
                                // When `cardHeight` is provided (wide layouts) keep a
                                // scrollable ListView; otherwise render static Column/Text
                                if (cardHeight != null)
                                  Expanded(
                                    child: c['type'] == 'list'
                                        ? ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount:
                                                (c['items'] as List).length,
                                            itemBuilder: (ctx, i) {
                                              final it =
                                                  (c['items'] as List)[i];
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 8.h,
                                                ),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            '${it['label']}: ',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.black,
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: it['text'],
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey
                                                              .shade800,
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : SingleChildScrollView(
                                            child: Text(
                                              c['text'] as String,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey.shade800,
                                                height: 1.6,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                  )
                                else
                                  // Small / narrow layouts: render content without
                                  // Expanded or inner scrollables so height is intrinsic
                                  (c['type'] == 'list'
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: (c['items'] as List).map((
                                            it,
                                          ) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 8.h,
                                              ),
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: '${it['label']}: ',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.black,
                                                        fontSize: 14.sp,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: it['text'],
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey
                                                            .shade800,
                                                        fontSize: 14.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      : Text(
                                          c['text'] as String,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey.shade800,
                                            height: 1.6,
                                          ),
                                          textAlign: TextAlign.center,
                                        )),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              // SizedBox(height: 12.h),
              // LayoutBuilder(
              //   builder: (context, constraints) {
              //     // Use 5 cols on very wide, 3 on desktop, 2 on tablet/large phones,
              //     // and 1 only on very narrow screens.
              //     final cols = constraints.maxWidth >= 1100
              //         ? 5
              //         : constraints.maxWidth >= 800
              //         ? 3
              //         : constraints.maxWidth >= 500
              //         ? 2
              //         : 1;
              //     return GridView.count(
              //       crossAxisCount: cols,
              //       shrinkWrap: true,
              //       physics: NeverScrollableScrollPhysics(),
              //       crossAxisSpacing: 12.w,
              //       mainAxisSpacing: 12.h,
              //       childAspectRatio: 2.2,
              //       children: [
              //         _buildStatCard('1.2K', 'bottles delivered'),
              //         _buildStatCard('4.5', 'Average Customer Rating'),
              //         _buildStatCard('1.2K', 'Happy Households Hydrated'),
              //         _buildStatCard('100%', 'BPA-Free, Reusable Packaging'),
              //         _buildStatCard('24x7', 'Customer Support'),
              //       ],
              //     );
              //   },
              // ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, List items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AllColors.olivegreenColor,
              ),
            ),
            SizedBox(height: 8.h),
            ...items.map(
              (it) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${it['label']}: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 14.sp,
                        ),
                      ),
                      TextSpan(
                        text: it['text'],
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: AllColors.olivegreenColor,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
