// lib/core/navigation/role_based_view.dart - VERSION CORRIGÉE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../auth/models.dart';
import '../auth/login_screen.dart';
import 'main_navigation.dart';    
import 'teacher_navigation.dart';
import 'student_navigation.dart';

class RoleBasedView extends StatelessWidget {
  const RoleBasedView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    final user = authProvider.user!;

    switch (user.role) {
      case UserRole.admin:
        return MainNavigationWrapper();
      case UserRole.teacher:
        return TeacherNavigation(user: user);
      case UserRole.student:
        return StudentNavigation(user: user);
      case UserRole.unknown:
        WidgetsBinding.instance.addPostFrameCallback((_) => authProvider.logout());
        return const LoginScreen();
    }
  }
}