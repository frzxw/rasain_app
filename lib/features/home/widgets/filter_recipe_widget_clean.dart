import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/constants/sizes.dart';

class FilterRecipeWidget extends StatefulWidget {
  final RangeValues priceRange;
  final RangeValues timeRange;
  final String? selectedDifficultyLevel;
  final List<String> availableDifficultyLevels;
  final Function(RangeValues) onPriceRangeChanged;
  final Function(RangeValues) onTimeRangeChanged;
  final Function(String?) onDifficultyLevelChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onResetFilters;

  const FilterRecipeWidget({
    super.key,
    required this.priceRange,
    required this.timeRange,
    this.selectedDifficultyLevel,
    this.availableDifficultyLevels = const [],
    required this.onPriceRangeChanged,
    required this.onTimeRangeChanged,
    required this.onDifficultyLevelChanged,
    required this.onApplyFilters,
    required this.onResetFilters,
  });

  @override
  State<FilterRecipeWidget> createState() => _FilterRecipeWidgetState();
}

class _FilterRecipeWidgetState extends State<FilterRecipeWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 50),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusXL),
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPriceFilter(),
                          const SizedBox(height: AppSizes.marginXL),
                          _buildTimeFilter(),
                          const SizedBox(height: AppSizes.marginXL),
                          _buildDifficultyFilter(),
                          const SizedBox(height: AppSizes.marginXL * 2),
                        ],
                      ),
                    ),
                  ),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(Icons.tune, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSizes.marginM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Resep',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Temukan resep sesuai preferensi Anda',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFilter() {
    return _buildFilterSection(
      title: 'Estimasi Biaya',
      subtitle:
          'Rp ${_formatCurrency(widget.priceRange.start.round())} - Rp ${_formatCurrency(widget.priceRange.end.round())}',
      icon: Icons.attach_money,
      child: Column(
        children: [
          const SizedBox(height: AppSizes.marginM),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              valueIndicatorColor: AppColors.primary,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: RangeSlider(
              values: widget.priceRange,
              min: 0,
              max: 100000,
              divisions: 20,
              labels: RangeLabels(
                'Rp ${_formatCurrency(widget.priceRange.start.round())}',
                'Rp ${_formatCurrency(widget.priceRange.end.round())}',
              ),
              onChanged: widget.onPriceRangeChanged,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceChip('Murah', const RangeValues(0, 25000)),
              _buildPriceChip('Sedang', const RangeValues(25000, 50000)),
              _buildPriceChip('Mahal', const RangeValues(50000, 100000)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilter() {
    return _buildFilterSection(
      title: 'Waktu Memasak',
      subtitle:
          '${widget.timeRange.start.round()} - ${widget.timeRange.end.round()} menit',
      icon: Icons.access_time,
      child: Column(
        children: [
          const SizedBox(height: AppSizes.marginM),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.success,
              inactiveTrackColor: AppColors.success.withOpacity(0.2),
              thumbColor: AppColors.success,
              overlayColor: AppColors.success.withOpacity(0.2),
              valueIndicatorColor: AppColors.success,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: RangeSlider(
              values: widget.timeRange,
              min: 0,
              max: 120,
              divisions: 24,
              labels: RangeLabels(
                '${widget.timeRange.start.round()}m',
                '${widget.timeRange.end.round()}m',
              ),
              onChanged: widget.onTimeRangeChanged,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeChip('Cepat', const RangeValues(0, 30)),
              _buildTimeChip('Sedang', const RangeValues(30, 60)),
              _buildTimeChip('Lama', const RangeValues(60, 120)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    return _buildFilterSection(
      title: 'Tingkat Kesulitan',
      subtitle: widget.selectedDifficultyLevel ?? 'Pilih tingkat kesulitan',
      icon: Icons.bar_chart,
      child: Column(
        children: [
          const SizedBox(height: AppSizes.marginM),
          Wrap(
            spacing: AppSizes.marginM,
            runSpacing: AppSizes.marginS,
            children: [
              _buildDifficultyChip('Mudah', Colors.green),
              _buildDifficultyChip('Sedang', Colors.orange),
              _buildDifficultyChip('Sulit', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSizes.marginM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildPriceChip(String label, RangeValues range) {
    final isSelected =
        widget.priceRange.start == range.start &&
        widget.priceRange.end == range.end;

    return GestureDetector(
      onTap: () => widget.onPriceRangeChanged(range),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(String label, RangeValues range) {
    final isSelected =
        widget.timeRange.start == range.start &&
        widget.timeRange.end == range.end;

    return GestureDetector(
      onTap: () => widget.onTimeRangeChanged(range),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.success : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: isSelected ? AppColors.success : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String label, Color color) {
    final isSelected = widget.selectedDifficultyLevel == label;

    return GestureDetector(
      onTap: () => widget.onDifficultyLevelChanged(isSelected ? null : label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: AppSizes.paddingM,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.marginS),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onResetFilters,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingM,
                ),
                side: BorderSide(color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: Text(
                'Reset',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.marginM),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: widget.onApplyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Terapkan Filter',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000) {
      if (amount >= 1000000) {
        return '${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}jt';
      }
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 0)}rb';
    }
    return amount.toString();
  }
}
