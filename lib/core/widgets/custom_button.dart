import 'package:flutter/material.dart';
import '../constants/sizes.dart';
import '../theme/colors.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  text,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool iconAtEnd;
  final bool isLoading;
  final bool isFullWidth;
  final bool disabled;
  
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeightForSize(),
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: disabled || isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            disabledBackgroundColor: AppColors.disabledColor,
            disabledForegroundColor: AppColors.textSecondary,
            padding: _getPaddingForSize(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
          ),
          child: _buildButtonContent(context, AppColors.onPrimary),
        );
      
      case ButtonVariant.secondary:
        return ElevatedButton(
          onPressed: disabled || isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            disabledBackgroundColor: AppColors.disabledColor,
            disabledForegroundColor: AppColors.textSecondary,
            padding: _getPaddingForSize(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
          ),
          child: _buildButtonContent(context, AppColors.textPrimary),
        );
      
      case ButtonVariant.outline:
        return OutlinedButton(
          onPressed: disabled || isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: disabled ? AppColors.disabledColor : AppColors.primary,
              width: 1,
            ),
            padding: _getPaddingForSize(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
          ),
          child: _buildButtonContent(context, AppColors.primary),
        );
      
      case ButtonVariant.text:
        return TextButton(
          onPressed: disabled || isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _getPaddingForSize(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
          ),
          child: _buildButtonContent(context, AppColors.primary),
        );
    }
  }

  Widget _buildButtonContent(BuildContext context, Color color) {
    if (isLoading) {
      return SizedBox(
        height: _getLoadingSize(),
        width: _getLoadingSize(),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: 2.5,
        ),
      );
    }

    final TextStyle textStyle = _getTextStyleForSize(context);
    
    if (icon == null) {
      return Text(
        label,
        style: textStyle,
        textAlign: TextAlign.center,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconAtEnd
          ? [
              Text(label, style: textStyle),
              SizedBox(width: size == ButtonSize.small ? 4 : 8),
              Icon(icon, size: _getIconSize()),
            ]
          : [
              Icon(icon, size: _getIconSize()),
              SizedBox(width: size == ButtonSize.small ? 4 : 8),
              Text(label, style: textStyle),
            ],
    );
  }

  double _getHeightForSize() {
    switch (size) {
      case ButtonSize.small:
        return 32;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 48;
    }
  }

  EdgeInsets _getPaddingForSize() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingS,
          vertical: AppSizes.paddingXS,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingM,
        );
    }
  }

  TextStyle _getTextStyleForSize(BuildContext context) {
    final baseStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: disabled ? AppColors.textSecondary : null,
    );
    
    switch (size) {
      case ButtonSize.small:
        return Theme.of(context).textTheme.labelMedium?.merge(baseStyle) ??
            baseStyle.copyWith(fontSize: 12);
      case ButtonSize.medium:
        return Theme.of(context).textTheme.labelLarge?.merge(baseStyle) ??
            baseStyle.copyWith(fontSize: 14);
      case ButtonSize.large:
        return Theme.of(context).textTheme.bodyLarge?.merge(baseStyle) ??
            baseStyle.copyWith(fontSize: 16);
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return AppSizes.iconXS;
      case ButtonSize.medium:
        return AppSizes.iconS;
      case ButtonSize.large:
        return 20;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 22;
    }
  }
}
