import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';

class RecipeFilterWidget extends StatefulWidget {
  final RangeValues priceRange;
  final RangeValues timeRange;
  final Function(RangeValues) onPriceRangeChanged;
  final Function(RangeValues) onTimeRangeChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onResetFilters;

  const RecipeFilterWidget({
    super.key,
    required this.priceRange,
    required this.timeRange,
    required this.onPriceRangeChanged,
    required this.onTimeRangeChanged,
    required this.onApplyFilters,
    required this.onResetFilters,
  });

  @override
  State<RecipeFilterWidget> createState() => _RecipeFilterWidgetState();
}

class _RecipeFilterWidgetState extends State<RecipeFilterWidget> {
  // Price range constants (in Rupiah)
  static const double minPrice = 0;
  static const double maxPrice = 100000; // 100k IDR

  // Time range constants (in minutes)
  static const double minTime = 0;
  static const double maxTime = 180; // 3 hours

  // Price range quick selection buttons
  final List<Map<String, dynamic>> priceRanges = [
    {'label': 'Semua', 'min': 0.0, 'max': 100000.0},
    {'label': '<10k', 'min': 0.0, 'max': 10000.0},
    {'label': '10k-25k', 'min': 10000.0, 'max': 25000.0},
    {'label': '25k-50k', 'min': 25000.0, 'max': 50000.0},
    {'label': '>50k', 'min': 50000.0, 'max': 100000.0},
  ];

  // Time range quick selection buttons
  final List<Map<String, dynamic>> timeRanges = [
    {'label': 'Semua', 'min': 0.0, 'max': 180.0},
    {'label': '<30 mnt', 'min': 0.0, 'max': 30.0},
    {'label': '30-60 mnt', 'min': 30.0, 'max': 60.0},
    {'label': '1-2 jam', 'min': 60.0, 'max': 120.0},
    {'label': '>2 jam', 'min': 120.0, 'max': 180.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusL),
          topRight: Radius.circular(AppSizes.radiusL),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filter Resep',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onResetFilters,
                child: const Text('Reset'),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.marginL),

          // Price Filter
          _buildPriceFilter(),

          const SizedBox(height: AppSizes.marginL),

          // Time Filter
          _buildTimeFilter(),

          const SizedBox(height: AppSizes.marginXL),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApplyFilters();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: const Text(
                'Terapkan Filter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.marginM),
        ],
      ),
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.attach_money, color: AppColors.primary, size: 20),
            const SizedBox(width: AppSizes.marginS),
            Text(
              'Filter Berdasarkan Harga',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.marginM),

        // Quick selection buttons for price
        Wrap(
          spacing: AppSizes.marginS,
          runSpacing: AppSizes.marginS,
          children:
              priceRanges.map((range) {
                final isSelected =
                    widget.priceRange.start == range['min'] &&
                    widget.priceRange.end == range['max'];

                return GestureDetector(
                  onTap: () {
                    widget.onPriceRangeChanged(
                      RangeValues(range['min'], range['max']),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      range['label'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.primary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),

        const SizedBox(height: AppSizes.marginM),

        // Current range display
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp ${_formatPrice(widget.priceRange.start)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'hingga',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                'Rp ${_formatPrice(widget.priceRange.end)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.marginS),

        // Price range slider for fine-tuning
        RangeSlider(
          values: widget.priceRange,
          min: minPrice,
          max: maxPrice,
          divisions: 20,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withOpacity(0.3),
          onChanged: widget.onPriceRangeChanged,
        ),
      ],
    );
  }

  Widget _buildTimeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.success, size: 20),
            const SizedBox(width: AppSizes.marginS),
            Text(
              'Filter Berdasarkan Waktu Memasak',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.marginM),

        // Quick selection buttons for time
        Wrap(
          spacing: AppSizes.marginS,
          runSpacing: AppSizes.marginS,
          children:
              timeRanges.map((range) {
                final isSelected =
                    widget.timeRange.start == range['min'] &&
                    widget.timeRange.end == range['max'];

                return GestureDetector(
                  onTap: () {
                    widget.onTimeRangeChanged(
                      RangeValues(range['min'], range['max']),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.success : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.success
                                : AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      range['label'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.success,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),

        const SizedBox(height: AppSizes.marginM),

        // Current range display
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.timeRange.start.round()} menit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'hingga',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                '${widget.timeRange.end.round()} menit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.marginS),

        // Time range slider for fine-tuning
        RangeSlider(
          values: widget.timeRange,
          min: minTime,
          max: maxTime,
          divisions: 18, // 10-minute intervals
          activeColor: AppColors.success,
          inactiveColor: AppColors.success.withOpacity(0.3),
          onChanged: widget.onTimeRangeChanged,
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}k';
    }
    return price.toStringAsFixed(0);
  }
}
