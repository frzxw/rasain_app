import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/recipe_service.dart';
import 'upload_recipe_state.dart';

class UploadRecipeCubit extends Cubit<UploadRecipeState> {
  final RecipeService _recipeService;

  UploadRecipeCubit({RecipeService? recipeService})
    : _recipeService = recipeService ?? RecipeService(),
      super(const UploadRecipeState());

  Future<void> uploadRecipe({
    required String name,
    required String description,
    required int servings,
    required int cookingTime,
    required String category,
    required List<String> ingredients,
    required List<String> instructions,
    List<XFile>? images,
  }) async {
    emit(state.copyWith(status: UploadRecipeStatus.loading));

    try {
      // Upload to service using named parameters
      final result = await _recipeService.createUserRecipe(
        name: name,
        description: description,
        servings: servings,
        cookingTime: cookingTime,
        category: category,
        ingredients: ingredients,
        instructions: instructions,
        images: images,
      );

      if (result != null) {
        emit(state.copyWith(status: UploadRecipeStatus.success));
      } else {
        emit(
          state.copyWith(
            status: UploadRecipeStatus.error,
            errorMessage: 'Failed to create recipe',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: UploadRecipeStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void reset() {
    emit(const UploadRecipeState());
  }
}
