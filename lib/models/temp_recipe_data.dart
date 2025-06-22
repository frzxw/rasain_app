import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

/// Class untuk menyimpan data resep sementara ketika user belum login
class TempRecipeData {
  final String name;
  final String description;
  final int servings;
  final int cookingTime;
  final String category;
  final List<String> ingredients;
  final List<String> instructions;
  final List<XFile> images;
  final List<Uint8List> imageBytes; // For web preview

  const TempRecipeData({
    required this.name,
    required this.description,
    required this.servings,
    required this.cookingTime,
    required this.category,
    required this.ingredients,
    required this.instructions,
    required this.images,
    required this.imageBytes,
  });

  /// Checks if the recipe data is valid for submission
  bool get isValid {
    return name.trim().isNotEmpty &&
        category.isNotEmpty &&
        ingredients.isNotEmpty &&
        instructions.isNotEmpty;
  }

  /// Creates an empty temp recipe data
  static const TempRecipeData empty = TempRecipeData(
    name: '',
    description: '',
    servings: 1,
    cookingTime: 30,
    category: '',
    ingredients: [],
    instructions: [],
    images: [],
    imageBytes: [],
  );

  @override
  String toString() {
    return 'TempRecipeData{name: $name, ingredients: ${ingredients.length}, instructions: ${instructions.length}}';
  }
}
