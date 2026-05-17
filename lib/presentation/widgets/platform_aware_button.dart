import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/constants/theme.dart';

enum ButtonVariant {
  /// Filled heritage emerald — call-to-action.
  primary,

  /// Outlined copper on ivory — supporting actions, navigation.
  secondary,

  /// Borderless copper text — least visual weight, low-priority actions.
  ghost,
}

class PlatformAwareButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool dense;

  const PlatformAwareButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.dense = false,
  });

  bool get _enabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return isIos ? _buildCupertino() : _buildMaterial();
  }

  // ---------------- Material ----------------

  Widget _buildMaterial() {
    final padH = dense ? AppSpacing.md : AppSpacing.lg;
    final padV = dense ? AppSpacing.sm : 14.0;
    final radius = BorderRadius.circular(AppRadius.small);
    final textStyle = bodyFont(
      size: dense ? 12 : 13,
      weight: FontWeight.w600,
      letterSpacing: 1.4,
    );

    switch (variant) {
      case ButtonVariant.primary:
        return _wrap(
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.heritage,
              foregroundColor: AppColors.cream,
              disabledBackgroundColor: AppColors.heritage.withOpacity(0.35),
              disabledForegroundColor: AppColors.cream.withOpacity(0.55),
              padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(
                  color: AppColors.copper.withOpacity(_enabled ? 0.65 : 0.25),
                  width: 1,
                ),
              ),
              elevation: 0,
              textStyle: textStyle,
            ),
            child: _content(AppColors.cream),
          ),
        );

      case ButtonVariant.secondary:
        return _wrap(
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.copper,
              disabledForegroundColor: AppColors.copper.withOpacity(0.35),
              backgroundColor: AppColors.ivory,
              padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
              shape: RoundedRectangleBorder(borderRadius: radius),
              side: BorderSide(
                color: AppColors.copper.withOpacity(_enabled ? 0.65 : 0.25),
                width: 1,
              ),
              textStyle: textStyle,
            ),
            child: _content(AppColors.copper),
          ),
        );

      case ButtonVariant.ghost:
        return _wrap(
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.copper,
              disabledForegroundColor: AppColors.copper.withOpacity(0.35),
              padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
              shape: RoundedRectangleBorder(borderRadius: radius),
              textStyle: textStyle,
            ),
            child: _content(AppColors.copper),
          ),
        );
    }
  }

  Widget _wrap(Widget child) => child;

  Widget _content(Color color) {
    if (icon == null) {
      return Text(label.toUpperCase());
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: dense ? 14 : 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(label.toUpperCase()),
      ],
    );
  }

  // ---------------- Cupertino (iOS) ----------------

  Widget _buildCupertino() {
    final padH = dense ? AppSpacing.md : AppSpacing.lg;
    final padV = dense ? AppSpacing.sm : 14.0;
    final radius = BorderRadius.circular(AppRadius.small);
    final textStyle = bodyFont(
      size: dense ? 12 : 13,
      weight: FontWeight.w600,
      letterSpacing: 1.4,
    );

    final Color bg;
    final Color fg;
    final BoxBorder? border;
    switch (variant) {
      case ButtonVariant.primary:
        bg = AppColors.heritage;
        fg = AppColors.cream;
        border = Border.all(
          color: AppColors.copper.withOpacity(_enabled ? 0.65 : 0.25),
          width: 1,
        );
        break;
      case ButtonVariant.secondary:
        bg = AppColors.ivory;
        fg = AppColors.copper;
        border = Border.all(
          color: AppColors.copper.withOpacity(_enabled ? 0.65 : 0.25),
          width: 1,
        );
        break;
      case ButtonVariant.ghost:
        bg = const Color(0x00000000);
        fg = AppColors.copper;
        border = null;
        break;
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: _enabled ? bg : bg.withOpacity(0.4),
          borderRadius: radius,
          border: border,
        ),
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        child: DefaultTextStyle(
          style: textStyle.copyWith(color: _enabled ? fg : fg.withOpacity(0.45)),
          child: _content(_enabled ? fg : fg.withOpacity(0.45)),
        ),
      ),
    );
  }
}
