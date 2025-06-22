import 'package:flutter/material.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';

class InstructionsSection extends StatefulWidget {
  final List<String> instructions;
  final Function(List<String>) onInstructionsChanged;

  const InstructionsSection({
    super.key,
    required this.instructions,
    required this.onInstructionsChanged,
  });

  @override
  State<InstructionsSection> createState() => _InstructionsSectionState();
}

class _InstructionsSectionState extends State<InstructionsSection> {
  final TextEditingController _instructionController = TextEditingController();

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add instruction input
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Langkah',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSizes.marginM),
              TextField(
                controller: _instructionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Jelaskan langkah memasak dengan detail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.all(AppSizes.paddingM),
                ),
                onSubmitted: (_) => _addInstruction(),
              ),
              const SizedBox(height: AppSizes.marginM),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _instructionController.clear();
                    },
                    child: const Text('Bersihkan'),
                  ),
                  const SizedBox(width: AppSizes.marginS),
                  ElevatedButton.icon(
                    onPressed: _addInstruction,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Langkah'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.marginL),

        // Instructions list
        Expanded(
          child:
              widget.instructions.isEmpty
                  ? _buildEmptyState()
                  : _buildInstructionsList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.list_alt, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.marginL),
          Text(
            'Belum ada langkah',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSizes.marginS),
          Text(
            'Tambahkan langkah-langkah memasak yang mudah diikuti',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Langkah Memasak (${widget.instructions.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.instructions.isNotEmpty)
                  TextButton(
                    onPressed: _clearAllInstructions,
                    child: Text(
                      'Hapus Semua',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              itemCount: widget.instructions.length,
              itemBuilder: (context, index) {
                return _buildInstructionItem(index);
              },
              onReorder: _reorderInstructions,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(int index) {
    return Container(
      key: ValueKey(index),
      margin: const EdgeInsets.only(bottom: AppSizes.marginM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.marginM),

          // Instruction content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Langkah ${index + 1}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.instructions[index],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Action buttons
          Column(
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () => _editInstruction(index),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: () => _removeInstruction(index),
              ),
            ],
          ),

          // Drag handle
          Icon(Icons.drag_handle, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  void _addInstruction() {
    final instruction = _instructionController.text.trim();
    if (instruction.isNotEmpty) {
      final updatedInstructions = List<String>.from(widget.instructions);
      updatedInstructions.add(instruction);
      widget.onInstructionsChanged(updatedInstructions);
      _instructionController.clear();
    }
  }

  void _removeInstruction(int index) {
    final updatedInstructions = List<String>.from(widget.instructions);
    updatedInstructions.removeAt(index);
    widget.onInstructionsChanged(updatedInstructions);
  }

  void _editInstruction(int index) {
    _instructionController.text = widget.instructions[index];
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Langkah ${index + 1}'),
            content: TextField(
              controller: _instructionController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Edit langkah memasak...',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _instructionController.clear();
                  Navigator.pop(context);
                },
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedInstructions = List<String>.from(
                    widget.instructions,
                  );
                  updatedInstructions[index] =
                      _instructionController.text.trim();
                  widget.onInstructionsChanged(updatedInstructions);
                  _instructionController.clear();
                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _reorderInstructions(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final updatedInstructions = List<String>.from(widget.instructions);
    final item = updatedInstructions.removeAt(oldIndex);
    updatedInstructions.insert(newIndex, item);
    widget.onInstructionsChanged(updatedInstructions);
  }

  void _clearAllInstructions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Semua Langkah'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus semua langkah memasak?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  widget.onInstructionsChanged([]);
                  Navigator.pop(context);
                },
                child: Text('Hapus', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
  }
}
