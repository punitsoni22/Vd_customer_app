import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_button.dart';

class SubscriptionTabBar extends StatelessWidget {
  const SubscriptionTabBar({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          toolbarHeight: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: AllColors.olivegreenColor,
              indicatorColor: AllColors.tabBarline,
              tabs: [
                Tab(text: "Active Subscription"),
                Tab(text: "Inactive Subscription"),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            SubscriptionList(isActive: true),
            SubscriptionList(isActive: false),
          ],
        ),
      ),
    );
  }
}

class SubscriptionList extends StatelessWidget {
  final bool isActive;
  const SubscriptionList({super.key, required this.isActive});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 24, backgroundColor: Colors.amber),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AquaFlow 20L Purified Water",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        isActive ? "Active" : "Pause",
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.loop, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text("Frequency: Weekly"),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.local_drink, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text("Quantity: 2 Cans"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text("Next: June 25, 2024"),
                    ],
                  ),
                  Text("Remaining: 10 Deliveries"),
                ],
              ),
              SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  CommonButton(
                    buttonValue: 'Pause',
                    backgroundColor: AllColors.backgroundColor,
                    textStyle: TextStyle(
                      color: const Color.fromARGB(255, 62, 62, 62),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  CommonButton(
                    buttonValue: 'Change Quality',
                    textStyle: TextStyle(
                      color: const Color.fromARGB(255, 62, 62, 62),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: AllColors.backgroundColor,
                  ),
                  CommonButton(
                    buttonValue: 'Swap',
                    backgroundColor: AllColors.backgroundColor,
                    textStyle: TextStyle(
                      color: const Color.fromARGB(255, 62, 62, 62),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  CommonButton(
                    buttonValue: 'Cancel ',
                    backgroundColor: AllColors.backgroundColor,
                    textStyle: TextStyle(
                      color: const Color.fromARGB(255, 62, 62, 62),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
