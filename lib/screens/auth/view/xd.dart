// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:flutter_arch/theme/colorTheme.dart';

// // class MyNavigationBar extends StatefulWidget {
// //   final Widget child;
// //   const MyNavigationBar({required this.child, super.key});
// //   @override
// //   State<MyNavigationBar> createState() => _MyNavigationBarState();
// // }

// // class _MyNavigationBarState extends State<MyNavigationBar> {
// //   int currentIndex = 0;
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: widget.child,
// //       bottomNavigationBar: BottomNavigationBar(
// //         backgroundColor: AppColor.primaryColor,
// //         currentIndex: currentIndex,
// //         selectedItemColor: AppColor.constWhite,
// //         type: BottomNavigationBarType.fixed,
// //         unselectedItemColor: AppColor.constWhite.withOpacity(0.6),
// //         onTap: (value) {
// //           currentIndex = value;
// //           switch (value) {
// //             case 0:
// //               context.go("/dashboard");
// //               break;
// //             case 1:
// //               context.go("/home");
// //               break;
// //             case 2:
// //               context.go("/setting");
// //               break;
// //             default:
// //           }
// //         },
// //         items: [
// //           BottomNavigationBarItem(
// //             backgroundColor: AppColor.primaryColor,
// //             label: "DASHBOARD",
// //             icon: Icon(Icons.dashboard_outlined),
// //           ),
// //           BottomNavigationBarItem(
// //             backgroundColor: AppColor.primaryColor,
// //             label: "HOME",
// //             icon: Icon(Icons.home),
// //           ),
// //           BottomNavigationBarItem(
// //             backgroundColor: AppColor.primaryColor,
// //             label: "SETTING",
// //             icon: Icon(Icons.settings),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';

// class MyNavigationBar extends StatefulWidget {
//   const MyNavigationBar({super.key});

//   @override
//   State<MyNavigationBar> createState() => _MyNavigationBarState();
// }

// class _MyNavigationBarState extends State<MyNavigationBar> {
//   int _currentIndex = 0;

//   final List<Widget> _screens = [
//     DashboardScreen(),
//     HomeScreen(),
//     SettingScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
//         ],
//       ),
//     );
//   }
// }
