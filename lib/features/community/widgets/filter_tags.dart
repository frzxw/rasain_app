import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';

class FilterTags extends StatelessWidget {
  final List<String> tags;
  final String selectedTag;
  final ValueChanged<String> onTagSelected;
  
  const FilterTags({
    Key? key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          final isSelected = tag == selectedTag;
          
          return Padding(
            padding: EdgeInsets.only(
              right: index < tags.length - 1 ? AppSizes.marginS : 0,
            ),
            child: FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) => onTagSelected(tag),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary.withOpacity(0.1),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingXS,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
