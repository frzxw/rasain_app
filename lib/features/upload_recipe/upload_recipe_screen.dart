import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../cubits/upload_recipe/upload_recipe_cubit.dart';
import '../../cubits/upload_recipe/upload_recipe_state.dart';
import '../../cubits/recipe/recipe_cubit.dart';
import '../../models/temp_recipe_data.dart';

class UploadRecipeScreen extends StatefulWidget {
  const UploadRecipeScreen({super.key});

  @override
  State<UploadRecipeScreen> createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends State<UploadRecipeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _servingController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();
  // Form data
  List<XFile> _selectedImages = [];
  List<Uint8List> _imageBytes = []; // For web preview
  List<String> _ingredients = [];
  List<String> _instructions = [];
  String? _selectedCategory;
  // State untuk menyimpan resep sementara ketika user belum login
  bool _pendingUpload = false;
  TempRecipeData? _tempRecipeData;

  final List<String> _categories = [
    'Makanan Utama',
    'Appetizer',
    'Dessert',
    'Minuman',
    'Snack',
    'Tradisional',
    'Modern',
    'Vegetarian',
  ];
  @override
  void initState() {
    super.initState();
    // Listen untuk perubahan auth state
    _checkAuthStateAndUpload();

    // Listen untuk auth state changes dari Supabase
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        _checkAuthStateAndUpload();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _servingController.dispose();
    _cookingTimeController.dispose();
    _ingredientController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocConsumer<UploadRecipeCubit, UploadRecipeState>(
        listener: (context, state) {
          if (state.status == UploadRecipeStatus.success) {
            // Refresh user recipes setelah upload berhasil
            context.read<RecipeCubit>().refreshUserRecipes();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Resep berhasil diupload!'),
                  ],
                ),
                backgroundColor: AppColors.success,
              ),
            );
            _resetForm();
          } else if (state.status == UploadRecipeStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(state.errorMessage ?? 'Gagal upload resep'),
                    ),
                  ],
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Modern App Bar
              SliverAppBar(
                floating: true,
                pinned: false,
                snap: true,
                backgroundColor: Colors.white,
                elevation: 0,
                title: Text(
                  'Bagikan Resep',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                centerTitle: true,
                leading: Container(),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                  ),
                ),
              ),

              // Header with inspirational text
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant_menu,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: AppSizes.marginM),
                      Text(
                        'Jadilah Chef Inspiratif!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.marginS),
                      Text(
                        'Bagikan resep istimewa Anda dan inspirasi jutaan orang untuk memasak dengan penuh cinta',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Form Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo Upload Section
                        _buildPhotoSection(),
                        const SizedBox(height: AppSizes.marginXL),

                        // Recipe Details
                        _buildRecipeDetails(),
                        const SizedBox(height: AppSizes.marginXL),

                        // Ingredients Section
                        _buildIngredientsSection(),
                        const SizedBox(height: AppSizes.marginXL),

                        // Instructions Section
                        _buildInstructionsSection(),
                        const SizedBox(height: AppSizes.marginXL),

                        // Upload Button
                        _buildUploadButton(state),
                        const SizedBox(height: AppSizes.marginXL),
                      ],
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
  // Helper methods untuk upload resep modern dan simple

  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.marginM),
              Text(
                'Foto Resep',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.marginM),

          if (_selectedImages.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    return _buildAddPhotoButton();
                  }
                  return _buildPhotoItem(_selectedImages[index], index);
                },
              ),
            )
          else
            _buildAddPhotoButton(),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _selectImages,
      child: Container(
        width: _selectedImages.isEmpty ? double.infinity : 160,
        height: 200,
        margin: const EdgeInsets.only(right: AppSizes.marginM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_a_photo,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSizes.marginM),
            Text(
              'Tambah Foto',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.marginS),
            Text(
              'Foto yang menarik\nmembuat resep lebih disukai',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem(XFile image, int index) {
    return Container(
      width: 160,
      height: 200,
      margin: const EdgeInsets.only(right: AppSizes.marginM),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            child:
                kIsWeb
                    ? (index < _imageBytes.length
                        ? Image.memory(
                          _imageBytes[index],
                          width: 160,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          width: 160,
                          height: 200,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ))
                    : Image.file(
                      File(image.path),
                      width: 160,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeDetails() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.marginM),
              Text(
                'Detail Resep',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.marginL),

          // Recipe Name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama Resep *',
              hintText: 'Contoh: Rendang Daging Sapi Padang',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              prefixIcon: Icon(Icons.restaurant, color: AppColors.primary),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama resep wajib diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSizes.marginM),

          // Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Deskripsi',
              hintText: 'Ceritakan sedikit tentang resep istimewa ini...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              prefixIcon: Icon(Icons.description, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSizes.marginM),

          // Category and details row
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Kategori *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              prefixIcon: Icon(Icons.category, color: AppColors.primary),
            ),
            items:
                _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Pilih kategori';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSizes.marginM),

          // Serving and time row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _servingController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Porsi',
                    hintText: '4',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(Icons.people, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.marginM),
              Expanded(
                child: TextFormField(
                  controller: _cookingTimeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Waktu (menit)',
                    hintText: '60',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(Icons.timer, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.marginM),
              Text(
                'Bahan-Bahan',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.marginL),

          // Add ingredient input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ingredientController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 500g daging sapi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(Icons.add, color: AppColors.primary),
                  ),
                  onSubmitted: _addIngredient,
                ),
              ),
              const SizedBox(width: AppSizes.marginM),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _addIngredient(_ingredientController.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.marginM),

          // Ingredients list
          if (_ingredients.isNotEmpty) ...[
            Text(
              '${_ingredients.length} bahan ditambahkan',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.marginM),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ingredients.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSizes.marginS),
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.marginM),
                      Expanded(
                        child: Text(
                          _ingredients[index],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _removeIngredient(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  'Belum ada bahan yang ditambahkan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.format_list_numbered,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.marginM),
              Text(
                'Langkah Memasak',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.marginL),

          // Add instruction input
          TextField(
            controller: _instructionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Contoh: Panaskan minyak dalam wajan dengan api sedang...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _addInstruction(_instructionController.text),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.marginM),

          // Instructions list
          if (_instructions.isNotEmpty) ...[
            Text(
              '${_instructions.length} langkah ditambahkan',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.marginM),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _instructions.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSizes.marginM),
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.marginM),
                      Expanded(
                        child: Text(
                          _instructions[index],
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.5),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _removeInstruction(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  'Belum ada langkah yang ditambahkan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(UploadRecipeState state) {
    final bool isFormValid =
        _nameController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        _ingredients.isNotEmpty &&
        _instructions.isNotEmpty;

    return Container(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient:
              isFormValid && state.status != UploadRecipeStatus.loading
                  ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color:
              !isFormValid || state.status == UploadRecipeStatus.loading
                  ? AppColors.textSecondary
                  : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow:
              isFormValid && state.status != UploadRecipeStatus.loading
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: ElevatedButton(
          onPressed:
              isFormValid && state.status != UploadRecipeStatus.loading
                  ? _uploadRecipe
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
          ),
          child:
              state.status == UploadRecipeStatus.loading
                  ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: AppSizes.marginM),
                      Text(
                        'Mengupload...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload, color: Colors.white, size: 24),
                      const SizedBox(width: AppSizes.marginM),
                      Text(
                        'Bagikan Resep',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  } // Helper methods

  bool _isUserAuthenticated() {
    return Supabase.instance.client.auth.currentUser != null;
  }

  void _checkAuthStateAndUpload() {
    // Jika user sudah login dan ada pending upload, langsung upload
    if (_isUserAuthenticated() && _pendingUpload && _tempRecipeData != null) {
      _pendingUpload = false;

      // Tampilkan snackbar bahwa upload otomatis akan dimulai
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.cloud_upload, color: Colors.white),
              SizedBox(width: 8),
              Text('Login berhasil! Mengunggah resep Anda...'),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );

      // Upload dengan data yang tersimpan
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _tempRecipeData != null) {
          _performUploadWithTempData(_tempRecipeData!);
          _tempRecipeData = null; // Clear temp data setelah upload
        }
      });
    }
  }

  /// Upload resep menggunakan temporary data yang tersimpan
  void _performUploadWithTempData(TempRecipeData tempData) {
    context.read<UploadRecipeCubit>().uploadRecipe(
      name: tempData.name,
      description: tempData.description,
      servings: tempData.servings,
      cookingTime: tempData.cookingTime,
      category: tempData.category,
      ingredients: tempData.ingredients,
      instructions: tempData.instructions,
      images: tempData.images,
    );
  }

  void _saveRecipeAndLogin() {
    // Validasi form terlebih dahulu
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Mohon lengkapi form resep terlebih dahulu'),
            ],
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Simpan data resep sementara
    _tempRecipeData = TempRecipeData(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      servings: int.tryParse(_servingController.text) ?? 1,
      cookingTime: int.tryParse(_cookingTimeController.text) ?? 30,
      category: _selectedCategory!,
      ingredients: List.from(_ingredients),
      instructions: List.from(_instructions),
      images: List.from(_selectedImages),
      imageBytes: List.from(_imageBytes),
    );

    // Simpan state bahwa ada resep yang akan di-upload
    _pendingUpload = true;

    // Tampilkan dialog konfirmasi
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          title: Row(
            children: [
              Icon(Icons.login, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Login Diperlukan'),
            ],
          ),
          content: const Text(
            'Anda perlu login untuk mengunggah resep. Resep yang sudah Anda buat akan tersimpan dan otomatis diunggah setelah login berhasil.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pendingUpload = false; // Reset pending upload
                _tempRecipeData = null; // Clear temp data
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigasi ke login dengan GoRouter
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: const Text(
                'Login Sekarang',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performUpload() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<UploadRecipeCubit>().uploadRecipe(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        servings: int.tryParse(_servingController.text) ?? 1,
        cookingTime: int.tryParse(_cookingTimeController.text) ?? 30,
        category: _selectedCategory!,
        ingredients: _ingredients,
        instructions: _instructions,
        images: _selectedImages,
      );
    }
  }

  Future<void> _selectImages() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        List<Uint8List> newImageBytes = [];

        // Load image bytes for web preview
        if (kIsWeb) {
          for (XFile image in images.take(5 - _selectedImages.length)) {
            final bytes = await image.readAsBytes();
            newImageBytes.add(bytes);
          }
        }

        setState(() {
          _selectedImages.addAll(images.take(5 - _selectedImages.length));
          if (kIsWeb) {
            _imageBytes.addAll(newImageBytes);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memilih gambar'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (kIsWeb && index < _imageBytes.length) {
        _imageBytes.removeAt(index);
      }
    });
  }

  void _addIngredient(String ingredient) {
    if (ingredient.trim().isNotEmpty) {
      setState(() {
        _ingredients.add(ingredient.trim());
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addInstruction(String instruction) {
    if (instruction.trim().isNotEmpty) {
      setState(() {
        _instructions.add(instruction.trim());
        _instructionController.clear();
      });
    }
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructions.removeAt(index);
    });
  }

  void _uploadRecipe() {
    // Check authentication first
    if (!_isUserAuthenticated()) {
      _saveRecipeAndLogin();
      return;
    }

    _performUpload();
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _servingController.clear();
    _cookingTimeController.clear();
    _ingredientController.clear();
    _instructionController.clear();
    setState(() {
      _selectedImages.clear();
      _imageBytes.clear(); // Clear web image bytes
      _ingredients.clear();
      _instructions.clear();
      _selectedCategory = null;
    });
  }
}
