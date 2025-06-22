import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

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

class _FilterRecipeWidgetState extends State<FilterRecipeWidget> {
  // Price range constants (in Rupiah)
  static const double minPrice = 0;
  static const double maxPrice = 100000; // 100k IDR

  // Time range constants (in minutes)
  static const double minTime = 0;
  static const double maxTime = 180; // 3 hours

  late RangeValues _currentPriceRange;
  late RangeValues _currentTimeRange;
  String? _selectedDifficultyLevel;

  // Selected price range index for quick buttons
  int _selectedPriceIndex = 0;
  // Selected time range index for quick buttons
  int _selectedTimeIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentPriceRange = widget.priceRange;
    _currentTimeRange = widget.timeRange;
    _selectedDifficultyLevel = widget.selectedDifficultyLevel;
    _updateSelectedIndices();
  }

  void _updateSelectedIndices() {
    // Update price index based on current range
    if (_currentPriceRange.start == 0 && _currentPriceRange.end == 100000) {
      _selectedPriceIndex = 0; // Semua
    } else if (_currentPriceRange.start == 0 &&
        _currentPriceRange.end == 10000) {
      _selectedPriceIndex = 1; // <10k
    } else if (_currentPriceRange.start == 10000 &&
        _currentPriceRange.end == 25000) {
      _selectedPriceIndex = 2; // 10k-25k
    } else if (_currentPriceRange.start == 25000 &&
        _currentPriceRange.end == 50000) {
      _selectedPriceIndex = 3; // 25k-50k
    } else if (_currentPriceRange.start == 50000 &&
        _currentPriceRange.end == 100000) {
      _selectedPriceIndex = 4; // 50k+
    } else {
      _selectedPriceIndex = -1; // Custom
    }

    // Update time index based on current range
    if (_currentTimeRange.start == 0 && _currentTimeRange.end == 180) {
      _selectedTimeIndex = 0; // Semua
    } else if (_currentTimeRange.start == 0 && _currentTimeRange.end == 30) {
      _selectedTimeIndex = 1; // <30 min
    } else if (_currentTimeRange.start == 30 && _currentTimeRange.end == 60) {
      _selectedTimeIndex = 2; // 30-60 min
    } else if (_currentTimeRange.start == 60 && _currentTimeRange.end == 120) {
      _selectedTimeIndex = 3; // 1-2 jam
    } else if (_currentTimeRange.start == 120 && _currentTimeRange.end == 180) {
      _selectedTimeIndex = 4; // 2+ jam
    } else {
      _selectedTimeIndex = -1; // Custom
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Resep',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentPriceRange = const RangeValues(
                        minPrice,
                        maxPrice,
                      );
                      _currentTimeRange = const RangeValues(minTime, maxTime);
                      _selectedDifficultyLevel = null;
                      _selectedPriceIndex = 0;
                      _selectedTimeIndex = 0;
                    });
                    widget.onPriceRangeChanged(_currentPriceRange);
                    widget.onTimeRangeChanged(_currentTimeRange);
                    widget.onDifficultyLevelChanged(null);
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Filter Section
                  _buildPriceFilterSection(),
                  const SizedBox(height: 32),

                  // Time Filter Section
                  _buildTimeFilterSection(),
                  const SizedBox(height: 32),

                  // Difficulty Level Filter Section
                  _buildDifficultyFilterSection(),
                  const SizedBox(height: 32),

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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Terapkan Filter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rentang Harga',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Quick Price Selection Buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickSelectChip('Semua', 0, true),
            _buildQuickSelectChip('<10k', 1, true),
            _buildQuickSelectChip('10k-25k', 2, true),
            _buildQuickSelectChip('25k-50k', 3, true),
            _buildQuickSelectChip('50k+', 4, true),
          ],
        ),
        const SizedBox(height: 16),

        // Price Range Slider
        Column(
          children: [
            RangeSlider(
              values: _currentPriceRange,
              min: minPrice,
              max: maxPrice,
              divisions: 20,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.primary.withOpacity(0.3),
              labels: RangeLabels(
                _formatPrice(_currentPriceRange.start),
                _formatPrice(_currentPriceRange.end),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentPriceRange = values;
                  _selectedPriceIndex = -1; // Mark as custom
                });
                widget.onPriceRangeChanged(values);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatPrice(_currentPriceRange.start),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatPrice(_currentPriceRange.end),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Waktu Memasak',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Quick Time Selection Buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickSelectChip('Semua', 0, false),
            _buildQuickSelectChip('<30 min', 1, false),
            _buildQuickSelectChip('30-60 min', 2, false),
            _buildQuickSelectChip('1-2 jam', 3, false),
            _buildQuickSelectChip('2+ jam', 4, false),
          ],
        ),
        const SizedBox(height: 16),

        // Time Range Slider
        Column(
          children: [
            RangeSlider(
              values: _currentTimeRange,
              min: minTime,
              max: maxTime,
              divisions: 18,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.primary.withOpacity(0.3),
              labels: RangeLabels(
                _formatTime(_currentTimeRange.start),
                _formatTime(_currentTimeRange.end),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentTimeRange = values;
                  _selectedTimeIndex = -1; // Mark as custom
                });
                widget.onTimeRangeChanged(values);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(_currentTimeRange.start),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatTime(_currentTimeRange.end),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tingkat Kesulitan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (widget.availableDifficultyLevels.isEmpty)
          const Text(
            'Memuat tingkat kesulitan...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          )
        else
          // Single row for all difficulty options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // All option
                _buildDifficultyChip(
                  'Semua',
                  _selectedDifficultyLevel == null,
                  () {
                    setState(() {
                      _selectedDifficultyLevel = null;
                    });
                    widget.onDifficultyLevelChanged(null);
                  },
                ),
                const SizedBox(width: 8),

                // Available difficulty levels in a row
                ...widget.availableDifficultyLevels.map((level) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildDifficultyChip(
                      level,
                      _selectedDifficultyLevel == level,
                      () {
                        setState(() {
                          _selectedDifficultyLevel = level;
                        });
                        widget.onDifficultyLevelChanged(level);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDifficultyChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSelectChip(String label, int index, bool isPrice) {
    final bool isSelected =
        isPrice ? _selectedPriceIndex == index : _selectedTimeIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          if (isPrice) {
            _selectedPriceIndex = index;
            switch (index) {
              case 0: // Semua
                _currentPriceRange = const RangeValues(minPrice, maxPrice);
                break;
              case 1: // <10k
                _currentPriceRange = const RangeValues(0, 10000);
                break;
              case 2: // 10k-25k
                _currentPriceRange = const RangeValues(10000, 25000);
                break;
              case 3: // 25k-50k
                _currentPriceRange = const RangeValues(25000, 50000);
                break;
              case 4: // 50k+
                _currentPriceRange = const RangeValues(50000, maxPrice);
                break;
            }
            widget.onPriceRangeChanged(_currentPriceRange);
          } else {
            _selectedTimeIndex = index;
            switch (index) {
              case 0: // Semua
                _currentTimeRange = const RangeValues(minTime, maxTime);
                break;
              case 1: // <30 min
                _currentTimeRange = const RangeValues(0, 30);
                break;
              case 2: // 30-60 min
                _currentTimeRange = const RangeValues(30, 60);
                break;
              case 3: // 1-2 jam
                _currentTimeRange = const RangeValues(60, 120);
                break;
              case 4: // 2+ jam
                _currentTimeRange = const RangeValues(120, maxTime);
                break;
            }
            widget.onTimeRangeChanged(_currentTimeRange);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatTime(double minutes) {
    if (minutes >= 60) {
      final hours = (minutes / 60).floor();
      final remainingMinutes = (minutes % 60).round();
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
    return '${minutes.round()}m';
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}k';
    }
    return price.toStringAsFixed(0);
  }
}
