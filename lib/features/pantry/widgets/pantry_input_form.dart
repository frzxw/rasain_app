import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../models/pantry_item.dart';
import '../../../services/data_service.dart';

class PantryInputForm extends StatefulWidget {
  final PantryItem? item;
  final Function(PantryItem) onSave;
  final VoidCallback onCancel;

  const PantryInputForm({
    super.key,
    this.item,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<PantryInputForm> createState() => _PantryInputFormState();
}

class _PantryInputFormState extends State<PantryInputForm> {
  final _formKey = GlobalKey<FormState>();
  final DataService _dataService = DataService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  DateTime? _expirationDate;
  String _selectedCategory = 'Other';
  String _storageLocation = 'Pantry'; // New: Storage location
  bool _isSearching = false; // For ingredient search
  List<String> _filteredIngredients = []; // For ingredient search results

  // Ingredient tracking
  int _totalQuantity = 1;
  bool _lowStockAlert = false;
  bool _expirationAlert = true;

  // Cached ingredient lists
  List<String> _fruitsList = [];
  List<String> _vegetablesList = [];
  List<String> _meatList = [];
  List<String> _dairyList = [];
  List<String> _spicesList = [];
  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Meat',
    'Dairy',
    'Grains',
    'Spices',
    'Bakery',
    'Canned',
    'Beverages',
    'Snacks',
    'Other',
  ];

  final List<String> _storageLocations = [
    'Pantry',
    'Refrigerator',
    'Freezer',
    'Spice Rack',
    'Counter',
    'Other',
  ];

  final List<String> _commonUnits = [
    'kg',
    'g',
    'lbs',
    'oz',
    'pcs',
    'pack',
    'bottle',
    'cup',
    'tbsp',
    'tsp',
    'L',
    'ml',
  ];
  @override
  void initState() {
    super.initState();
    _loadIngredientData();

    if (widget.item != null) {
      _nameController.text = widget.item!.name;

      // Parse quantity and unit
      if (widget.item!.quantity != null) {
        final parts = widget.item!.quantity!.split(' ');
        if (parts.isNotEmpty) {
          _quantityController.text = parts[0];
          if (parts.length > 1) {
            _unitController.text = parts.sublist(1).join(' ');
          }
        }
      }

      _priceController.text =
          widget.item!.price?.replaceAll(RegExp(r'[^\d.]'), '') ?? '';
      _unitController.text = widget.item!.unit ?? '';
      _expirationDate = widget.item!.expirationDate;

      // Validate category against available options
      final category = widget.item!.category ?? 'Other';
      _selectedCategory = _categories.contains(category) ? category : 'Other';

      // Validate storage location against available options
      final storageLocation = widget.item!.storageLocation ?? 'Pantry';
      _storageLocation =
          _storageLocations.contains(storageLocation)
              ? storageLocation
              : 'Pantry';

      _totalQuantity = widget.item!.totalQuantity ?? 1;
      _lowStockAlert = widget.item!.lowStockAlert ?? false;
      _expirationAlert = widget.item!.expirationAlert ?? true;
    }
  }

  Future<void> _loadIngredientData() async {
    try {
      final ingredients = await _dataService.getCommonIngredients();
      final fruits = await _dataService.getFruitsList();
      final vegetables = await _dataService.getVegetablesList();
      final meats = await _dataService.getMeatList();
      final dairy = await _dataService.getDairyList();
      final spices = await _dataService.getSpicesList();

      if (mounted) {
        setState(() {
          _filteredIngredients = ingredients;
          _fruitsList = fruits;
          _vegetablesList = vegetables;
          _meatList = meats;
          _dairyList = dairy;
          _spicesList = spices;
        });
      }
    } catch (e) {
      debugPrint('Error loading ingredient data: $e');
      // Set default values if loading fails
      if (mounted) {
        setState(() {
          _filteredIngredients = [
            'bawang merah',
            'bawang putih',
            'tomat',
            'cabai merah',
            'cabai rawit',
            'wortel',
            'kentang',
            'daging sapi',
            'daging ayam',
            'telur',
            'ikan',
          ];
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterIngredients(String query) {
    setState(() {
      if (query.isEmpty) {
        // Reset to common ingredients when query is empty
        _loadIngredientData();
      } else {
        _filteredIngredients =
            _filteredIngredients
                .where(
                  (ingredient) =>
                      ingredient.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
        if (_isSearching) {
          setState(() {
            _isSearching = false;
          });
        }
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                // Header
                Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: widget.onCancel,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: AppSizes.marginS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item != null ? 'Edit Bahan' : 'Tambah Bahan Baru',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            'Type any ingredient, quantity, and details manually',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Clear button
                    if (_nameController.text.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _nameController.clear();
                            _quantityController.clear();
                            _unitController.clear();
                            _priceController.clear();
                            _expirationDate = null;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                  ],
                ),

                const SizedBox(height: AppSizes.marginL),

                // Ingredient Name with Search
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Bahan',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSizes.marginS),                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Type any ingredient name (e.g. Tomat)',
                        helperText: 'Nama bahan harus unik. Jika sudah ada, coba variasi seperti "Telur Ayam Kampung"',
                        helperMaxLines: 2,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isSearching ? Icons.close : Icons.search,
                            size: AppSizes.iconM,
                          ),
                          onPressed: () {
                            setState(() {
                              _isSearching = !_isSearching;
                              if (_isSearching) {
                                _searchController.text = _nameController.text;
                                _filterIngredients(_searchController.text);
                              }
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingM,
                        ),
                      ),
                      onChanged: (value) {
                        if (_isSearching) {
                          _searchController.text = value;
                          _filterIngredients(value);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Silakan masukkan nama bahan';
                        }
                        return null;
                      },
                    ),

                    // Ingredient Search Results
                    if (_isSearching)
                      Container(
                        height: 200,
                        margin: const EdgeInsets.only(top: AppSizes.marginS),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          border: Border.all(color: AppColors.border),
                        ),
                        child:
                            _filteredIngredients.isEmpty
                                ? const Center(
                                  child: Text('Tidak ada bahan ditemukan'),
                                )
                                : ListView.builder(
                                  itemCount: _filteredIngredients.length,
                                  itemBuilder: (context, index) {
                                    final ingredient =
                                        _filteredIngredients[index];
                                    return ListTile(
                                      title: Text(ingredient),
                                      onTap: () {
                                        setState(() {
                                          _nameController.text = ingredient;
                                          _isSearching = false;

                                          // Auto-set category based on ingredient
                                          if (_fruitsList.contains(
                                            ingredient.toLowerCase(),
                                          )) {
                                            _selectedCategory = 'Fruits';
                                          } else if (_vegetablesList.contains(
                                            ingredient.toLowerCase(),
                                          )) {
                                            _selectedCategory = 'Vegetables';
                                          } else if (_meatList.contains(
                                            ingredient.toLowerCase(),
                                          )) {
                                            _selectedCategory = 'Meat';
                                          } else if (_dairyList.contains(
                                            ingredient.toLowerCase(),
                                          )) {
                                            _selectedCategory = 'Dairy';
                                          } else if (_spicesList.contains(
                                            ingredient.toLowerCase(),
                                          )) {
                                            _selectedCategory = 'Spices';
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                      ),
                  ],
                ),

                const SizedBox(height: AppSizes.marginM),

                // Quantity and Unit (Row)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jumlah',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: AppSizes.marginS),
                          TextFormField(
                            controller: _quantityController,
                            decoration: InputDecoration(
                              hintText: 'e.g. 2',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingM,
                                vertical: AppSizes.paddingM,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.marginM),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Satuan',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: AppSizes.marginS),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusS,
                              ),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(                                  child: TextFormField(
                                    controller: _unitController,
                                    decoration: const InputDecoration(
                                      hintText: 'Type custom unit (e.g. kg, pcs, bunches)',
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.paddingM,
                                        vertical: AppSizes.paddingM,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.arrow_drop_down),
                                  onSelected: (String unit) {
                                    setState(() {
                                      _unitController.text = unit;
                                    });
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return _commonUnits.map((String unit) {
                                      return PopupMenuItem<String>(
                                        value: unit,
                                        child: Text(unit),
                                      );
                                    }).toList();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.marginM),

                // Storage Location
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lokasi Penyimpanan',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSizes.marginS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _storageLocation,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 1,
                          style: Theme.of(context).textTheme.bodyMedium,
                          onChanged: (String? newValue) {
                            setState(() {
                              _storageLocation = newValue!;
                            });
                          },
                          items:
                              _storageLocations.map<DropdownMenuItem<String>>((
                                String value,
                              ) {
                                IconData icon;
                                switch (value) {
                                  case 'Refrigerator':
                                    icon = Icons.kitchen;
                                    break;
                                  case 'Freezer':
                                    icon = Icons.ac_unit;
                                    break;
                                  case 'Spice Rack':
                                    icon = Icons.restaurant;
                                    break;
                                  case 'Counter':
                                    icon = Icons.countertops;
                                    break;
                                  case 'Other':
                                    icon = Icons.more_horiz;
                                    break;
                                  case 'Pantry':
                                  default:
                                    icon = Icons.kitchen_outlined;
                                }
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Icon(icon, size: AppSizes.iconS),
                                      const SizedBox(width: AppSizes.marginS),
                                      Text(value),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.marginM),

                // Expiration Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Kadaluarsa',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSizes.marginS),
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingM,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _expirationDate != null
                                  ? DateFormat(
                                    'dd MMM yyyy',
                                  ).format(_expirationDate!)
                                  : 'Pilih Tanggal (Opsional)',
                              style: TextStyle(
                                color:
                                    _expirationDate != null
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                              ),
                            ),
                            Row(
                              children: [
                                if (_expirationDate != null)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      size: AppSizes.iconS,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _expirationDate = null;
                                      });
                                    },
                                  ),
                                const Icon(
                                  Icons.calendar_today,
                                  size: AppSizes.iconS,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Expiration alert checkbox
                    CheckboxListTile(
                      title: const Text('Ingatkan saat mendekati kadaluarsa'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _expirationAlert,
                      onChanged: (bool? value) {
                        setState(() {
                          _expirationAlert = value ?? false;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.marginM),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harga (Opsional)',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSizes.marginS),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 15000',
                        prefixIcon: Icon(
                          Icons.currency_exchange,
                          size: AppSizes.iconS,
                          color: AppColors.textSecondary,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingM,
                          vertical: AppSizes.paddingM,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.marginM),

                // Category Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSizes.marginS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 1,
                          style: Theme.of(context).textTheme.bodyMedium,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue!;
                            });
                          },
                          items:
                              _categories.map<DropdownMenuItem<String>>((
                                String value,
                              ) {
                                IconData icon;
                                switch (value) {
                                  case 'Vegetables':
                                    icon = Icons.eco;
                                    break;
                                  case 'Fruits':
                                    icon = Icons.apple;
                                    break;
                                  case 'Meat':
                                    icon = Icons.food_bank;
                                    break;
                                  case 'Dairy':
                                    icon = Icons.egg;
                                    break;
                                  case 'Grains':
                                    icon = Icons.grain;
                                    break;
                                  case 'Spices':
                                    icon = Icons.spa;
                                    break;
                                  case 'Bakery':
                                    icon = Icons.bakery_dining;
                                    break;                                  case 'Canned':
                                    icon = Icons.inventory;
                                    break;
                                  case 'Beverages':
                                    icon = Icons.local_drink;
                                    break;
                                  case 'Snacks':
                                    icon = Icons.cookie;
                                    break;
                                  default:
                                    icon = Icons.category;
                                }
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Icon(icon, size: AppSizes.iconS),
                                      const SizedBox(width: AppSizes.marginS),
                                      Text(value),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.marginM),

                // Inventory tracking options
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Opsi Pelacakan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSizes.marginS),

                    // Total quantity tracking
                    Row(
                      children: [
                        const Text('Jumlah Total:'),
                        const SizedBox(width: AppSizes.marginM),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusS,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed:
                                    _totalQuantity > 1
                                        ? () {
                                          setState(() {
                                            _totalQuantity--;
                                          });
                                        }
                                        : null,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: AppSizes.marginS),
                              Text('$_totalQuantity'),
                              const SizedBox(width: AppSizes.marginS),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    _totalQuantity++;
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.marginS),

                    // Low stock alert
                    CheckboxListTile(
                      title: const Text('Ingatkan saat stok menipis'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _lowStockAlert,
                      onChanged: (bool? value) {
                        setState(() {
                          _lowStockAlert = value ?? false;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.marginXL),

                // Button Row
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Cancel',
                        onPressed: widget.onCancel,
                        variant: ButtonVariant.secondary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.marginM),
                    Expanded(
                      child: CustomButton(
                        label: widget.item != null ? 'Update' : 'Tambah',
                        onPressed: _handleSave,
                        variant: ButtonVariant.primary,
                        textStyle: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _expirationDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.background,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }
  // Helper method to sanitize text input to prevent UTF-8 encoding issues
  String _sanitizeText(String text) {
    // Remove any invalid UTF-8 characters and trim whitespace
    return text.trim()
        .replaceAll(RegExp(r'[^\u0000-\u007F\u0080-\uFFFF]'), '') // Remove invalid unicode
        .replaceAll(RegExp(r'[\uFFFD]'), ''); // Remove replacement characters
  }  void _handleSave() {
    debugPrint('🔄 PantryInputForm: _handleSave called');
    debugPrint('🔍 PantryInputForm: Form valid: ${_formKey.currentState!.validate()}');
    
    if (_formKey.currentState!.validate()) {
      final price =
          _priceController.text.isNotEmpty
              ? 'Rp${_sanitizeText(_priceController.text)}'
              : null;

      final quantityText = _sanitizeText(_quantityController.text);
      final unitText = _sanitizeText(_unitController.text);
      
      final quantity =
          quantityText.isNotEmpty
              ? unitText.isNotEmpty
                  ? '$quantityText $unitText'
                  : quantityText
              : null;

      final PantryItem item = PantryItem(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _sanitizeText(_nameController.text),
        quantity: quantity,
        expirationDate: _expirationDate,
        price: price,
        unit: unitText.isNotEmpty ? unitText : null,
        category: _selectedCategory != 'Other' ? _selectedCategory : null,
        storageLocation: _storageLocation,
        totalQuantity: _totalQuantity,
        lowStockAlert: _lowStockAlert,
        expirationAlert: _expirationAlert,
      );

      debugPrint('📦 PantryInputForm: Created item: ${item.name}');
      debugPrint('📝 PantryInputForm: Item data: ${item.toJson()}');
      debugPrint('📤 PantryInputForm: Calling widget.onSave...');
      
      widget.onSave(item);
    } else {
      debugPrint('❌ PantryInputForm: Form validation failed');
    }
  }
}
