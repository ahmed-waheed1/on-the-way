import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

/// Shows a bottom sheet for editing a single text profile field.
///
/// Returns the trimmed new value, or null if the user cancelled.
Future<String?> showEditFieldSheet(
  BuildContext context, {
  required String title,
  required String currentValue,
  String? hint,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  bool obscure = false,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => _EditFieldSheet(
      title: title,
      currentValue: currentValue,
      hint: hint,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscure: obscure,
    ),
  );
}

class _EditFieldSheet extends HookWidget {
  const _EditFieldSheet({
    required this.title,
    required this.currentValue,
    this.hint,
    required this.keyboardType,
    required this.maxLines,
    this.obscure = false,
  });

  final String title;
  final String currentValue;
  final String? hint;
  final TextInputType keyboardType;
  final int maxLines;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: currentValue);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, scrollController) => GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            padding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
              top: 16.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.robotoFlex,
                    fontVariations: AppTypography.bold,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                    color: AppColors.titleText,
                  ),
                ),
                SizedBox(height: 16.h),

                AppTextField(
                  controller: controller,
                  hint: hint,
                  // TextInputAction.newline requires a multiline keyboard type.
                  keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
                  maxLines: maxLines,
                  obscureText: obscure,
                  autofocus: true,
                  textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.done,
                ),
                SizedBox(height: 24.h),

                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                        variant: ButtonVariant.outline,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppButton(
                        label: 'Save',
                        onPressed: () {
                          final value = controller.text.trim();
                          Navigator.of(context).pop(value);
                        },
                        variant: ButtonVariant.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
