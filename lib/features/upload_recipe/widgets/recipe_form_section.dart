import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';

class RecipeFormSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController servingController;
  final TextEditingController cookingTimeController;
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;

  const RecipeFormSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.servingController,
    required this.cookingTimeController,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recipe Name
        _buildInputField(
          label: 'Nama Resep',
          controller: nameController,
          hint: 'Masukkan nama resep yang menarik',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama resep tidak boleh kosong';
            }
            if (value.length < 3) {
              return 'Nama resep minimal 3 karakter';
            }
            return null;
          },
        ),

        const SizedBox(height: AppSizes.marginL),

        // Description
        _buildInputField(
          label: 'Deskripsi',
          controller: descriptionController,
          hint: 'Ceritakan sedikit tentang resep ini...',
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Deskripsi tidak boleh kosong';
            }
            if (value.length < 10) {
              return 'Deskripsi minimal 10 karakter';
            }
            return null;
          },
        ),

        const SizedBox(height: AppSizes.marginL),

        // Category Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSizes.marginS),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                hint: const Text('Pilih kategori resep'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: AppSizes.paddingS,
                  ),
                ),
                items:
                    categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: onCategoryChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih kategori resep';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.marginL),

        // Serving and Cooking Time Row
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                label: 'Porsi',
                controller: servingController,
                hint: '4',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Porsi tidak boleh kosong';
                  }
                  final serving = int.tryParse(value);
                  if (serving == null || serving <= 0) {
                    return 'Porsi harus angka positif';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSizes.marginM),
            Expanded(
              child: _buildInputField(
                label: 'Waktu Memasak (menit)',
                controller: cookingTimeController,
                hint: '30',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Waktu tidak boleh kosong';
                  }
                  final time = int.tryParse(value);
                  if (time == null || time <= 0) {
                    return 'Waktu harus angka positif';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: AppSizes.marginS),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: AppColors.border),
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
            ),
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
          ),
        ),
      ],
    );
  }
}
