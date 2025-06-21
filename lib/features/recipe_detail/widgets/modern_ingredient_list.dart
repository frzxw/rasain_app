import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class ModernIngredientList extends StatefulWidget {
  final List<Map<String, dynamic>> ingredients;
  
  const ModernIngredientList({
    super.key,
    required this.ingredients,
  });

  @override
  State<ModernIngredientList> createState() => _ModernIngredientListState();
}

class _ModernIngredientListState extends State<ModernIngredientList>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Set<int> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ingredients.isEmpty) {
      return _buildEmptyState(context);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_basket,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bahan-bahan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.ingredients.length} item',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Total: ${_calculateTotalCost()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _checkedIngredients.length / widget.ingredients.length,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_checkedIngredients.length}/${widget.ingredients.length}',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Ingredients list
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                children: List.generate(
                  widget.ingredients.length,
                  (index) => _buildModernIngredientItem(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernIngredientItem(int index) {
    final ingredient = widget.ingredients[index];
    final isChecked = _checkedIngredients.contains(index);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isChecked ? AppColors.success.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isChecked ? AppColors.success : Colors.grey[300]!,
          width: isChecked ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              if (isChecked) {
                _checkedIngredients.remove(index);
              } else {
                _checkedIngredients.add(index);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox with animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isChecked ? AppColors.success : Colors.transparent,
                    border: Border.all(
                      color: isChecked ? AppColors.success : Colors.grey[400]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isChecked
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                
                const SizedBox(width: 16),

                // Ingredient image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ingredient['image_url'] != null
                        ? Image.network(
                            ingredient['image_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                                size: 24,
                              );
                            },
                          )
                        : Icon(
                            Icons.fastfood,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Ingredient details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ingredient['name'] ?? 'Unknown ingredient',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isChecked ? Colors.grey[600] : Colors.black87,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),                      Row(
                        children: [
                          if (ingredient['quantity'] != null || ingredient['unit'] != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatQuantityWithUnit(ingredient),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (ingredient['price'] != null)
                            Text(
                              ingredient['price'].toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action button
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_shopping_cart,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _calculateTotalCost() {
    double totalCost = 0.0;
    
    for (final ingredient in widget.ingredients) {
      if (ingredient['price'] != null) {
        final priceString = ingredient['price'].toString();
        final numericPrice = double.tryParse(
          priceString.replaceAll(RegExp(r'[^\d.]'), '')
        ) ?? 0.0;
        
        totalCost += numericPrice;
      }
    }
    
    return 'Rp ${totalCost.toStringAsFixed(0)}';
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_basket_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada bahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resep ini belum memiliki daftar bahan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatQuantityWithUnit(Map<String, dynamic> ingredient) {
    final quantity = ingredient['quantity'];
    final unit = ingredient['unit'];
    
    if (quantity == null && unit == null) {
      return '';
    }
    
    String result = '';
    
    if (quantity != null) {
      // Format quantity - bisa berupa angka atau string
      if (quantity is num) {
        // Jika angka, format dengan proper decimal places
        if (quantity % 1 == 0) {
          result = quantity.toInt().toString();
        } else {
          result = quantity.toString();
        }
      } else {
        result = quantity.toString();
      }
    }
    
    if (unit != null && unit.toString().isNotEmpty) {
      if (result.isNotEmpty) {
        result += ' ${unit.toString()}';
      } else {
        result = unit.toString();
      }
    }
    
    return result;
  }
}
