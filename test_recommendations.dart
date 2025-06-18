import 'package:flutter/foundation.dart';
import 'lib/services/home_data_service.dart';

void main() {
  debugPrint('🧪 Testing HomeDataService...');

  final homeRecipes = HomeDataService.getHomeRecipes();
  debugPrint('✅ Home recipes: ${homeRecipes.length}');

  final featuredRecipes = HomeDataService.getFeaturedRecipes();
  debugPrint('✅ Featured recipes: ${featuredRecipes.length}');

  final recommendedRecipes = HomeDataService.getRecommendedRecipes();
  debugPrint('✅ Recommended recipes: ${recommendedRecipes.length}');

  debugPrint('🎉 Test completed!');
}
