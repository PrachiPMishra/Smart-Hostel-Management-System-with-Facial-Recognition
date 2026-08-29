import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/enrollment/presentation/screens/enrollment_screen.dart';
import '../../features/enrollment/presentation/screens/consent_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/mess/presentation/screens/mess_screen.dart';
import '../../features/leave/presentation/screens/leave_screen.dart';
import '../../features/complaints/presentation/screens/complaints_screen.dart';
import '../../features/emergency/presentation/screens/emergency_screen.dart';
import '../../features/parent/presentation/screens/parent_portal_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../services/auth_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authService.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSplash = state.matchedLocation == '/splash';

      if (isGoingToSplash) return null;
      
      if (!isAuthenticated && !isGoingToLogin) {
        return '/login';
      }
      
      if (isAuthenticated && isGoingToLogin) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/enrollment',
        builder: (context, state) => const EnrollmentScreen(),
      ),
      GoRoute(
        path: '/enrollment/consent',
        builder: (context, state) => const ConsentScreen(),
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/mess',
        builder: (context, state) => const MessScreen(),
      ),
      GoRoute(
        path: '/leave',
        builder: (context, state) => const LeaveScreen(),
      ),
      GoRoute(
        path: '/complaints',
        builder: (context, state) => const ComplaintsScreen(),
      ),
      GoRoute(
        path: '/emergency',
        builder: (context, state) => const EmergencyScreen(),
      ),
      GoRoute(
        path: '/parent-portal',
        builder: (context, state) => const ParentPortalScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
