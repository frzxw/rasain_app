import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../models/pantry_item.dart';

class PantryInputForm extends StatefulWidget {
  final PantryItem? item;
  final Function(PantryItem) onSave;
  final VoidCallback onCancel;
  
  const PantryInputForm({
    Key? key,
    this.item,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<PantryInputForm> createState() => _PantryInputFormState();
}

class _PantryInputFormState extends State<PantryInputForm> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  
  DateTime? _expirationDate;
  String _selectedCategory = 'Other';
  
  final List<String> _categories = [
    'Vegetables', 'Fruits', 'Meat', 'Dairy', 
    'Grains', 'Spices', 'Bakery', 'Canned', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _quantityController.text = widget.item!.quantity ?? '';
      _priceController.text = widget.item!.price?.replaceAll(RegExp(r'[^\d.]'), '') ?? '';
      _unitController.text = widget.item!.unit ?? '';
      _expirationDate = widget.item!.expirationDate;
      _selectedCategory = widget.item!.category ?? 'Other';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                widget.item != null ? 'Edit Ingredient' : 'Add New Ingredient',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              
              const SizedBox(height: AppSizes.marginL),
              
              // Name
              _buildTextField(
                controller: _nameController,
                label: 'Ingredient Name',
                hint: 'e.g. Tomato',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an ingredient name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppSizes.marginM),
              
              // Quantity and Unit (Row)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _quantityController,
                      label: 'Quantity',
                      hint: 'e.g. 2',
                    ),
                  ),
                  const SizedBox(width: AppSizes.marginM),
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: _unitController,
                      label: 'Unit',
                      hint: 'e.g. kg, pcs',
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
                    'Expiration Date',
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
                                ? DateFormat('MMM dd, yyyy').format(_expirationDate!)
                                : 'Select Date (Optional)',
                            style: TextStyle(
                              color: _expirationDate != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today,
                            size: AppSizes.iconS,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSizes.marginM),
              
              // Price
              _buildTextField(
                controller: _priceController,
                label: 'Price (Optional)',
                hint: 'e.g. 2.99',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(
                  Icons.attach_money,
                  size: AppSizes.iconS,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: AppSizes.marginM),
              
              // Category Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
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
                        items: _categories.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
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
                      label: widget.item != null ? 'Update' : 'Add',
                      onPressed: _handleSave,
                      variant: ButtonVariant.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSizes.marginS),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingM,
            ),
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 7)),
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

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final price = _priceController.text.isNotEmpty
          ? '\$${_priceController.text}'
          : null;
      
      final PantryItem item = PantryItem(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        quantity: _quantityController.text.trim().isNotEmpty
            ? '${_quantityController.text.trim()} ${_unitController.text.trim()}'
            : null,
        expirationDate: _expirationDate,
        price: price,
        unit: _unitController.text.trim().isNotEmpty ? _unitController.text.trim() : null,
        category: _selectedCategory != 'Other' ? _selectedCategory : null,
      );
      
      widget.onSave(item);
    }
  }
}
