import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart'; // Remove VideoPlayer import
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/custom_button.dart';

class InstructionSteps extends StatefulWidget {
  final List<Map<String, dynamic>> instructions;
  
  const InstructionSteps({
    super.key,
    required this.instructions,
  });

  @override
  State<InstructionSteps> createState() => _InstructionStepsState();
}

class _InstructionStepsState extends State<InstructionSteps> {
  Set<int> _expandedSteps = {};
  bool _expandAll = false;
  // Remove VideoPlayerController map

  @override
  void initState() {
    super.initState();
    // Initially expand first step
    if (widget.instructions.isNotEmpty) {
      _expandedSteps = {0};
      // Remove video controller initialization
    }
  }
  
  // Remove _initializeVideoControllers method

  @override
  void dispose() {
    // Remove video controller disposal
    super.dispose();
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
    final step = widget.instructions[index];
    final String instructionText = step['text'] ?? '';
    final String? videoUrl = step['videoUrl'];
    
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
                // Remove video controller actions
              } else {
                _expandedSteps.remove(index);
                // Remove video controller actions
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
              
              // Step Title
              Expanded(
                child: Text(
                  _getStepTitle(instructionText),
                  style: TextStyle(
                    fontWeight: isExpanded ? FontWeight.w600 : FontWeight.normal,
                    color: isExpanded ? AppColors.primary : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Video indicator icon
              if (videoUrl != null && videoUrl.isNotEmpty)
                const Icon(
                  Icons.videocam,
                  color: AppColors.highlight,
                  size: AppSizes.iconS,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instruction text
                  Text(
                    instructionText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  // Video player (if video URL exists)
                  if (videoUrl != null && videoUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.paddingM),
                      child: _buildVideoPlayer(videoUrl),
                    ),
                  
                  // "Jump to Next Step" button for better navigation
                  if (index < widget.instructions.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.paddingM),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.arrow_downward),
                          label: const Text('Next Step'),
                          onPressed: () {
                            setState(() {
                              _expandedSteps.remove(index);
                              _expandedSteps.add(index + 1);
                              
                              // Ensure the next step is visible
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Scrollable.ensureVisible(
                                  context,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              });
                            });
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVideoPlayer(String videoUrl) {
    // Remove VideoPlayer implementation
    return Column(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: const Center(
            child: Icon(Icons.videocam, size: 50, color: AppColors.textSecondary),
          ),
        ),
        TextButton.icon(
          icon: const Icon(Icons.open_in_new),
          label: const Text('Watch Video'),
          onPressed: () {
            _openVideoFullscreen(videoUrl);
          },
        ),
      ],
    );
  }
  
  Future<void> _openVideoFullscreen(String videoUrl) async {
    try {
      final Uri url = Uri.parse(videoUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open video link'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening video: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
