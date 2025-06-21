import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';

class PantrySearchFilter extends StatefulWidget {
  final String searchQuery;
  final String? selectedCategory;
  final String? selectedLocation;
  final bool showExpiring;
  final bool showLowStock;
  final Function(String) onSearchChanged;
  final Function(String?) onCategoryChanged;
  final Function(String?) onLocationChanged;
  final Function(bool) onExpiringToggled;
  final Function(bool) onLowStockToggled;
  final VoidCallback onClearFilters;

  const PantrySearchFilter({
    super.key,
    required this.searchQuery,
    this.selectedCategory,
    this.selectedLocation,
    required this.showExpiring,
    required this.showLowStock,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onLocationChanged,
    required this.onExpiringToggled,
    required this.onLowStockToggled,
    required this.onClearFilters,
  });

  @override
  State<PantrySearchFilter> createState() => _PantrySearchFilterState();
}

class _PantrySearchFilterState extends State<PantrySearchFilter> {
  late TextEditingController _searchController;
  bool _isFilterExpanded = false;

  final List<String> _categories = [
    'All Categories',
    'Vegetables',
    'Fruits',
    'Meat',
    'Dairy',
    'Grains',
    'Spices',
    'Bakery',
    'Canned',
    'Other',
  ];

  final List<String> _locations = [
    'All Locations',
    'Refrigerator',
    'Freezer',
    'Pantry',
    'Spice Rack',
    'Counter',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Search bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search pantry items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: widget.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              widget.onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingS,
                    ),
                  ),
                  onChanged: widget.onSearchChanged,
                ),
              ),
              const SizedBox(width: AppSizes.marginS),
              // Filter toggle button
              IconButton(
                icon: Icon(
                  _isFilterExpanded ? Icons.filter_list_off : Icons.filter_list,
                  color: _hasActiveFilters() ? AppColors.primary : AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isFilterExpanded = !_isFilterExpanded;
                  });
                },
                tooltip: 'Filters',
              ),
            ],
          ),

          // Expandable filters
          if (_isFilterExpanded) ...[
            const SizedBox(height: AppSizes.marginM),
            _buildFilters(),
          ],

          // Active filters chips
          if (_hasActiveFilters()) ...[
            const SizedBox(height: AppSizes.marginS),
            _buildActiveFiltersChips(),
          ],
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category and Location dropdowns
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: 'Category',
                value: widget.selectedCategory ?? 'All Categories',
                items: _categories,
                onChanged: (value) {
                  widget.onCategoryChanged(
                    value == 'All Categories' ? null : value,
                  );
                },
              ),
            ),
            const SizedBox(width: AppSizes.marginM),
            Expanded(
              child: _buildDropdown(
                label: 'Location',
                value: widget.selectedLocation ?? 'All Locations',
                items: _locations,
                onChanged: (value) {
                  widget.onLocationChanged(
                    value == 'All Locations' ? null : value,
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.marginM),

        // Toggle switches
        Wrap(
          spacing: AppSizes.marginM,
          children: [
            _buildToggleChip(
              label: 'Expiring Soon',
              value: widget.showExpiring,
              onChanged: widget.onExpiringToggled,
              icon: Icons.schedule,
              color: Colors.orange,
            ),
            _buildToggleChip(
              label: 'Low Stock',
              value: widget.showLowStock,
              onChanged: widget.onLowStockToggled,
              icon: Icons.inventory_outlined,
              color: AppColors.error,
            ),
          ],
        ),

        const SizedBox(height: AppSizes.marginM),

        // Clear filters button
        if (_hasActiveFilters())
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
              onPressed: widget.onClearFilters,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              style: Theme.of(context).textTheme.bodyMedium,
              onChanged: onChanged,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: value ? Colors.white : color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: value,
      onSelected: onChanged,
      backgroundColor: AppColors.background,
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: value ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        side: BorderSide(
          color: value ? color : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    final activeFilters = <Widget>[];

    if (widget.selectedCategory != null) {
      activeFilters.add(_buildActiveFilterChip(
        label: widget.selectedCategory!,
        onRemove: () => widget.onCategoryChanged(null),
      ));
    }

    if (widget.selectedLocation != null) {
      activeFilters.add(_buildActiveFilterChip(
        label: widget.selectedLocation!,
        onRemove: () => widget.onLocationChanged(null),
      ));
    }

    if (widget.showExpiring) {
      activeFilters.add(_buildActiveFilterChip(
        label: 'Expiring Soon',
        onRemove: () => widget.onExpiringToggled(false),
      ));
    }

    if (widget.showLowStock) {
      activeFilters.add(_buildActiveFilterChip(
        label: 'Low Stock',
        onRemove: () => widget.onLowStockToggled(false),
      ));
    }

    return Wrap(
      spacing: AppSizes.marginS,
      children: activeFilters,
    );
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      labelStyle: TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      deleteIconColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
    );
  }

  bool _hasActiveFilters() {
    return widget.selectedCategory != null ||
        widget.selectedLocation != null ||
        widget.showExpiring ||
        widget.showLowStock;
  }
}
