import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/auth_dialog.dart';
import '../../cubits/upload_recipe/upload_recipe_cubit.dart';
import '../../cubits/upload_recipe/upload_recipe_state.dart';
import '../../cubits/recipe/recipe_cubit.dart';

class UploadRecipeScreen extends StatefulWidget {
  const UploadRecipeScreen({super.key});

  @override
  State<UploadRecipeScreen> createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends State<UploadRecipeScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _servingController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();
  final TextEditingController _estimatedCostController =
      TextEditingController();
  final TextEditingController _tipsController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  // Form data
  List<XFile> _selectedImages = [];
  List<Uint8List> _imageBytes = []; // For web preview
  List<String> _ingredients = [];
  List<String> _instructions = [];
  String? _selectedCategory;
  String? _selectedDifficulty;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final List<String> _categories = [
    'Makanan Utama',
    'Appetizer',
    'Dessert',
    'Minuman',
    'Snack',
    'Tradisional',
  ];

  final List<String> _difficultyLevels = ['easy', 'medium', 'hard'];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Check authentication and show form if authenticated
    _checkAuthenticationAndShowForm();

    // Listen untuk auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        _checkAuthenticationAndShowForm();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _servingController.dispose();
    _cookingTimeController.dispose();
    _ingredientController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  void _checkAuthenticationAndShowForm() {
    if (_isUserAuthenticated()) {
      // Delay untuk memberikan efek animasi yang smooth
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _animationController.forward();
        }
      });
    } else {
      _animationController.reverse();
    }
  }

  bool _isUserAuthenticated() {
    return Supabase.instance.client.auth.currentUser != null;
  }
  void _navigateToLogin() {
    AuthDialog.showAuthDialog(
      context,
      startWithLogin: true,
      redirectMessage: 'Masuk untuk mulai membuat dan berbagi resep dengan komunitas.',
    );
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
              // App Bar
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

              // Header Section
              SliverToBoxAdapter(child: _buildHeaderSection()),

              // Content Section - Form atau Login Prompt
              SliverToBoxAdapter(
                child:
                    _isUserAuthenticated()
                        ? _buildAnimatedUploadForm(state)
                        : _buildLoginPrompt(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
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
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingL),
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, color: AppColors.primary, size: 48),
          const SizedBox(height: AppSizes.marginM),
          Text(
            'Login Diperlukan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Silakan login untuk dapat membagikan resep Anda ke komunitas Rasain',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.marginL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToLogin,
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text(
                'Login Sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedUploadForm(UploadRecipeState state) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Upload Section
                    _buildPhotoSection(),
                    const SizedBox(height: AppSizes.marginL),

                    // Recipe Details
                    _buildRecipeDetails(),
                    const SizedBox(height: AppSizes.marginL),

                    // Ingredients Section
                    _buildIngredientsSection(),
                    const SizedBox(height: AppSizes.marginL),

                    // Instructions Section
                    _buildInstructionsSection(),
                    const SizedBox(height: AppSizes.marginL),

                    // Upload Button
                    _buildUploadButton(state),
                    const SizedBox(height: AppSizes.marginXL),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Resep',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.marginM),
        GestureDetector(
          onTap: _selectImages,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child:
                _selectedImages.isEmpty
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 48,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: AppSizes.marginS),
                        Text(
                          'Tambahkan foto resep Anda',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          kIsWeb
                              ? (_imageBytes.isNotEmpty
                                  ? Image.memory(
                                    _imageBytes.first,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                  : const Icon(Icons.image))
                              : Image.file(
                                File(_selectedImages.first.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Resep',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.marginM),

        // Recipe Name
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Resep',
            hintText: 'Masukkan nama resep',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama resep tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.marginM),

        // Description
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Deskripsi',
            hintText: 'Ceritakan tentang resep Anda',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSizes.marginM),

        // Category
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Kategori',
            border: OutlineInputBorder(),
          ),
          items:
              _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Pilih kategori resep';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.marginM),

        // Servings and Cooking Time
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _servingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Porsi',
                  hintText: '4',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Masukkan jumlah porsi';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSizes.marginM),
            Expanded(
              child: TextFormField(
                controller: _cookingTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Waktu Masak (menit)',
                  hintText: '30',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Masukkan waktu masak';
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

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bahan-bahan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.marginM),

        // Add ingredient field
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ingredientController,
                decoration: const InputDecoration(
                  labelText: 'Tambah Bahan',
                  hintText: 'contoh: 2 butir telur',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.marginS),
            ElevatedButton(
              onPressed: () => _addIngredient(_ingredientController.text),
              child: const Text('Tambah'),
            ),
          ],
        ),

        if (_ingredients.isNotEmpty) ...[
          const SizedBox(height: AppSizes.marginM),
          Text(
            '${_ingredients.length} bahan ditambahkan',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.marginS),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ingredients.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(_ingredients[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeIngredient(index),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Langkah-langkah',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.marginM),

        // Add instruction field
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _instructionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Tambah Langkah',
                  hintText: 'Tuliskan langkah memasak',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.marginS),
            ElevatedButton(
              onPressed: () => _addInstruction(_instructionController.text),
              child: const Text('Tambah'),
            ),
          ],
        ),

        if (_instructions.isNotEmpty) ...[
          const SizedBox(height: AppSizes.marginM),
          Text(
            '${_instructions.length} langkah ditambahkan',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.marginS),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _instructions.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(_instructions[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeInstruction(index),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildUploadButton(UploadRecipeState state) {
    final isFormValid =
        _nameController.text.trim().isNotEmpty &&
        _selectedCategory != null &&
        _ingredients.isNotEmpty &&
        _instructions.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            isFormValid && state.status != UploadRecipeStatus.loading
                ? _uploadRecipe
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    SizedBox(width: 8),
                    Text(
                      'Mengupload...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
                : const Text(
                  'Bagikan Resep',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
      ),
    );
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

        if (kIsWeb) {
          for (XFile image in images.take(5)) {
            final bytes = await image.readAsBytes();
            newImageBytes.add(bytes);
          }
        }

        setState(() {
          _selectedImages = images.take(5).toList();
          if (kIsWeb) {
            _imageBytes = newImageBytes;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting images: $e')));
    }
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

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _servingController.clear();
    _cookingTimeController.clear();
    _ingredientController.clear();
    _instructionController.clear();
    setState(() {
      _selectedImages.clear();
      _imageBytes.clear();
      _ingredients.clear();
      _instructions.clear();
      _selectedCategory = null;
    });
  }
}
