import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/custom_button.dart';

class ImageUploadSection extends StatelessWidget {
  final List<XFile> selectedImages;
  final Function(List<XFile>) onImagesSelected;

  const ImageUploadSection({
    super.key,
    required this.selectedImages,
    required this.onImagesSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Upload area
        GestureDetector(
          onTap: () => _pickImages(context),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child:
                selectedImages.isEmpty
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSizes.paddingL),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.marginM),
                        Text(
                          'Tambahkan Foto Resep',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.marginS),
                        Text(
                          'Ketuk untuk memilih foto dari galeri',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    )
                    : _buildSelectedImages(),
          ),
        ),

        const SizedBox(height: AppSizes.marginL),

        // Upload buttons
        Row(
          children: [
            Expanded(
              child: CustomButton(
                label: 'Kamera',
                icon: Icons.camera_alt,
                onPressed: () => _pickFromCamera(context),
                variant: ButtonVariant.outline,
              ),
            ),
            const SizedBox(width: AppSizes.marginM),
            Expanded(
              child: CustomButton(
                label: 'Galeri',
                icon: Icons.photo_library,
                onPressed: () => _pickImages(context),
                variant: ButtonVariant.outline,
              ),
            ),
          ],
        ),

        if (selectedImages.isNotEmpty) ...[
          const SizedBox(height: AppSizes.marginM),
          Text(
            '${selectedImages.length} foto dipilih',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedImages() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      child: PageView.builder(
        itemCount: selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                selectedImages[index].path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
              Positioned(
                top: AppSizes.marginS,
                right: AppSizes.marginS,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => _removeImage(index),
                  ),
                ),
              ),
              if (selectedImages.length > 1)
                Positioned(
                  bottom: AppSizes.marginS,
                  right: AppSizes.marginS,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingS,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Text(
                      '${index + 1}/${selectedImages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickImages(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      final updatedImages = List<XFile>.from(selectedImages);
      updatedImages.addAll(images);
      // Limit to maximum 5 images
      if (updatedImages.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maksimal 5 foto yang dapat dipilih'),
            backgroundColor: Colors.orange,
          ),
        );
        onImagesSelected(updatedImages.take(5).toList());
      } else {
        onImagesSelected(updatedImages);
      }
    }
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );

    if (image != null) {
      final updatedImages = List<XFile>.from(selectedImages);
      updatedImages.add(image);
      if (updatedImages.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maksimal 5 foto yang dapat dipilih'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        onImagesSelected(updatedImages);
      }
    }
  }

  void _removeImage(int index) {
    final updatedImages = List<XFile>.from(selectedImages);
    updatedImages.removeAt(index);
    onImagesSelected(updatedImages);
  }
}
