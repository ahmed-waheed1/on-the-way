import 'package:go_router/go_router.dart';
import 'package:on_the_way/src/routing/global_navigator.dart';
import 'package:on_the_way/src/routing/app_routes.dart';

import 'package:on_the_way/src/features/auth/presentation/screens/login_screen.dart';
import 'package:on_the_way/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:on_the_way/src/features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:on_the_way/src/features/home/presentation/screens/home_page.dart';
import 'package:on_the_way/src/features/onboarding/presentation/screens/onboarding_page.dart';
import 'package:on_the_way/src/features/nearby_assistance/presentation/screens/nearby_assistance_screen.dart';
import 'package:on_the_way/src/features/nearby_accidents/presentation/screens/nearby_accidents_screen.dart';
import 'package:on_the_way/src/features/need_help/presentation/screens/need_help_screen.dart';
import 'package:on_the_way/src/features/need_help/presentation/screens/describe_issue_screen.dart';
import 'package:on_the_way/src/features/need_help/presentation/screens/review_request_screen.dart';
import 'package:on_the_way/src/features/need_help/presentation/screens/request_sent_screen.dart';
import 'package:on_the_way/src/features/account/presentation/screens/my_account_screen.dart';


final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.onboarding,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.nearbyAssistance,
      name: 'nearbyAssistance',
      builder: (context, state) => const NearbyAssistanceScreen(),
    ),
    GoRoute(
      path: AppRoutes.nearbyAccidents,
      name: 'nearbyAccidents',
      builder: (context, state) => const NearbyAccidentsScreen(),
    ),
    GoRoute(
      path: AppRoutes.needHelp,
      name: 'needHelp',
      builder: (context, state) => const NeedHelpScreen(),
    ),
    GoRoute(
      path: AppRoutes.describeIssue,
      name: 'describeIssue',
      builder: (context, state) => const DescribeIssueScreen(),
    ),
    GoRoute(
      path: AppRoutes.reviewRequest,
      name: 'reviewRequest',
      builder: (context, state) => const ReviewRequestScreen(),
    ),
    GoRoute(
      path: AppRoutes.requestSent,
      name: 'requestSent',
      builder: (context, state) => const RequestSentScreen(),
    ),
    GoRoute(
      path: AppRoutes.myAccount,
      name: 'myAccount',
      builder: (context, state) => const MyAccountScreen(),
    ),
  ],
);
