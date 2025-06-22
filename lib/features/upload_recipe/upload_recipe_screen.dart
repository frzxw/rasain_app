import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/sizes.dart';
import '../../core/theme/colors.dart';
import '../../core/widgets/auth_dialog.dart';
import '../../cubits/upload_recipe/upload_recipe_cubit.dart';
import '../../cubits/upload_recipe/upload_recipe_state.dart';
import '../../cubits/recipe/recipe_cubit.dart';
import '../../models/recipe_ingredient.dart';
import '../../models/recipe_instruction.dart';

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

  // New controllers for missing fields
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
  List<RecipeIngredient> _ingredients = [];
  List<RecipeInstruction> _instructions = [];
  String? _selectedCategory;
  String? _selectedDifficulty; // New field for difficulty level  // Additional controllers for ingredient form
  final TextEditingController _ingredientNameController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _ingredientNotesController =
      TextEditingController();
  // Additional controllers for instruction form
  final TextEditingController _instructionTextController =
      TextEditingController();
  final TextEditingController _timerController = TextEditingController();

  // Image picker for instruction steps
  XFile? _currentInstructionImage;
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<String> _categories = [];
  bool _categoriesLoaded = false;
  final List<String> _difficultyLevels = ['Mudah', 'Sedang', 'Sulit'];

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
    ); // Check authentication and show form if authenticated
    _checkAuthenticationAndShowForm();

    // Load categories from database
    _loadCategories(); // Listen untuk auth state changes dengan tambahan stream listener
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        final wasAuthenticated = _isUserAuthenticated();
        final isNowAuthenticated = data.session != null;

        // Jika user baru saja login, tampilkan form dengan animasi
        if (isNowAuthenticated && !wasAuthenticated) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _refreshAuthState();
              // Scroll to top untuk memudahkan user melihat form
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          });
        } else {
          // Delay sedikit untuk memastikan state sudah ter-update
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) {
              _checkAuthenticationAndShowForm();
            }
          });
        }
      }
    });

    // Tambahan: Listen untuk perubahan current user secara langsung
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check auth state setelah widget selesai build
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _checkAuthenticationAndShowForm();
        }
      });
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

    // Dispose new controllers
    _estimatedCostController.dispose();
    _tipsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();    // Dispose new ingredient/instruction controllers
    _ingredientNameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _ingredientNotesController.dispose();
    _instructionTextController.dispose();
    _timerController.dispose();

    super.dispose();
  }

  void _checkAuthenticationAndShowForm() {
    if (_isUserAuthenticated()) {
      // Delay untuk memberikan efek animasi yang smooth
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _animationController.forward();
        }
      });
    } else {
      if (mounted) {
        _animationController.reverse();
      }
    }
  }

  bool _isUserAuthenticated() {
    return Supabase.instance.client.auth.currentUser != null;
  }

  Future<void> _loadCategories() async {
    if (_categoriesLoaded) return;

    try {
      final response = await Supabase.instance.client
          .from('recipe_categories')
          .select('name')
          .order('name', ascending: true);

      setState(() {
        _categories =
            (response as List<dynamic>)
                .map((category) => category['name'] as String)
                .toList();
        _categoriesLoaded = true;
      });

      print('✅ Loaded ${_categories.length} categories: $_categories');
    } catch (e) {
      print('❌ Error loading categories: $e');
      // Fallback to default categories if database fetch fails
      setState(() {
        _categories = [
          'Makanan Utama',
          'Appetizer',
          'Dessert',
          'Minuman',
          'Snack',
          'Tradisional',
        ];
        _categoriesLoaded = true;
      });
    }
  }

  void _refreshAuthState() {
    // Force refresh auth state dan form
    if (mounted) {
      setState(() {
        // Trigger rebuild
      });
      _checkAuthenticationAndShowForm();

      // Jika ada data form yang sudah diisi, beri tahu user bahwa data masih tersimpan
      if (_hasFormData()) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.save_outlined, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Data form Anda masih tersimpan dan siap dilanjutkan!',
                    ),
                  ],
                ),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 3),
              ),
            );
          }
        });
      }
    }
  }

  // Method untuk memeriksa apakah user sudah mengisi form
  bool _hasFormData() {
    return _nameController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty ||
        _servingController.text.trim().isNotEmpty ||
        _cookingTimeController.text.trim().isNotEmpty ||
        _selectedCategory != null ||
        _ingredients.isNotEmpty ||
        _instructions.isNotEmpty ||
        _selectedImages.isNotEmpty;
  }

  void _navigateToLogin() async {
    final hasData = _hasFormData();
    // Show login dialog with callback to return to upload form
    AuthDialog.showAuthDialog(
      context,
      startWithLogin: true,
      redirectMessage:
          hasData
              ? 'Login untuk melanjutkan upload resep Anda. Data yang sudah diisi akan tetap tersimpan.'
              : 'Login untuk mulai membuat resep baru',
      onSuccess: () {
        // After successful login, trigger form animation and state refresh
        _refreshAuthState();
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasData
                        ? 'Selamat datang kembali! Anda dapat melanjutkan upload resep.'
                        : 'Selamat datang! Silakan mulai membuat resep baru.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocConsumer<UploadRecipeCubit, UploadRecipeState>(
        listener: (context, state) {
          if (state.status == UploadRecipeStatus.success) {
            // Refresh user recipes dan all recipes setelah upload berhasil
            context.read<RecipeCubit>().refreshUserRecipes();
            context.read<RecipeCubit>().refreshAllRecipes();

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
    final hasData = _hasFormData();

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
            hasData
                ? 'Silakan login untuk melanjutkan upload resep yang sedang Anda buat'
                : 'Silakan login untuk dapat membagikan resep Anda ke komunitas Rasain',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.marginS),
          // Tampilkan info data tersimpan hanya jika user sudah mengisi form
          if (hasData) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.save_outlined, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Data yang sudah Anda isi akan tetap tersimpan setelah login',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.marginL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToLogin,
              icon: const Icon(Icons.login, color: Colors.white),
              label: Text(
                hasData ? 'Login & Lanjutkan Upload' : 'Login Sekarang',
                style: const TextStyle(
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
              _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pilih kategori resep';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.marginM), // Serving and Cooking Time
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _servingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Porsi',
                  hintText: 'Contoh: 4',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.marginM),
            Expanded(
              child: TextFormField(
                controller: _cookingTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Waktu (menit)',
                  hintText: 'Contoh: 30',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.marginM),

        // Difficulty Level and Estimated Cost
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Tingkat Kesulitan',
                  border: OutlineInputBorder(),
                ),
                items:
                    _difficultyLevels.map((String difficulty) {
                      String displayText;
                      switch (difficulty) {
                        case 'easy':
                          displayText = 'Mudah';
                          break;
                        case 'medium':
                          displayText = 'Sedang';
                          break;
                        case 'hard':
                          displayText = 'Sulit';
                          break;
                        default:
                          displayText = difficulty;
                      }
                      return DropdownMenuItem<String>(
                        value: difficulty,
                        child: Text(displayText),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDifficulty = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih tingkat kesulitan';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSizes.marginM),
            Expanded(
              child: TextFormField(
                controller: _estimatedCostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Estimasi Biaya (Rp)',
                  hintText: 'Contoh: 25000',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final cost = int.tryParse(value);
                    if (cost == null || cost < 0) {
                      return 'Masukkan biaya yang valid';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.marginM),

        // Nutrition Information Section
        Text(
          'Informasi Gizi (Opsional)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.marginS),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kalori',
                  hintText: 'per porsi',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.marginS),
            Expanded(
              child: TextFormField(
                controller: _proteinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Protein (g)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.marginS),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _carbsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Karbohidrat (g)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.marginS),
            Expanded(
              child: TextFormField(
                controller: _fatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Lemak (g)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.marginM),

        // Tips Section
        TextFormField(
          controller: _tipsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Tips Memasak (Opsional)',
            hintText: 'Bagikan tips dan trik untuk hasil terbaik...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: AppColors.primary, size: 24),
              const SizedBox(width: AppSizes.marginS),
              Text(
                'Bahan-bahan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_ingredients.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_ingredients.length}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.marginM),

          // Add ingredient form
          _buildAddIngredientForm(),

          if (_ingredients.isNotEmpty) ...[
            const SizedBox(height: AppSizes.marginM),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_ingredients.length} bahan telah ditambahkan',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.marginS),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ingredients.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final ingredient = _ingredients[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ingredient.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Show detailed information if available
                            if (ingredient.amount != null &&
                                ingredient.amount!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Total: ${ingredient.amount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (ingredient.notes != null &&
                                ingredient.notes!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                ingredient.notes!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _ingredients.removeAt(index);
                            // Update order indexes
                            for (int i = 0; i < _ingredients.length; i++) {
                              _ingredients[i] = _ingredients[i].copyWith(
                                orderIndex: i,
                              );
                            }
                          });
                        },
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else ...[
            const SizedBox(height: AppSizes.marginM),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                border: Border.all(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada bahan yang ditambahkan',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tambahkan bahan-bahan yang diperlukan',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_list_numbered,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSizes.marginS),
              Text(
                'Langkah-langkah',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_instructions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_instructions.length}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.marginM),

          // Add instruction form
          _buildAddInstructionForm(),

          if (_instructions.isNotEmpty) ...[
            const SizedBox(height: AppSizes.marginM),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingS),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_instructions.length} langkah telah ditambahkan',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.marginS),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _instructions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final instruction = _instructions[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            '${instruction.stepNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Langkah ${instruction.stepNumber}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (instruction.timerMinutes != null &&
                                    instruction.timerMinutes! > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          size: 12,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${instruction.timerMinutes}m',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (instruction.imageUrl != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.image,
                                          size: 12,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'Foto',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              instruction.instructionText,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                            // Show image preview if available
                            if (instruction.imageUrl != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    instruction.imageUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          if (index > 0)
                            IconButton(
                              onPressed: () => _moveInstructionUp(index),
                              icon: Icon(
                                Icons.keyboard_arrow_up,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              splashRadius: 16,
                              tooltip: 'Pindah ke atas',
                            ),
                          if (index < _instructions.length - 1)
                            IconButton(
                              onPressed: () => _moveInstructionDown(index),
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              splashRadius: 16,
                              tooltip: 'Pindah ke bawah',
                            ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _instructions.removeAt(index);
                            // Update step numbers
                            for (int i = 0; i < _instructions.length; i++) {
                              _instructions[i] = _instructions[i].copyWith(
                                stepNumber: i + 1,
                              );
                            }
                          });
                        },
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        splashRadius: 20,
                        tooltip: 'Hapus langkah',
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else ...[
            const SizedBox(height: AppSizes.marginM),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                border: Border.all(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.menu_book,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada langkah yang ditambahkan',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tambahkan langkah-langkah memasak',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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

  Future<void> _selectInstructionImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _currentInstructionImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
    }
  }

  void _uploadRecipe() {
    if (_formKey.currentState?.validate() ?? false) {
      // Prepare nutrition info
      Map<String, dynamic> nutritionInfo = {};
      if (_caloriesController.text.isNotEmpty) {
        nutritionInfo['calories'] = int.tryParse(_caloriesController.text);
      }
      if (_proteinController.text.isNotEmpty) {
        nutritionInfo['protein'] = double.tryParse(_proteinController.text);
      }
      if (_carbsController.text.isNotEmpty) {
        nutritionInfo['carbohydrates'] = double.tryParse(_carbsController.text);
      }
      if (_fatController.text.isNotEmpty) {
        nutritionInfo['fat'] = double.tryParse(_fatController.text);
      } // Convert ingredients and instructions to simple strings for compatibility
      List<String> ingredientStrings =
          _ingredients.map((ingredient) => ingredient.toString()).toList();
      List<String> instructionStrings =
          _instructions
              .map((instruction) => instruction.instructionText)
              .toList();

      context.read<UploadRecipeCubit>().uploadRecipe(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        servings: int.tryParse(_servingController.text) ?? 1,
        cookingTime: int.tryParse(_cookingTimeController.text) ?? 30,
        category: _selectedCategory!,
        ingredients: ingredientStrings,
        instructions: instructionStrings,
        images: _selectedImages,
        estimatedCost:
            _estimatedCostController.text.isNotEmpty
                ? _estimatedCostController.text
                : null,
        difficultyLevel: _selectedDifficulty,
        nutritionInfo: nutritionInfo.isNotEmpty ? nutritionInfo : null,
        tips:
            _tipsController.text.isNotEmpty
                ? _tipsController.text.trim()
                : null,
        detailedIngredients: _ingredients,
        detailedInstructions: _instructions,
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

    // Clear new controllers
    _estimatedCostController.clear();
    _tipsController.clear();
    _caloriesController.clear();
    _proteinController.clear();
    _carbsController.clear();
    _fatController.clear();

    setState(() {
      _selectedImages.clear();
      _imageBytes.clear();
      _ingredients.clear();
      _instructions.clear();
      _selectedCategory = null;
      _selectedDifficulty = null;
    });
  }

  void _moveInstructionUp(int index) {
    if (index > 0) {
      setState(() {
        final instruction = _instructions.removeAt(index);
        _instructions.insert(index - 1, instruction);
        // Update step numbers
        for (int i = 0; i < _instructions.length; i++) {
          _instructions[i] = _instructions[i].copyWith(stepNumber: i + 1);
        }
      });
    }
  }

  void _moveInstructionDown(int index) {
    if (index < _instructions.length - 1) {
      setState(() {
        final instruction = _instructions.removeAt(index);
        _instructions.insert(index + 1, instruction);
        // Update step numbers
        for (int i = 0; i < _instructions.length; i++) {
          _instructions[i] = _instructions[i].copyWith(stepNumber: i + 1);
        }
      });
    }
  }

  Widget _buildAddIngredientForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambah Bahan Baru',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Ingredient name (required)
          TextFormField(
            controller: _ingredientNameController,
            decoration: InputDecoration(
              labelText: 'Nama Bahan *',
              hintText: 'Contoh: Bawang putih',
              prefixIcon: Icon(Icons.restaurant, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),
          // Quantity and Unit row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    hintText: 'Contoh: 2',
                    prefixIcon: Icon(Icons.numbers, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _unitController,
                  decoration: InputDecoration(
                    labelText: 'Satuan',
                    hintText: 'siung, gram, ml',
                    prefixIcon: Icon(
                      Icons.straighten,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ),          ],
          ),
          const SizedBox(height: 12),
          
          // Notes (optional)
          TextFormField(
            controller: _ingredientNotesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Catatan (Opsional)',
              hintText: 'Contoh: cincang halus, atau sesuai selera',
              prefixIcon: Icon(Icons.note_alt, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16),

          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addNewIngredient,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Bahan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewIngredient() {
    if (_ingredientNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama bahan tidak boleh kosong'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check for duplicates by ingredient name
    final ingredientName = _ingredientNameController.text.trim();
    if (_ingredients.any(
      (ingredient) =>
          ingredient.ingredientName.toLowerCase() ==
          ingredientName.toLowerCase(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bahan sudah ditambahkan sebelumnya'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }    // Auto-calculate amount from quantity and unit
    String? finalAmount;
    if (_quantityController.text.trim().isNotEmpty && _unitController.text.trim().isNotEmpty) {
      finalAmount = '${_quantityController.text.trim()} ${_unitController.text.trim()}';
    } else if (_quantityController.text.trim().isNotEmpty) {
      finalAmount = _quantityController.text.trim();
    }
    // Generate a UUID for ingredient_id instead of string-based ID
    // Let the database auto-generate the UUID for ingredient_id
    final newIngredient = RecipeIngredient(
      ingredientName: ingredientName,
      quantity:
          _quantityController.text.trim().isEmpty
              ? null
              : _quantityController.text.trim(),
      unit:
          _unitController.text.trim().isEmpty
              ? null
              : _unitController.text.trim(),
      orderIndex: _ingredients.length,
      notes:
          _ingredientNotesController.text.trim().isEmpty
              ? null
              : _ingredientNotesController.text.trim(),
      amount: finalAmount,
      ingredientId: null, // Let database auto-generate UUID
    );    setState(() {
      _ingredients.add(newIngredient);
      // Clear form
      _ingredientNameController.clear();
      _quantityController.clear();
      _unitController.clear();
      _ingredientNotesController.clear();
    });

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('Bahan "${newIngredient.toString()}" berhasil ditambahkan'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildAddInstructionForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambah Langkah Baru',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Instruction text (required)
          TextFormField(
            controller: _instructionTextController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Deskripsi Langkah *',
              hintText:
                  'Contoh: Panaskan minyak dalam wajan dengan api sedang selama 2 menit...',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                child: Icon(Icons.menu_book, color: AppColors.primary),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),

          // Timer (optional)
          TextFormField(
            controller: _timerController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Waktu Timer (Menit)',
              hintText: 'Contoh: 5 untuk timer 5 menit',
              prefixIcon: Icon(Icons.timer, color: AppColors.primary),
              suffixText: 'menit',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),

          // Image upload for instruction step (optional)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Column(
              children: [
                if (_currentInstructionImage == null) ...[
                  InkWell(
                    onTap: _selectInstructionImage,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 40,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tambah Foto Langkah (Opsional)',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Foto akan membantu pengguna memahami langkah',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Show selected image preview
                  Container(
                    height: 120,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          child:
                              kIsWeb
                                  ? FutureBuilder<Uint8List>(
                                    future:
                                        _currentInstructionImage!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        );
                                      }
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  )
                                  : Image.file(
                                    File(_currentInstructionImage!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  onPressed: _selectInstructionImage,
                                  tooltip: 'Ganti foto',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _currentInstructionImage = null;
                                    });
                                  },
                                  tooltip: 'Hapus foto',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Add button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addNewInstruction,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Langkah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewInstruction() async {
    if (_instructionTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deskripsi langkah tidak boleh kosong'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    int? timerMinutes;
    if (_timerController.text.trim().isNotEmpty) {
      timerMinutes = int.tryParse(_timerController.text.trim());
      if (timerMinutes == null || timerMinutes <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Timer harus berupa angka positif'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // Upload image to Supabase Storage if available
    String? imageUrl;
    if (_currentInstructionImage != null) {
      try {
        final supabase = Supabase.instance.client;
        final bytes = await _currentInstructionImage!.readAsBytes();
        final fileName =
            'instruction_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await supabase.storage
            .from('recipeimages')
            .uploadBinary(fileName, bytes);

        imageUrl = supabase.storage.from('recipeimages').getPublicUrl(fileName);

        print('✅ Instruction image uploaded: $imageUrl');
      } catch (e) {
        print('❌ Error uploading instruction image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupload gambar: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        // Continue without image
      }
    }

    final newInstruction = RecipeInstruction(
      stepNumber: _instructions.length + 1,
      instructionText: _instructionTextController.text.trim(),
      timerMinutes: timerMinutes,
      imageUrl: imageUrl,
    );

    setState(() {
      _instructions.add(newInstruction);
      // Clear form
      _instructionTextController.clear();
      _timerController.clear();
      _currentInstructionImage = null;
    });

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('Langkah ${newInstruction.stepNumber} berhasil ditambahkan'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
