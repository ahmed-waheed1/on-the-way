import 'dart:io';
import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';
import 'package:on_the_way/src/features/auth/presentation/providers/session_provider.dart';
import 'package:on_the_way/src/features/account/presentation/widgets/edit_field_sheet.dart';

const _kLogoutRed = Color(0xFFFF305D);
const _kSubtitleGray = Color(0xFF6B7280);
const _kDividerColor = Color(0xFFE5E7EB);

PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 20.r, color: AppColors.primary),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.robotoFlex,
            fontVariations: AppTypography.regular,
            fontSize: 14.sp,
            color: AppColors.titleText,
          ),
        ),
      ],
    ),
  );
}

class MyAccountScreen extends HookConsumerWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).user;
    final isLoggingOut = useState(false);
    final pendingAvatar = useState<File?>(null);
    final isUploadingAvatar = useState(false);

    Future<void> handleLogout() async {
      isLoggingOut.value = true;
      await ref.read(sessionProvider.notifier).logout();
      isLoggingOut.value = false;
      if (context.mounted) context.go(AppRoutes.login);
    }

    Future<void> pickAndUploadAvatar(ImageSource source) async {
      final result = await MediaService.instance.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      result.fold(
        (_) {},
        (file) async {
          if (file == null) return;
          pendingAvatar.value = file;
          isUploadingAvatar.value = true;

          final ok = await ref.read(sessionProvider.notifier).uploadAvatar(file);

          isUploadingAvatar.value = false;
          pendingAvatar.value = null;
          if (ok && context.mounted) {
            showToast(context, message: 'Profile photo updated', status: 'success');
          }
        },
      );
    }

    void showAvatarPicker() {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (_) => SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: _kDividerColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                _AvatarSourceTile(
                  icon: Icons.photo_library_outlined,
                  label: 'Choose from Gallery',
                  onTap: () {
                    Navigator.of(context).pop();
                    pickAndUploadAvatar(ImageSource.gallery);
                  },
                ),
                SizedBox(height: 8.h),
                _AvatarSourceTile(
                  icon: Icons.camera_alt_outlined,
                  label: 'Take a Photo',
                  onTap: () {
                    Navigator.of(context).pop();
                    pickAndUploadAvatar(ImageSource.camera);
                  },
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      );
    }

    Future<void> editUsername() async {
      final current = user?.username ?? '';
      final result = await showEditFieldSheet(
        context,
        title: 'Username',
        currentValue: current,
        hint: 'e.g. ~johndoe',
      );
      if (result == null || result == current) return;
      final ok = await ref.read(sessionProvider.notifier).updateProfile(username: result);
      if (ok && context.mounted) {
        showToast(context, message: 'Username updated', status: 'success');
      }
    }

    Future<void> editBio() async {
      final current = user?.bio ?? '';
      final result = await showEditFieldSheet(
        context,
        title: 'Bio',
        currentValue: current,
        hint: 'Tell others about yourself…',
        maxLines: 3,
      );
      if (result == null || result == current) return;
      final ok = await ref.read(sessionProvider.notifier).updateProfile(bio: result);
      if (ok && context.mounted) {
        showToast(context, message: 'Bio updated', status: 'success');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppTopBar(
        title: 'My Account',
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            onSelected: (value) {
              if (value == 'manage_roads') context.push(AppRoutes.manageRoads);
              if (value == 'my_requests') context.push(AppRoutes.myRequests);
            },
            itemBuilder: (_) => [
              _menuItem('my_requests', Icons.receipt_long_outlined, 'My Requests'),
              _menuItem('manage_roads', Icons.alt_route, 'Manage Roads'),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 27.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 17.h),

                      // ── Avatar ──────────────────────────────────────────────
                      Center(
                        child: _ProfileAvatar(
                          photoUrl: user?.photoUrl,
                          pendingFile: pendingAvatar.value,
                          isUploading: isUploadingAvatar.value,
                          onTap: showAvatarPicker,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // ── Full name ───────────────────────────────────────────
                      Center(
                        child: Text(
                          user?.name ?? 'Unknown',
                          style: TextStyle(
                            fontFamily: AppTypography.robotoFlex,
                            fontVariations: AppTypography.bold,
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                            color: AppColors.titleText,
                            height: 20 / 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 44.h),

                      // ── Phone ───────────────────────────────────────────────
                      _EditableProfileRow(
                        value: user?.phone ?? '',
                        emptyHint: 'Add phone number',
                        label: 'Phone',
                        sublabel: 'Tap to change phone number',
                        sublabelIsAction: true,
                        onTap: () => context.push(AppRoutes.changeNumber),
                      ),
                      _AccountDivider(),

                      // ── Username ────────────────────────────────────────────
                      _EditableProfileRow(
                        value: user?.username ?? '',
                        emptyHint: 'Add username',
                        label: 'Username',
                        onTap: editUsername,
                      ),
                      _AccountDivider(),

                      // ── Bio ─────────────────────────────────────────────────
                      _EditableProfileRow(
                        value: user?.bio ?? '',
                        emptyHint: 'Add bio',
                        label: 'Bio',
                        onTap: editBio,
                      ),
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),
            ),

            // ── Action buttons ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(27.w, 0, 27.w, 0),
              child: Column(
                children: [
                  AppButton(
                    label: 'Assistance History',
                    onPressed: () => context.push(AppRoutes.requestHistory),
                    variant: ButtonVariant.primary,
                    isFullWidth: true,
                  ),
                  SizedBox(height: 24.h),
                  AppButton(
                    label: 'Reset Password',
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    variant: ButtonVariant.outline,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),

            // ── Logout ────────────────────────────────────────────────────────
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: isLoggingOut.value ? null : handleLogout,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoggingOut.value)
                    SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _kLogoutRed,
                      ),
                    )
                  else
                    Icon(Icons.logout_rounded, color: _kLogoutRed, size: 24.r),
                  SizedBox(width: 8.w),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: AppTypography.robotoFlex,
                      fontVariations: AppTypography.bold,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                      color: _kLogoutRed,
                      height: 20 / 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

// ── Profile avatar with camera badge ──────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    this.photoUrl,
    this.pendingFile,
    required this.isUploading,
    required this.onTap,
  });

  final String? photoUrl;
  final File? pendingFile;
  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100.r,
            height: 100.r,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: _avatarContent(),
            ),
          ),
          if (isUploading)
            Positioned.fill(
              child: ClipOval(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: Center(
                    child: SizedBox(
                      width: 24.r,
                      height: 24.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: EdgeInsets.all(5.r),
              child: Icon(Icons.camera_alt_outlined, size: 14.r, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarContent() {
    if (pendingFile != null) {
      return Image.file(pendingFile!, fit: BoxFit.cover);
    }
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _AvatarPlaceholder(),
        errorWidget: (_, __, ___) => _AvatarPlaceholder(),
      );
    }
    return _AvatarPlaceholder();
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.avatarBackground,
      child: Icon(Icons.person, size: 52.r, color: AppColors.primary),
    );
  }
}

// ── Avatar source picker tile ──────────────────────────────────────────────────

class _AvatarSourceTile extends StatelessWidget {
  const _AvatarSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 24.r, color: AppColors.primary),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.robotoFlex,
                fontVariations: AppTypography.semiBold,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: AppColors.titleText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Editable profile row ───────────────────────────────────────────────────────

class _EditableProfileRow extends StatelessWidget {
  const _EditableProfileRow({
    required this.value,
    required this.emptyHint,
    required this.label,
    this.sublabel,
    this.sublabelIsAction = false,
    required this.onTap,
  });

  final String value;
  final String emptyHint;
  final String label;
  final String? sublabel;
  final bool sublabelIsAction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.isEmpty;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEmpty ? emptyHint : value,
                    style: TextStyle(
                      fontFamily: AppTypography.robotoFlex,
                      fontVariations: isEmpty ? AppTypography.regular : AppTypography.semiBold,
                      fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
                      fontSize: 16.sp,
                      color: isEmpty ? _kSubtitleGray : AppColors.titleText,
                      height: 20 / 16,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    sublabel ?? label,
                    style: TextStyle(
                      fontFamily: AppTypography.robotoFlex,
                      fontVariations: AppTypography.regular,
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      color: _kSubtitleGray,
                      height: 20 / 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined,
              size: 18.r,
              color: _kSubtitleGray,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Divider ────────────────────────────────────────────────────────────────────

class _AccountDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: const Divider(height: 1, thickness: 1, color: _kDividerColor),
    );
  }
}
