import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/sizes.dart';
import '../../../core/theme/colors.dart';

class ChatInputBox extends StatefulWidget {
  final Function(String) onSendText;
  final Function(List<int>, String) onSendImage;
  
  const ChatInputBox({
    super.key,
    required this.onSendText,
    required this.onSendImage,
  });

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _isComposing = _textController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Camera Button
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: _handleImageSelection,
              splashRadius: 20,
            ),
          ),
          
          // Text Input
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ask something...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingS,
                  vertical: AppSizes.paddingM,
                ),
              ),
              onSubmitted: _isComposing ? _handleSubmitted : null,
            ),
          ),
          
          // Send Button
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: Icon(
                Icons.send,
                color: _isComposing ? AppColors.primary : AppColors.textSecondary,
              ),
              onPressed: _isComposing ? () => _handleSubmitted(_textController.text) : null,
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    widget.onSendText(text.trim());
    _textController.clear();
    _focusNode.requestFocus();
  }

  Future<void> _handleImageSelection() async {
    final ImagePicker picker = ImagePicker();
    final source = await _showImageSourceDialog();
    
    if (source == null) return;
    
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );
    
    if (image == null) return;
    
    try {
      final bytes = await image.readAsBytes();
      widget.onSendImage(bytes, image.name);
    } catch (e) {
      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error processing image. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
