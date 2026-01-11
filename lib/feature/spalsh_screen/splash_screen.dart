import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/routing/routes.dart';
import '../../core/utils/prefs/prefs.dart';
import '../../theme/color_pallete.dart';
import '../home_screen/provider/home_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeSplash();
  }

  void _initializeSplash() {
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    // Check authentication and redirect
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    try {
      // Start fetching home data
      final homeProvider = context.read<HomeProvider>();
      final requestData = {
        "filterModel": const {},
        "orderBy": "productName",
        "orderDir": "ASC",
        "searchText": "",
        "page": 1,
        "pageSize": 10,
      };
      // Initiate fetch in parallel
      final dataFetchFuture = homeProvider.fetchHomeProducts(requestData);
      final authCheckFuture = Prefs.getString(Prefs.keyAuthToken);

      // Wait for minimum splash duration (3 seconds)
      await Future.delayed(const Duration(seconds: 3));

      // If data fetching is still in progress, show loading indicator
      if (homeProvider.isLoading) {
        if (mounted) {
          setState(() {
            _showLoading = true;
          });
        }
      }

      // Wait for data fetching and auth check to complete
      final results = await Future.wait([
        dataFetchFuture,
        authCheckFuture,
      ]);

      // The second result is the token (first is void from fetchHomeProducts)
      final String? token = results[1] as String?;

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        context.goNamed(AppRoutes.bottomBarScreen);
      } else {
        context.goNamed(AppRoutes.loginScreen);
      }
    } catch (e) {
      debugPrint('Error during splash initialization: $e');
      if (mounted) {
        // Fallback to login screen on error
        context.goNamed(AppRoutes.loginScreen);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/App_Icon.png',
                width: 200.w,
                height: 200.h,
              ),
              SizedBox(height: 20.h),
              Text(
                'Veedasip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (_showLoading) ...[
                SizedBox(height: 30.h),
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
