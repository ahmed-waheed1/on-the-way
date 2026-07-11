import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

import 'package:on_the_way/src/features/auth/presentation/providers/session_provider.dart';

class SessionListenerWrapper extends ConsumerWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SessionState>(sessionProvider, (prev, next) {
      if (next.status == SessionStatus.unknown) return;
      FlutterNativeSplash.remove();

      // Only redirect on real status transitions — not on every user-data
      // refresh (e.g. profile edits re-emit an authenticated state and used
      // to kick the user back to home mid-flow).
      if (prev?.status == next.status) return;

      if (next.status == SessionStatus.authenticated) {
        context.go(AppRoutes.home);
      } else if (next.status == SessionStatus.unauthenticated) {
        context.go(AppRoutes.onboarding);
      }
    });

    return child;
  }
}
