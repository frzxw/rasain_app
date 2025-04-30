import '../models/recipe.dart';
import 'mock_data.dart';

/// A mock implementation of API service that returns our Indonesian-themed mock data
class MockApiService {
  // Return mock data instead of making actual API calls
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    // Add a small delay to simulate network request
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Handle different endpoints
    if (endpoint == 'recipes/popular') {
      return {
        'recipes': MockData.recipes
            .where((recipe) => recipe.rating >= 4.7)
            .map((recipe) => recipe.toJson())
            .toList(),
      };
    } 
    else if (endpoint == 'recipes/latest') {
      return {
        'recipes': MockData.recipes.map((recipe) => recipe.toJson()).toList(),
      };
    }
    else if (endpoint == 'recipes/saved') {
      return {
        'recipes': MockData.recipes
            .where((recipe) => recipe.isSaved)
            .map((recipe) => recipe.toJson())
            .toList(),
      };
    }
    else if (endpoint == 'recipes/recommendations') {
      // Return recommended Indonesian recipes from mock data
      // For realistic recommendations, mix some traditional and popular recipes
      final traditionalRecipes = MockData.recipes.where((recipe) => 
        recipe.categories != null && recipe.categories!.any((cat) => cat.toLowerCase().contains('tradisional'))
      ).take(3).toList();
      
      final highRatedRecipes = MockData.recipes.where((recipe) => recipe.rating >= 4.5).take(2).toList();
      
      // Combine both lists, avoiding duplicates
      final recommendedRecipes = [...traditionalRecipes];
      for (final recipe in highRatedRecipes) {
        if (!recommendedRecipes.any((r) => r.id == recipe.id)) {
          recommendedRecipes.add(recipe);
        }
      }
      
      return {
        'recipes': recommendedRecipes.map((recipe) => recipe.toJson()).toList(),
      };
    }
    else if (endpoint == 'recipes/pantry') {
      // Return recipes based on what's in the pantry
      final pantryItemNames = MockData.pantryItems.map((item) => item.name.toLowerCase()).toList();
      
      // Filter recipes that have at least one ingredient from pantry
      final pantryRecipes = MockData.recipes.where((recipe) {
        if (recipe.ingredients == null) return false;
        
        return recipe.ingredients!.any((ingredient) {
          final ingredientName = ingredient['name'].toString().toLowerCase();
          return pantryItemNames.any((pantryItem) => ingredientName.contains(pantryItem));
        });
      }).toList();
      
      return {
        'recipes': pantryRecipes.map((recipe) => recipe.toJson()).toList(),
      };
    }
    else if (endpoint == 'user/profile') {
      return {
        'user': MockData.users[0].toJson(),
      };
    }
    else if (endpoint == 'pantry/items') {
      return {
        'items': MockData.pantryItems.map((item) => item.toJson()).toList(),
      };
    }
    else if (endpoint == 'pantry/tools') {
      return {
        'tools': MockData.kitchenTools,
      };
    }
    else if (endpoint == 'community/posts') {
      return {
        'posts': MockData.communityPosts.map((post) => post.toJson()).toList(),
      };
    }
    else if (endpoint == 'chat/history') {
      // Create mock chat history with Indonesian food-related conversations
      final chatHistory = [
        {
          'id': '1',
          'content': 'Selamat datang di Rasain. Ada yang bisa saya bantu dengan masakan Indonesia?',
          'type': 'text',
          'sender': 'assistant',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        },
        {
          'id': '2',
          'content': 'Saya ingin belajar membuat rendang. Apa bahan-bahannya?',
          'type': 'text',
          'sender': 'user',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, minutes: 1)).toIso8601String(),
        },
        {
          'id': '3',
          'content': 'Untuk membuat rendang yang otentik, Anda memerlukan: daging sapi (1 kg), santan kelapa (2 liter), lengkuas, serai, daun kunyit, daun jeruk, bawang merah, bawang putih, cabai, jahe, dan bumbu rempah lainnya. Apakah Anda ingin resep lengkapnya?',
          'type': 'text',
          'sender': 'assistant',
          'timestamp': DateTime.now().subtract(const Duration(days: 2, minutes: 2)).toIso8601String(),
        },
        {
          'id': '4',
          'content': 'Ya, tolong berikan resep lengkapnya',
          'type': 'text',
          'sender': 'user',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'id': '5',
          'content': 'Berikut resep rendang daging sapi khas Padang:\n\n1. Potong 1 kg daging sapi menjadi ukuran sedang\n2. Haluskan bumbu: 10 cabai merah, 5 cabai rawit, 12 bawang merah, 5 bawang putih, 4 cm jahe, 4 cm lengkuas, 3 cm kunyit, 1 sdt ketumbar, 4 butir kemiri\n3. Tumis bumbu halus, masukkan 3 batang serai, 5 lembar daun jeruk, dan 2 lembar daun kunyit\n4. Masukkan daging, aduk hingga berubah warna\n5. Tuang 2 liter santan, masak dengan api kecil selama 3-4 jam sambil diaduk\n6. Bumbui dengan garam dan gula secukupnya\n7. Masak hingga kuah mengental dan daging empuk\n\nSelamat mencoba!',
          'type': 'text',
          'sender': 'assistant',
          'timestamp': DateTime.now().subtract(const Duration(days: 1, minutes: 1)).toIso8601String(),
        },
      ];
      
      return {
        'messages': chatHistory,
      };
    }
    else if (endpoint == 'auth/me') {
      // Return the first user as the authenticated user
      return {
        'user': MockData.users[0].toJson(),
      };
    }
    else if (endpoint.startsWith('recipes/') && endpoint.split('/').length == 2) {
      // Get recipe by ID
      final recipeId = endpoint.split('/')[1];
      final recipe = MockData.recipes.firstWhere(
        (recipe) => recipe.id == recipeId,
        orElse: () => throw Exception('Recipe not found'),
      );
      
      return {
        'recipe': recipe.toJson(),
      };
    }
    else if (endpoint == 'recipes/search') {
      // Search recipes by name
      final query = (queryParams?['query'] ?? '').toLowerCase();
      
      if (query.isEmpty) {
        return {
          'recipes': [],
        };
      }
      
      final searchResults = MockData.recipes.where((recipe) {
        // Search in name and description
        final inName = recipe.name.toLowerCase().contains(query);
        final inDescription = recipe.description?.toLowerCase().contains(query) ?? false;
        
        // Search in ingredients
        bool inIngredients = false;
        if (recipe.ingredients != null) {
          inIngredients = recipe.ingredients!.any((ingredient) => 
            ingredient['name'].toString().toLowerCase().contains(query)
          );
        }
        
        return inName || inDescription || inIngredients;
      }).toList();
      
      return {
        'recipes': searchResults.map((recipe) => recipe.toJson()).toList(),
      };
    }
    else if (endpoint == 'recipes/filter') {
      // Filter recipes by category
      final category = queryParams?['category']?.toLowerCase() ?? '';
      
      if (category.isEmpty || category == 'all') {
        return {
          'recipes': MockData.recipes.map((recipe) => recipe.toJson()).toList(),
        };
      }
      
      final filteredRecipes = MockData.recipes.where((recipe) {
        return recipe.categories?.any(
          (cat) => cat.toLowerCase().contains(category)
        ) ?? false;
      }).toList();
      
      return {
        'recipes': filteredRecipes.map((recipe) => recipe.toJson()).toList(),
      };
    }
    else if (endpoint == 'recipes/suggestions') {
      // Return some recipes as suggestions based on pantry items
      return {
        'recipes': MockData.recipes.take(3).map((recipe) => recipe.toJson()).toList(),
      };
    }
    
    // Default fallback
    return {
      'message': 'No mock data available for this endpoint: $endpoint',
    };
  }
  
  // Mock POST request
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    // Add a small delay to simulate network request
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (endpoint.contains('/save')) {
      return {
        'message': 'Recipe saved successfully',
        'success': true,
      };
    }
    
    if (endpoint.contains('/rate')) {
      return {
        'message': 'Recipe rated successfully',
        'success': true,
      };
    }
    
    if (endpoint == 'auth/login') {
      // Mock successful login
      return {
        'user': MockData.users[0].toJson(),
        'token': 'mock_auth_token_123',
        'success': true,
      };
    }
    
    if (endpoint == 'auth/register') {
      // Mock successful registration
      return {
        'user': MockData.users[0].toJson(),
        'token': 'mock_auth_token_123',
        'success': true,
      };
    }
    
    if (endpoint == 'chat/message') {
      // Create a mock AI response based on the user message
      final userMessage = body?['content'] ?? '';
      String aiResponse;
      
      if (userMessage.toLowerCase().contains('rendang')) {
        aiResponse = 'Rendang adalah masakan daging yang berasal dari Minangkabau, Sumatera Barat. Rendang diolah dengan santan dan rempah-rempah hingga kering dan berwarna gelap. Ini adalah salah satu masakan terenak di dunia!';
      } else if (userMessage.toLowerCase().contains('nasi goreng')) {
        aiResponse = 'Nasi goreng adalah makanan khas Indonesia yang sangat populer. Anda bisa menambahkan berbagai bahan seperti telur, ayam, udang, dan sayuran. Kecap manis adalah bahan kunci untuk nasi goreng yang otentik.';
      } else if (userMessage.toLowerCase().contains('sambal')) {
        aiResponse = 'Ada banyak jenis sambal di Indonesia, seperti sambal terasi, sambal matah dari Bali, dan sambal dabu-dabu dari Manado. Masing-masing memiliki cita rasa unik dan pedas yang berbeda.';
      } else {
        aiResponse = 'Terima kasih atas pertanyaannya. Indonesia memiliki budaya kuliner yang sangat kaya dengan lebih dari 5000 resep tradisional. Ada masakan tertentu yang ingin Anda ketahui?';
      }
      
      return {
        'message': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': aiResponse,
          'type': 'text',
          'sender': 'assistant',
          'timestamp': DateTime.now().toIso8601String(),
        },
        'success': true,
      };
    }
    
    return {
      'message': 'Operation completed successfully',
      'success': true,
    };
  }
  
  // Mock PUT request
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (endpoint == 'auth/profile' || endpoint == 'auth/settings') {
      // Return updated user
      return {
        'user': {
          ...MockData.users[0].toJson(),
          ...?body,
        },
        'success': true,
      };
    }
    
    if (endpoint == 'pantry/tools') {
      return {
        'tools': body?['tools'] ?? [],
        'success': true,
      };
    }
    
    return {
      'message': 'Updated successfully',
      'success': true,
    };
  }
  
  // Mock DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (endpoint == 'chat/history') {
      return {
        'message': 'Chat history cleared successfully',
        'success': true,
      };
    }
    
    return {
      'message': 'Deleted successfully',
      'success': true,
    };
  }
  
  // Mock file upload
  Future<Map<String, dynamic>> uploadFile(
    String endpoint, 
    List<int> fileBytes, 
    String fileName, 
    String fieldName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    // For image search, just return some matching recipes
    if (endpoint == 'recipes/search/image') {
      // Randomly select 1-3 recipes as "detected" from the image
      final samples = MockData.recipes.take(3).map((recipe) => recipe.toJson()).toList();
      
      return {
        'recipes': samples,
        'message': 'Items detected in image',
      };
    }
    
    if (endpoint == 'chat/image') {
      // Return a placeholder image URL and a mock AI response about the image
      return {
        'image_url': 'https://placekitten.com/500/300',
        'message': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': 'Saya melihat makanan Indonesia dalam gambar tersebut. Ini terlihat seperti hidangan tradisional yang sangat lezat!',
          'type': 'text',
          'sender': 'assistant',
          'timestamp': DateTime.now().toIso8601String(),
        },
        'success': true,
      };
    }
    
    if (endpoint == 'pantry/detect') {
      // Return a couple of sample detected items
      return {
        'detected_items': [
          MockData.pantryItems[0].toJson(),
          MockData.pantryItems[2].toJson(),
        ],
        'success': true,
      };
    }
    
    return {
      'message': 'File uploaded successfully',
      'success': true,
    };
  }
}