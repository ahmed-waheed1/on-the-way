/// Central list of REST endpoint paths for the On The Way API.
///
/// Base URL is configured in [AppConfig] via the `API_BASE_URL` env var
/// (https://ontheway.up.railway.app).
abstract final class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ────────────────────────────────────────────────────────────────
  static const String register = '/api/auth/register';
  static const String verifyEmail = '/api/auth/verify-email';
  static const String login = '/api/auth/login';
  static const String forgetPassword = '/api/auth/forget-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String googleLogin = '/api/auth/google-login';

  // ── Incidents (accidents) ───────────────────────────────────────────────
  static const String reportIncident = '/api/incidents/report';
  static const String voteIncident = '/api/incidents/vote';
  static String incidentById(String id) => '/api/incidents/$id';

  // ── Assistance ──────────────────────────────────────────────────────────
  static const String requestAssistance = '/api/assistance/request';
  static String assistanceById(String id) => '/api/assistance/$id';

  // ── Feed ────────────────────────────────────────────────────────────────
  static const String feedIncidents = '/api/feed/incidents';
  static const String feedAssistance = '/api/feed/assistance';
  static String offerHelp(String assistanceId) =>
      '/api/feed/assistance/$assistanceId/offer-help';
  static String respondToOffer(String offerId) =>
      '/api/feed/offers/$offerId/respond';
  static String completeAssistance(String assistanceId) =>
      '/api/feed/assistance/$assistanceId/complete';

  // ── History ─────────────────────────────────────────────────────────────
  static const String history = '/api/history';
}
