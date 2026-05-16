import 'dart:async';
import 'dart:io';
import 'package:hooks_riverpod/legacy.dart';
import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';
import 'package:on_the_way/src/features/auth/domain/entities/user.dart';
import 'package:on_the_way/src/features/auth/domain/repositories/auth_repository.dart';

import 'package:on_the_way/src/features/auth/data/repositories/auth_repository_impl.dart';

/// Provides the AuthRepository instance
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Provides a stream of auth state changes
final authStateStreamProvider = StreamProvider<AppUser?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.onAuthStateChanged;
});

/// Provides the current session state
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return SessionNotifier(repository: repo);
});

/// Session states
enum SessionStatus { unknown, authenticated, unauthenticated }

class SessionState {
  final SessionStatus status;
  final AppUser? user;

  const SessionState({this.status = SessionStatus.unknown, this.user});

  SessionState copyWith({SessionStatus? status, AppUser? user, bool clearUser = false}) {
    return SessionState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _authSub;

  SessionNotifier({required AuthRepository repository})
      : _repository = repository,
        super(const SessionState()) {
    _init();
  }

  Future<void> _init() async {
    // Check persisted session first
    final result = await _repository.checkAuthState();
    result.fold(
      (_) => state = const SessionState(status: SessionStatus.unauthenticated),
      (user) {
        if (user != null) {
          state = SessionState(status: SessionStatus.authenticated, user: user);
        } else {
          state = const SessionState(status: SessionStatus.unauthenticated);
        }
      },
    );

    // Listen for future changes
    _authSub = _repository.onAuthStateChanged.listen((user) {
      if (user != null) {
        state = SessionState(status: SessionStatus.authenticated, user: user);
      } else {
        state = const SessionState(status: SessionStatus.unauthenticated);
      }
    });
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const SessionState(status: SessionStatus.unauthenticated);
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? username,
    String? bio,
  }) async {
    final result = await _repository.updateProfile(
      name: name,
      phone: phone,
      username: username,
      bio: bio,
    );
    return result.fold(
      (failure) {
        showGlobalToast(message: failure.message, status: 'error');
        return false;
      },
      (user) {
        state = state.copyWith(status: SessionStatus.authenticated, user: user);
        return true;
      },
    );
  }

  Future<bool> uploadAvatar(File imageFile) async {
    final result = await _repository.uploadAvatar(imageFile);
    return result.fold(
      (failure) {
        showGlobalToast(message: failure.message, status: 'error');
        return false;
      },
      (url) {
        final updated = state.user?.copyWith(photoUrl: url);
        if (updated != null) {
          state = state.copyWith(status: SessionStatus.authenticated, user: updated);
        }
        return true;
      },
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

