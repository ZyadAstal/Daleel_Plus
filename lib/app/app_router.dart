import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  static const String initial = '/';

  static const String login = '/login';
  static const String register = '/register';
  static const String accountType = '/account-type';

  static const String profileSetup = '/profile-setup';
  static const String interests = '/interests';

  static const String discovery = '/discovery';
  static const String search = '/search';

  static const String education = '/education';
  static const String libraries = '/libraries';
  static const String jobs = '/jobs';
  static const String tutors = '/tutors';

  static const String notifications = '/notifications';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.initial:
      case AppRoutes.login:
      case AppRoutes.register:
      case AppRoutes.accountType:
      case AppRoutes.profileSetup:
      case AppRoutes.interests:
      case AppRoutes.discovery:
      case AppRoutes.search:
      case AppRoutes.education:
      case AppRoutes.libraries:
      case AppRoutes.jobs:
      case AppRoutes.tutors:
      case AppRoutes.notifications:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(),
        );

      default:
        return _unknownRoute(settings);
    }
  }

  static Route<dynamic> _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const Scaffold(),
    );
  }
}
