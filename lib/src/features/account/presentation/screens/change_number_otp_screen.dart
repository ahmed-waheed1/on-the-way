import 'package:on_the_way/src/imports/core_imports.dart';
import 'package:on_the_way/src/imports/packages_imports.dart';

const _kSubtitleColor = Color(0xFF909090);
const _kOtpLength = 5;

class ChangeNumberOtpScreen extends HookWidget {
  const ChangeNumberOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = useMemoized(
      () => List.generate(_kOtpLength, (_) => TextEditingController()),
      const [],
    );
    final focusNodes = useMemoized(
      () => List.generate(_kOtpLength, (_) => FocusNode()),
      const [],
    );
    final digits = useState(List.filled(_kOtpLength, ''));
    final submitted = useState(false);

    useEffect(() {
      return () {
        for (final c in controllers) {
          c.dispose();
        }
        for (final f in focusNodes) {
          f.dispose();
        }
      };
    }, const []);

    void confirm() {
      if (submitted.value) return;
      submitted.value = true;
      // TODO: verify the code against the backend before confirming.
      context.go(AppRoutes.changeNumberSuccess);
    }

    void onDigitChanged(int index, String value) {
      final ch = value.isEmpty ? '' : value.characters.last;
      controllers[index].text = ch;
      controllers[index].selection = TextSelection.collapsed(offset: ch.length);

      final next = [...digits.value];
      next[index] = ch;
      digits.value = next;

      if (ch.isNotEmpty && index < _kOtpLength - 1) {
        focusNodes[index + 1].requestFocus();
      } else if (ch.isEmpty && index > 0) {
        focusNodes[index - 1].requestFocus();
      }

      if (!next.contains('')) {
        FocusScope.of(context).unfocus();
        confirm();
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: ''),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 27.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Illustration ──────────────────────────────────────────────
                Image.asset(
                  AppAssets.changeNumberOtpIllustration,
                  width: 100.r,
                  height: 100.r,
                ),
                SizedBox(height: 72.h),

                Text(
                  'Enter code',
                  style: TextStyle(
                    fontFamily: AppTypography.robotoFlex,
                    fontVariations: AppTypography.bold,
                    fontWeight: FontWeight.w700,
                    fontSize: 20.sp,
                    color: Colors.black,
                    height: 20 / 20,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'check your email to dictate the code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.robotoFlex,
                    fontVariations: AppTypography.regular,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp,
                    color: _kSubtitleColor,
                    height: 20 / 16,
                  ),
                ),
                SizedBox(height: 24.h),

                // ── OTP boxes ─────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_kOtpLength, (i) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: _OtpBox(
                        controller: controllers[i],
                        focusNode: focusNodes[i],
                        onChanged: (v) => onDigitChanged(i, v),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── OTP box ─────────────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.w,
      height: 56.h,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 1),
        borderRadius: BorderRadius.circular(4.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
        color: Colors.white,
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 1,
        cursorColor: AppColors.primary,
        style: TextStyle(
          fontFamily: AppTypography.robotoFlex,
          fontVariations: AppTypography.bold,
          fontWeight: FontWeight.w700,
          fontSize: 20.sp,
          color: AppColors.titleText,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
