import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:on_the_way/src/routing/global_navigator.dart';
import 'package:on_the_way/src/routing/app_routes.dart';

import 'package:on_the_way/src/features/auth/presentation/screens/login_screen.dart';
import 'package:on_the_way/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:on_the_way/src/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:on_the_way/src/features/auth/presentation/screens/verify_account_screen.dart';
import 'package:on_the_way/src/features/auth/presentation/screens/email_verified_screen.dart';

import 'package:on_the_way/src/features/home/presentation/screens/home_page.dart';
import 'package:on_the_way/src/features/onboarding/presentation/screens/onboarding_page.dart';
import 'package:on_the_way/src/features/nearby_assistance/presentation/screens/nearby_assistance_screen.dart';
import 'package:on_the_way/src/features/nearby_accidents/presentation/screens/nearby_accidents_screen.dart';
import 'package:on_the_way/src/features/need_help/presentation/screens/need_help_screen.dart';
import 'package:on_the_way/src/features/need_help/presentation/screens/describe_issue_screen.dart';
import 'package:on_the_way/src/features/need_help/presentation/screens/review_request_screen.dart';
import 'package:on_the_way/src/features/need_help/presentation/screens/request_sent_screen.dart';
import 'package:on_the_way/src/features/account/presentation/screens/my_account_screen.dart';
import 'package:on_the_way/src/features/account/presentation/screens/change_number_screen.dart';
import 'package:on_the_way/src/features/account/presentation/screens/change_number_form_screen.dart';
import 'package:on_the_way/src/features/account/presentation/screens/change_number_otp_screen.dart';
import 'package:on_the_way/src/features/account/presentation/screens/change_number_success_screen.dart';
import 'package:on_the_way/src/features/request_history/presentation/screens/request_history_screen.dart';
import 'package:on_the_way/src/features/request_history/presentation/screens/my_requests_screen.dart';
import 'package:on_the_way/src/features/request_history/presentation/screens/request_details_screen.dart';
import 'package:on_the_way/src/features/request_history/domain/entities/request_history_item.dart';
import 'package:on_the_way/src/features/report_accident/presentation/screens/report_accident_screen.dart';
import 'package:on_the_way/src/features/report_accident/presentation/screens/describe_accident_screen.dart';
import 'package:on_the_way/src/features/report_accident/presentation/screens/review_accident_screen.dart';
import 'package:on_the_way/src/features/report_accident/presentation/screens/report_sent_screen.dart';
import 'package:on_the_way/src/features/manage_roads/presentation/screens/manage_roads_screen.dart';

/// Smooth, subtle fade+slide transition used app-wide. Tab roots
/// (home / nearby / account) use a plain fade so switching tabs feels instant.
CustomTransitionPage<void> _page(
  GoRouterState state,
  Widget child, {
  bool fadeOnly = false,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      if (fadeOnly) {
        return FadeTransition(opacity: curved, child: child);
      }
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.onboarding,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      pageBuilder: (context, state) =>
          _page(state, const OnboardingPage(), fadeOnly: true),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      pageBuilder: (context, state) => _page(state, const LoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      pageBuilder: (context, state) => _page(state, const SignupScreen()),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      pageBuilder: (context, state) =>
          _page(state, const ForgotPasswordScreen()),
    ),
    GoRoute(
      path: AppRoutes.verifyAccount,
      name: 'verifyAccount',
      pageBuilder: (context, state) => _page(
          state, VerifyAccountScreen(args: state.extra as VerifyAccountArgs?)),
    ),
    GoRoute(
      path: AppRoutes.emailVerified,
      name: 'emailVerified',
      pageBuilder: (context, state) =>
          _page(state, const EmailVerifiedScreen()),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) =>
          _page(state, const HomePage(), fadeOnly: true),
    ),
    GoRoute(
      path: AppRoutes.nearbyAssistance,
      name: 'nearbyAssistance',
      pageBuilder: (context, state) =>
          _page(state, const NearbyAssistanceScreen(), fadeOnly: true),
    ),
    GoRoute(
      path: AppRoutes.nearbyAccidents,
      name: 'nearbyAccidents',
      pageBuilder: (context, state) =>
          _page(state, const NearbyAccidentsScreen(), fadeOnly: true),
    ),
    GoRoute(
      path: AppRoutes.needHelp,
      name: 'needHelp',
      pageBuilder: (context, state) => _page(state, const NeedHelpScreen()),
    ),
    GoRoute(
      path: AppRoutes.describeIssue,
      name: 'describeIssue',
      pageBuilder: (context, state) =>
          _page(state, const DescribeIssueScreen()),
    ),
    GoRoute(
      path: AppRoutes.reviewRequest,
      name: 'reviewRequest',
      pageBuilder: (context, state) =>
          _page(state, const ReviewRequestScreen()),
    ),
    GoRoute(
      path: AppRoutes.requestSent,
      name: 'requestSent',
      pageBuilder: (context, state) => _page(state, const RequestSentScreen()),
    ),
    GoRoute(
      path: AppRoutes.myAccount,
      name: 'myAccount',
      pageBuilder: (context, state) =>
          _page(state, const MyAccountScreen(), fadeOnly: true),
    ),
    GoRoute(
      path: AppRoutes.changeNumber,
      name: 'changeNumber',
      pageBuilder: (context, state) => _page(state, const ChangeNumberScreen()),
    ),
    GoRoute(
      path: AppRoutes.changeNumberForm,
      name: 'changeNumberForm',
      pageBuilder: (context, state) =>
          _page(state, const ChangeNumberFormScreen()),
    ),
    GoRoute(
      path: AppRoutes.changeNumberOtp,
      name: 'changeNumberOtp',
      pageBuilder: (context, state) =>
          _page(state, const ChangeNumberOtpScreen()),
    ),
    GoRoute(
      path: AppRoutes.changeNumberSuccess,
      name: 'changeNumberSuccess',
      pageBuilder: (context, state) =>
          _page(state, const ChangeNumberSuccessScreen()),
    ),
    GoRoute(
      path: AppRoutes.requestHistory,
      name: 'requestHistory',
      pageBuilder: (context, state) =>
          _page(state, const RequestHistoryScreen()),
    ),
    GoRoute(
      path: AppRoutes.myRequests,
      name: 'myRequests',
      pageBuilder: (context, state) => _page(state, const MyRequestsScreen()),
    ),
    GoRoute(
      path: AppRoutes.requestDetails,
      name: 'requestDetails',
      pageBuilder: (context, state) => _page(
          state, RequestDetailsScreen(item: state.extra as RequestHistoryItem)),
    ),
    GoRoute(
      path: AppRoutes.reportAccident,
      name: 'reportAccident',
      pageBuilder: (context, state) =>
          _page(state, const ReportAccidentScreen()),
    ),
    GoRoute(
      path: AppRoutes.manageRoads,
      name: 'manageRoads',
      pageBuilder: (context, state) => _page(state, const ManageRoadsScreen()),
    ),
    GoRoute(
      path: AppRoutes.describeAccident,
      name: 'describeAccident',
      pageBuilder: (context, state) =>
          _page(state, const DescribeAccidentScreen()),
    ),
    GoRoute(
      path: AppRoutes.reviewAccident,
      name: 'reviewAccident',
      pageBuilder: (context, state) =>
          _page(state, const ReviewAccidentScreen()),
    ),
    GoRoute(
      path: AppRoutes.accidentSent,
      name: 'accidentSent',
      pageBuilder: (context, state) => _page(state, const ReportSentScreen()),
    ),
  ],
);
