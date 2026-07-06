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
import 'package:on_the_way/src/features/request_history/presentation/screens/request_details_screen.dart';
import 'package:on_the_way/src/features/request_history/domain/entities/request_history_item.dart';
import 'package:on_the_way/src/features/report_accident/presentation/screens/report_accident_screen.dart';
import 'package:on_the_way/src/features/report_accident/presentation/screens/describe_accident_screen.dart';
import 'package:on_the_way/src/features/report_accident/presentation/screens/review_accident_screen.dart';
import 'package:on_the_way/src/features/report_accident/presentation/screens/report_sent_screen.dart';
import 'package:on_the_way/src/features/manage_roads/presentation/screens/manage_roads_screen.dart';


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
      path: AppRoutes.verifyAccount,
      name: 'verifyAccount',
      builder: (context, state) => VerifyAccountScreen(email: state.extra as String?),
    ),
    GoRoute(
      path: AppRoutes.emailVerified,
      name: 'emailVerified',
      builder: (context, state) => const EmailVerifiedScreen(),
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
    GoRoute(
      path: AppRoutes.changeNumber,
      name: 'changeNumber',
      builder: (context, state) => const ChangeNumberScreen(),
    ),
    GoRoute(
      path: AppRoutes.changeNumberForm,
      name: 'changeNumberForm',
      builder: (context, state) => const ChangeNumberFormScreen(),
    ),
    GoRoute(
      path: AppRoutes.changeNumberOtp,
      name: 'changeNumberOtp',
      builder: (context, state) => const ChangeNumberOtpScreen(),
    ),
    GoRoute(
      path: AppRoutes.changeNumberSuccess,
      name: 'changeNumberSuccess',
      builder: (context, state) => const ChangeNumberSuccessScreen(),
    ),
    GoRoute(
      path: AppRoutes.requestHistory,
      name: 'requestHistory',
      builder: (context, state) => const RequestHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.requestDetails,
      name: 'requestDetails',
      builder: (context, state) =>
          RequestDetailsScreen(item: state.extra as RequestHistoryItem),
    ),
    GoRoute(
      path: AppRoutes.reportAccident,
      name: 'reportAccident',
      builder: (context, state) => const ReportAccidentScreen(),
    ),
    GoRoute(
      path: AppRoutes.manageRoads,
      name: 'manageRoads',
      builder: (context, state) => const ManageRoadsScreen(),
    ),
    GoRoute(
      path: AppRoutes.describeAccident,
      name: 'describeAccident',
      builder: (context, state) => const DescribeAccidentScreen(),
    ),
    GoRoute(
      path: AppRoutes.reviewAccident,
      name: 'reviewAccident',
      builder: (context, state) => const ReviewAccidentScreen(),
    ),
    GoRoute(
      path: AppRoutes.accidentSent,
      name: 'accidentSent',
      builder: (context, state) => const ReportSentScreen(),
    ),
  ],
);
