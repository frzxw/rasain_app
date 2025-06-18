import '../models/recipe.dart';
import '../models/pantry_item.dart';
import '../models/community_post.dart';

/// Service untuk menyediakan data fallback ketika database tidak tersedia
class FallbackDataService {
  static List<Recipe> getMockRecipes() {
    return [
      Recipe(
        id: 'fallback-1',
        name: 'Nasi Goreng Kampung',
        description: 'Nasi goreng dengan cita rasa autentik kampung',
        rating: 4.5,
        reviewCount: 25,
        cookTime: '25 menit',
        servings: 2,
        imageUrl:
            'https://via.placeholder.com/300x200/FFA726/FFFFFF?text=Nasi+Goreng',
        ingredients: [
          {'name': 'Nasi putih dingin', 'amount': '2 piring'},
          {'name': 'Telur ayam', 'amount': '2 butir'},
          {'name': 'Bawang merah', 'amount': '3 siung'},
          {'name': 'Bawang putih', 'amount': '2 siung'},
          {'name': 'Kecap manis', 'amount': '2 sdm'},
          {'name': 'Garam', 'amount': '1 sdt'},
          {'name': 'Minyak goreng', 'amount': 'secukupnya'},
        ],
        instructions: [
          {'text': 'Panaskan minyak dalam wajan'},
          {'text': 'Tumis bawang merah dan bawang putih hingga harum'},
          {'text': 'Masukkan telur, orak-arik hingga matang'},
          {'text': 'Masukkan nasi, aduk rata dengan bumbu'},
          {'text': 'Tambahkan kecap manis dan garam'},
          {'text': 'Aduk hingga nasi berwarna merata'},
          {'text': 'Angkat dan sajikan hangat'},
        ],
        categories: ['Makanan Utama', 'Tradisional'],
      ),
      Recipe(
        id: 'fallback-2',
        name: 'Gado-gado Jakarta',
        description: 'Salad sayuran segar dengan bumbu kacang yang gurih',
        rating: 4.7,
        reviewCount: 18,
        cookTime: '30 menit',
        servings: 4,
        imageUrl:
            'https://via.placeholder.com/300x200/66BB6A/FFFFFF?text=Gado-gado',
        ingredients: [
          {'name': 'Tahu', 'amount': '200g'},
          {'name': 'Tempe', 'amount': '200g'},
          {'name': 'Tauge', 'amount': '100g'},
          {'name': 'Kacang panjang', 'amount': '100g'},
          {'name': 'Kentang', 'amount': '2 buah'},
          {'name': 'Telur rebus', 'amount': '2 butir'},
          {'name': 'Bumbu kacang siap pakai', 'amount': '100g'},
          {'name': 'Kerupuk', 'amount': 'secukupnya'},
        ],
        instructions: [
          {'text': 'Rebus kentang, kacang panjang, dan tauge'},
          {'text': 'Goreng tahu dan tempe hingga kecokelatan'},
          {'text': 'Rebus telur hingga matang'},
          {'text': 'Siapkan bumbu kacang'},
          {'text': 'Tata semua bahan di piring saji'},
          {'text': 'Siram dengan bumbu kacang'},
          {'text': 'Taburi kerupuk sebagai pelengkap'},
        ],
        categories: ['Sehat', 'Tradisional', 'Vegetarian'],
      ),
      Recipe(
        id: 'fallback-3',
        name: 'Rendang Daging Sapi',
        description: 'Rendang daging sapi yang empuk dengan rempah yang kaya',
        rating: 4.9,
        reviewCount: 42,
        cookTime: '4 jam',
        servings: 6,
        imageUrl:
            'https://via.placeholder.com/300x200/D32F2F/FFFFFF?text=Rendang',
        ingredients: [
          {'name': 'Daging sapi', 'amount': '1 kg'},
          {'name': 'Santan kental', 'amount': '400ml'},
          {'name': 'Daun jeruk', 'amount': '3 lembar'},
          {'name': 'Serai', 'amount': '2 batang'},
          {'name': 'Daun kunyit', 'amount': '2 lembar'},
          {'name': 'Bumbu halus', 'amount': 'sesuai resep'},
        ],
        instructions: [
          {'text': 'Haluskan semua bumbu'},
          {'text': 'Tumis bumbu halus hingga harum'},
          {'text': 'Masukkan daging, aduk hingga berubah warna'},
          {'text': 'Tuang santan sedikit demi sedikit'},
          {'text': 'Masukkan daun jeruk, serai, dan daun kunyit'},
          {'text': 'Masak dengan api kecil sambil terus diaduk'},
          {'text': 'Masak hingga kuah mengental dan berminyak'},
          {'text': 'Sajikan dengan nasi putih hangat'},
        ],
        categories: ['Makanan Utama', 'Tradisional', 'Pedas'],
      ),
    ];
  }

  static List<PantryItem> getMockPantryItems() {
    return [
      PantryItem(
        id: 'pantry-1',
        name: 'Beras',
        category: 'Makanan Pokok',
        quantity: '5',
        unit: 'kg',
        expirationDate: DateTime.now().add(const Duration(days: 365)),
      ),
      PantryItem(
        id: 'pantry-2',
        name: 'Telur Ayam',
        category: 'Protein',
        quantity: '12',
        unit: 'butir',
        expirationDate: DateTime.now().add(const Duration(days: 14)),
      ),
      PantryItem(
        id: 'pantry-3',
        name: 'Bawang Merah',
        category: 'Bumbu',
        quantity: '0.5',
        unit: 'kg',
        expirationDate: DateTime.now().add(const Duration(days: 30)),
      ),
      PantryItem(
        id: 'pantry-4',
        name: 'Minyak Goreng',
        category: 'Minyak',
        quantity: '2',
        unit: 'liter',
        expirationDate: DateTime.now().add(const Duration(days: 180)),
      ),
    ];
  }

  static List<Map<String, dynamic>> getMockCommunityPosts() {
    return [
      {
        'id': 'post-1',
        'title': 'Tips Membuat Nasi Goreng yang Sempurna',
        'content':
            'Gunakan nasi yang sudah dingin dan jangan terlalu banyak minyak',
        'author': 'Chef Budi',
        'likes': 25,
        'comments': 8,
        'created_at':
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'image_url': null,
      },
      {
        'id': 'post-2',
        'title': 'Resep Rendang Tradisional dari Padang',
        'content':
            'Rendang autentik membutuhkan waktu masak yang lama untuk hasil terbaik',
        'author': 'Ibu Sari',
        'likes': 42,
        'comments': 15,
        'created_at':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'image_url': null,
      },
    ];
  }

  static List<String> getMockKitchenTools() {
    return [
      'Pisau Chef',
      'Wajan Anti Lengket',
      'Panci Stainless Steel',
      'Talenan Kayu',
      'Spatula',
      'Sendok Sayur',
      'Blender',
      'Rice Cooker',
      'Kompor Gas',
      'Piring Saji',
    ];
  }
}
