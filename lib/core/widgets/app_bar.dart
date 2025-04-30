import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../constants/sizes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;
  
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.leading,
    this.centerTitle = false,
    this.backgroundColor,
    this.elevation = 0,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      leading: showBackButton 
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: AppSizes.iconS,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : leading,
      actions: actions,
      backgroundColor: backgroundColor ?? AppColors.background,
      elevation: elevation,
      centerTitle: centerTitle,
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);
}
