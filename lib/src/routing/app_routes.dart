/// Centralized route path constants for GoRouter.
///
/// Use these variables instead of raw strings throughout the app.
/// Example: `context.go(AppRoutes.onboarding)` instead of `context.go('/')`.
abstract final class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String nearbyAssistance = '/nearby-assistance';
  static const String nearbyAccidents = '/nearby-accidents';
  static const String needHelp = '/need-help';
  static const String describeIssue = '/need-help/describe-issue';
  static const String reviewRequest = '/need-help/review-request';
  static const String requestSent = '/need-help/request-sent';
  static const String myAccount = '/account';
}
