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
  final TextEditingController _estimatedCostController = TextEditingController();
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
  String? _selectedDifficulty; // New field for difficulty level

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
  final List<String> _difficultyLevels = [
    'Mudah',
    'Sedang',
    'Sulit',
  ];

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
    _checkAuthenticationAndShowForm();    // Listen untuk auth state changes dengan tambahan stream listener
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
    _fatController.dispose();
    
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
                    Text('Data form Anda masih tersimpan dan siap dilanjutkan!'),
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
           _instructions.isNotEmpty ||           _selectedImages.isNotEmpty;
  }

  void _navigateToLogin() async {
    final hasData = _hasFormData();
    // Show login dialog with callback to return to upload form
    AuthDialog.showAuthDialog(
      context,
      startWithLogin: true,
      redirectMessage: hasData 
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
          ),          const SizedBox(height: AppSizes.marginS),          Text(
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
              icon: const Icon(Icons.login, color: Colors.white),              label: Text(
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
        const SizedBox(height: AppSizes.marginM),        // Serving and Cooking Time
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
                items: _difficultyLevels.map((String difficulty) {
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
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children:
                _ingredients
                    .map(
                      (ingredient) => Chip(
                        label: Text(ingredient),
                        onDeleted: () {
                          setState(() {
                            _ingredients.remove(ingredient);
                          });
                        },
                      ),
                    )
                    .toList(),
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
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children:
                _instructions
                    .asMap()
                    .entries
                    .map(
                      (entry) => Chip(
                        label: Text('${entry.key + 1}. ${entry.value}'),
                        onDeleted: () {
                          setState(() {
                            _instructions.removeAt(entry.key);
                          });
                        },
                      ),
                    )
                    .toList(),
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
        _ingredients.add(ingredient.trim());        _ingredientController.clear();
      });
    }
  }

  void _addInstruction(String instruction) {
    if (instruction.trim().isNotEmpty) {
      setState(() {
        _instructions.add(instruction.trim());
        _instructionController.clear();
      });
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
      }

      context.read<UploadRecipeCubit>().uploadRecipe(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        servings: int.tryParse(_servingController.text) ?? 1,
        cookingTime: int.tryParse(_cookingTimeController.text) ?? 30,
        category: _selectedCategory!,
        ingredients: _ingredients,
        instructions: _instructions,
        images: _selectedImages,
        estimatedCost: _estimatedCostController.text.isNotEmpty 
          ? _estimatedCostController.text 
          : null,
        difficultyLevel: _selectedDifficulty,
        nutritionInfo: nutritionInfo.isNotEmpty ? nutritionInfo : null,
        tips: _tipsController.text.isNotEmpty ? _tipsController.text.trim() : null,
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
}
