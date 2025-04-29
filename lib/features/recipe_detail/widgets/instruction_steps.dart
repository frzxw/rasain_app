import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/custom_button.dart';

class InstructionSteps extends StatefulWidget {
  final List<String> instructions;
  
  const InstructionSteps({
    Key? key,
    required this.instructions,
  }) : super(key: key);

  @override
  State<InstructionSteps> createState() => _InstructionStepsState();
}

class _InstructionStepsState extends State<InstructionSteps> {
  Set<int> _expandedSteps = {};
  bool _expandAll = false;

  @override
  void initState() {
    super.initState();
    // Initially expand first step
    if (widget.instructions.isNotEmpty) {
      _expandedSteps = {0};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.instructions.isEmpty) {
      return _buildEmptyState(context);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expand/Collapse All Button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _toggleExpandAll,
            icon: Icon(
              _expandAll ? Icons.unfold_less : Icons.unfold_more,
              size: AppSizes.iconS,
            ),
            label: Text(_expandAll ? 'Collapse All' : 'Expand All'),
          ),
        ),
        
        const SizedBox(height: AppSizes.marginS),
        
        // Instruction Steps
        ...List.generate(widget.instructions.length, (index) {
          return _buildInstructionStep(index);
        }),
        
        const SizedBox(height: AppSizes.marginM),
        
        // Cook Now Button
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            label: 'Start Cooking',
            icon: Icons.play_arrow,
            variant: ButtonVariant.primary,
            onPressed: () {
              // This could start a guided cooking mode or timer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cooking mode starting...'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(int index) {
    final isExpanded = _expandedSteps.contains(index) || _expandAll;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        side: BorderSide(
          color: isExpanded ? AppColors.primary.withOpacity(0.3) : AppColors.border,
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      elevation: 0,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              if (expanded) {
                _expandedSteps.add(index);
              } else {
                _expandedSteps.remove(index);
              }
            });
          },
          backgroundColor: isExpanded ? AppColors.primary.withOpacity(0.05) : null,
          collapsedBackgroundColor: AppColors.background,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusM)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusM)),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Step Number Circle
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isExpanded ? AppColors.primary : AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isExpanded ? AppColors.onPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: AppSizes.marginM),
              
              // Step Title (first 20 characters of instruction)
              Expanded(
                child: Text(
                  _getStepTitle(widget.instructions[index]),
                  style: TextStyle(
                    fontWeight: isExpanded ? FontWeight.w600 : FontWeight.normal,
                    color: isExpanded ? AppColors.primary : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSizes.paddingL + 28,
                right: AppSizes.paddingL,
                bottom: AppSizes.paddingL,
              ),
              child: Text(
                widget.instructions[index],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle(String instruction) {
    // Get first few words as the title
    if (instruction.length <= 30) {
      return instruction;
    }
    
    // Find a space around the 30th character
    final cutoffIndex = instruction.indexOf(' ', 30);
    if (cutoffIndex == -1 || cutoffIndex > 50) {
      // If no space found or it's too far, just cut at 30
      return '${instruction.substring(0, 30)}...';
    } else {
      return '${instruction.substring(0, cutoffIndex)}...';
    }
  }

  void _toggleExpandAll() {
    setState(() {
      _expandAll = !_expandAll;
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.menu_book_outlined,
            size: AppSizes.iconL,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSizes.marginM),
          Text(
            'No instructions available',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'This recipe doesn\'t have any instructions listed yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
