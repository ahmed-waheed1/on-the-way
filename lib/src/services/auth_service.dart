import 'dart:async';
import 'dart:io';
import '../utils/utils.dart';
import '../config/app_config.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Account get _account => AppConfig.appwriteAccount;

  final StreamController<Map<String, dynamic>?> _authStateController =
      StreamController<Map<String, dynamic>?>.broadcast();

  Stream<Map<String, dynamic>?> get authStateChanges => _authStateController.stream;

  // ── Helpers ────────────────────────────────────────────────────────────────

  Map<String, dynamic> _userToMap(appwrite_models.User user) {
    final prefs = user.prefs.data;
    return {
      'id': user.$id,
      'email': user.email,
      'name': user.name,
      'phone': prefs['phone'],
      'username': prefs['username'],
      'bio': prefs['bio'],
      'photoUrl': prefs['photoUrl'],
    };
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  FutureEither<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      await _account.createEmailPasswordSession(email: email, password: password);
      final user = await _account.get();
      final userData = _userToMap(user);
      _authStateController.add(userData);
      return userData;
    }, requiresNetwork: true);
  }

  FutureEither<Map<String, dynamic>?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      await _account.createEmailPasswordSession(email: email, password: password);
      final userData = _userToMap(user);
      _authStateController.add(userData);
      return userData;
    }, requiresNetwork: true);
  }

  FutureEither<void> forgotPassword({required String email}) async {
    return runTask(() async {
      await _account.createRecovery(
        email: email,
        url: 'https://example.com/recovery',
      );
    }, requiresNetwork: true);
  }

  FutureEither<void> logout() async {
    return runTask(() async {
      await _account.deleteSession(sessionId: 'current');
      _authStateController.add(null);
    }, requiresNetwork: true);
  }

  FutureEither<Map<String, dynamic>?> getCurrentUser() async {
    return runTask(() async {
      try {
        final user = await _account.get();
        return _userToMap(user);
      } catch (_) {
        return null;
      }
    });
  }

  // ── Profile update ────────────────────────────────────────────────────────

  FutureEither<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? username,
    String? bio,
  }) async {
    return runTask(() async {
      if (name != null && name.isNotEmpty) {
        await _account.updateName(name: name);
      }

      final currentUser = await _account.get();
      final prefs = Map<String, dynamic>.from(currentUser.prefs.data);

      if (phone != null) prefs['phone'] = phone;
      if (username != null) prefs['username'] = username;
      if (bio != null) prefs['bio'] = bio;

      await _account.updatePrefs(prefs: prefs);

      final updatedUser = await _account.get();
      final userData = _userToMap(updatedUser);
      _authStateController.add(userData);
      return userData;
    }, requiresNetwork: true);
  }

  // ── Avatar upload ─────────────────────────────────────────────────────────

  FutureEither<String> uploadAvatar(File imageFile) async {
    return runTask(() async {
      final bucketId = AppConfig.avatarBucketId;
      if (bucketId.isEmpty) {
        throw Exception(
          'Avatar storage bucket not configured. '
          'Set APPWRITE_AVATAR_BUCKET_ID in .env and create the bucket in Appwrite Console.',
        );
      }

      // Fetch user first so we can set file ownership permissions.
      final currentUser = await _account.get();
      final userId = currentUser.$id;

      final bytes = await imageFile.readAsBytes();
      final fileId = ID.unique();
      await AppConfig.appwriteStorage.createFile(
        bucketId: bucketId,
        fileId: fileId,
        file: InputFile.fromBytes(
          bytes: bytes,
          filename: 'avatar_$fileId.jpg',
        ),
        permissions: [
          Permission.read(Role.any()),          // public — avatars are visible to everyone
          Permission.update(Role.user(userId)), // only owner can replace
          Permission.delete(Role.user(userId)), // only owner can delete
        ],
      );

      final endpoint = dotenv.get('APPWRITE_ENDPOINT', fallback: 'https://cloud.appwrite.io/v1');
      final projectId = dotenv.get('APPWRITE_PROJECT_ID', fallback: '');
      final url = '$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId';

      final prefs = Map<String, dynamic>.from(currentUser.prefs.data);
      prefs['photoUrl'] = url;
      await _account.updatePrefs(prefs: prefs);

      final updatedUser = await _account.get();
      _authStateController.add(_userToMap(updatedUser));

      return url;
    }, requiresNetwork: true);
  }

  void dispose() {
    _authStateController.close();
  }
}
