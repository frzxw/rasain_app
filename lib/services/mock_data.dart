import '../models/recipe.dart';
import '../models/pantry_item.dart';
import '../models/user_profile.dart';
import '../models/community_post.dart';

/// Mock data with Indonesian-themed content for the Rasain app
class MockData {
  /// List of Indonesian recipes
  static List<Recipe> recipes = [
  //   Recipe(
  //     id: '1',
  //     name: 'Nasi Goreng Kampung',
  //     imageUrl: 'public/assets/images/recipe/1.png',
  //     rating: 4.8,
  //     reviewCount: 245,
  //     estimatedCost: 'Rp25.000',
  //     cookTime: '25 menit',
  //     servings: 2,
  //     description:
  //         'Nasi goreng khas Indonesia dengan cita rasa kampung yang otentikS. Dimasak dengan bumbu tradisional dan tambahan telur mata sapi serta kerupuk.',
  //     categories: ['Makanan Utama', 'Tradisional', 'Pedas'],
  //     ingredients: [
  //       {
  //         'id': '1',
  //         'name': 'Nasi Putih',
  //         'quantity': '2',
  //         'unit': 'piring',
  //         'price': 'Rp5.000',
  //         'image_url': 'public/assets/images/ingredient/nasgor/1.png',
  //       },
  //       {
  //         'id': '2',
  //         'name': 'Bawang Merah',
  //         'quantity': '5',
  //         'unit': 'siung',
  //         'price': 'Rp2.000',
  //         'image_url': 'public/assets/images/ingredient/nasgor/2.png',
  //       },
  //       {
  //         'id': '3',
  //         'name': 'Bawang Putih',
  //         'quantity': '3',
  //         'unit': 'siung',
  //         'price': 'Rp1.500',
  //         'image_url': 'public/assets/images/ingredient/nasgor/3.png',
  //       },
  //       {
  //         'id': '4',
  //         'name': 'Cabai Merah',
  //         'quantity': '4',
  //         'unit': 'buah',
  //         'price': 'Rp2.500',
  //         'image_url': 'public/assets/images/ingredient/nasgor/6.png',
  //       },
  //       {
  //         'id': '5',
  //         'name': 'Telur Ayam',
  //         'quantity': '2',
  //         'unit': 'butir',
  //         'price': 'Rp3.000',
  //         'image_url': 'public/assets/images/ingredient/nasgor/4.png',
  //       },
  //       {
  //         'id': '6',
  //         'name': 'Kecap Manis',
  //         'quantity': '2',
  //         'unit': 'sdm',
  //         'price': 'Rp1.000',
  //         'image_url': 'public/assets/images/ingredient/nasgor/5.png',
  //       },
  //     ],
  //     instructions: [
  //       {
  //         'text': 'Haluskan bawang merah, bawang putih, dan cabai.',
  //         'videoUrl': null,
  //       },
  //       {
  //         'text': 'Panaskan minyak, tumis bumbu halus hingga harum.',
  //         'videoUrl': null,
  //       },
  //       {'text': 'Masukkan nasi putih, aduk rata.', 'videoUrl': null},
  //       {
  //         'text': 'Tambahkan kecap manis, garam, dan penyedap rasa secukupnya.',
  //         'videoUrl': null,
  //       },
  //       {'text': 'Aduk hingga semua bumbu tercampur rata.', 'videoUrl': null},
  //       {'text': 'Goreng telur mata sapi terpisah.', 'videoUrl': null},
  //       {
  //         'text':
  //             'Sajikan nasi goreng dengan telur mata sapi di atasnya dan kerupuk.',
  //         'videoUrl': null,
  //       },
  //     ],
  //     isSaved: true,
  //   ),
  //   Recipe(
  //     id: '2',
  //     name: 'Rendang Daging Sapi',
  //     imageUrl: 'public/assets/images/recipe/2.png',
  //     rating: 4.9,
  //     reviewCount: 312,
  //     estimatedCost: 'Rp85.000',
  //     cookTime: '4 jam',
  //     servings: 6,
  //     description:
  //         'Rendang daging sapi khas Padang dengan rempah-rempah kaya dan santan kelapa yang dimasak hingga empuk dan bumbu meresap sempurna.',
  //     categories: ['Makanan Utama', 'Tradisional', 'Pedas', 'Padang'],
  //     ingredients: [
  //       {
  //         'id': '7',
  //         'name': 'Daging Sapi',
  //         'quantity': '1',
  //         'unit': 'kg',
  //         'price': 'Rp140.000',
  //         'image_url': 'public/assets/images/ingredient/rendang/1.png',
  //       },
  //       {
  //         'id': '8',
  //         'name': 'Santan Kelapa',
  //         'quantity': '2',
  //         'unit': 'liter',
  //         'price': 'Rp25.000',
  //         'image_url': 'public/assets/images/ingredient/rendang/2.png',
  //       },
  //       {
  //         'id': '9',
  //         'name': 'Bumbu Rendang',
  //         'quantity': '1',
  //         'unit': 'paket',
  //         'price': 'Rp15.000',
  //         'image_url': 'public/assets/images/ingredient/rendang/3.png',
  //       },
  //     ],
  //     instructions: [
  //       {
  //         'text':
  //             'Haluskan semua bumbu rendang (bawang merah, bawang putih, cabai, lengkuas, serai, dll).',
  //         'videoUrl': null,
  //       },
  //     ],
  //     isSaved: false,
  //   ),
  //   Recipe(
  //     id: '3',
  //     name: 'Soto Ayam Lamongan',
  //     imageUrl: 'public/assets/images/recipe/3.png',
  //     rating: 4.7,
  //     reviewCount: 178,
  //     estimatedCost: 'Rp35.000',
  //     cookTime: '60 menit',
  //     servings: 4,
  //     description:
  //         'Soto ayam khas Lamongan dengan kuah kuning bening, potongan ayam suwir, dan pelengkap seperti koya, telur rebus, serta sambal.',
  //     categories: ['Sup', 'Tradisional', 'Ayam'],
  //     ingredients: [
  //       {
  //         'id': '10',
  //         'name': 'Ayam Kampung',
  //         'quantity': '1',
  //         'unit': 'ekor',
  //         'price': 'Rp65.000',
  //         'image_url': 'public/assets/images/ingredient/soto_lamongan/1.png',
  //       },
  //       {
  //         'id': '11',
  //         'name': 'Kunyit',
  //         'quantity': '3',
  //         'unit': 'ruas',
  //         'price': 'Rp2.000',
  //         'image_url': 'public/assets/images/ingredient/soto_lamongan/2.png',
  //       },
  //       {
  //         'id': '12',
  //         'name': 'Koya (Kerupuk Udang + Bawang)',
  //         'quantity': '100',
  //         'unit': 'gram',
  //         'price': 'Rp10.000',
  //         'image_url': 'public/assets/images/ingredient/soto_lamongan/3.png',
  //       },
  //     ],
  //     instructions: [
  //       {'text': 'Rebus ayam hingga matang dan empuk.', 'videoUrl': null},
  //       {'text': 'Tumis bumbu halus hingga harum.', 'videoUrl': null},
  //       {'text': 'Masukkan bumbu ke dalam rebusan ayam.', 'videoUrl': null},
  //       {'text': 'Angkat ayam, suwir-suwir dagingnya.', 'videoUrl': null},
  //       {
  //         'text':
  //             'Sajikan kuah soto dengan ayam suwir, telur rebus, tauge, seledri, dan koya di atasnya.',
  //         'videoUrl': null,
  //       },
  //     ],
  //     isSaved: true,
  //   ),
  //   Recipe(
  //     id: '4',
  //     name: 'Martabak Manis Coklat Keju',
  //     imageUrl: 'public/assets/images/recipe/4.png',
  //     rating: 4.6,
  //     reviewCount: 203,
  //     estimatedCost: 'Rp45.000',
  //     cookTime: '30 menit',
  //     servings: 8,
  //     description:
  //         'Kue terang bulan atau martabak manis dengan topping coklat dan keju yang lumer di mulut. Tekstur lembut dan kenyal.',
  //     categories: ['Makanan Penutup', 'Kue', 'Manis'],
  //     ingredients: [
  //       {
  //         'id': '13',
  //         'name': 'Tepung Terigu',
  //         'quantity': '250',
  //         'unit': 'gram',
  //         'price': 'Rp5.000',
  //         'image_url': 'public/assets/images/ingredient/martabak/1.png',
  //       },
  //       {
  //         'id': '14',
  //         'name': 'Gula Pasir',
  //         'quantity': '150',
  //         'unit': 'gram',
  //         'price': 'Rp3.000',
  //         'image_url': 'public/assets/images/ingredient/martabak/2.png',
  //       },
  //       {
  //         'id': '15',
  //         'name': 'Coklat Meses',
  //         'quantity': '100',
  //         'unit': 'gram',
  //         'price': 'Rp10.000',
  //         'image_url': 'public/assets/images/ingredient/martabak/3.png',
  //       },
  //       {
  //         'id': '16',
  //         'name': 'Keju Cheddar',
  //         'quantity': '100',
  //         'unit': 'gram',
  //         'price': 'Rp15.000',
  //         'image_url': 'public/assets/images/ingredient/martabak/4.png',
  //       },
  //     ],
  //     instructions: [
  //       {
  //         'text': 'Campurkan tepung terigu, gula, ragi, dan air. Aduk rata.',
  //         'videoUrl': null,
  //       },
  //       {
  //         'text': 'Diamkan adonan sekitar 30 menit hingga mengembang.',
  //         'videoUrl': null,
  //       },
  //       {
  //         'text': 'Panaskan cetakan martabak dengan api sedang.',
  //         'videoUrl': null,
  //       },
  //       {
  //         'text': 'Tuang adonan ke dalam cetakan, tutup sebentar.',
  //         'videoUrl': null,
  //       },
  //       {
  //         'text':
  //             'Setelah berlubang-lubang, taburi gula pasir dan tutup kembali.',
  //         'videoUrl': null,
  //       },
  //       {
  //         'text':
  //             'Setelah matang, olesi dengan margarin, taburi meses dan keju parut.',
  //         'videoUrl': null,
  //       },
  //       {'text': 'Lipat martabak dan potong sesuai selera.', 'videoUrl': null},
  //     ],
  //     isSaved: false,
  //   ),
  //   Recipe(
  //     id: '5',
  //     name: 'Sate Ayam Madura',
  //     imageUrl: 'public/assets/images/recipe/5.png',
  //     rating: 4.7,
  //     reviewCount: 189,
  //     estimatedCost: 'Rp30.000',
  //     cookTime: '45 menit',
  //     servings: 3,
  //     description:
  //         'Sate ayam khas Madura dengan bumbu kacang yang gurih dan sedikit pedas. Disajikan dengan lontong atau nasi putih.',
  //     categories: ['Makanan Utama', 'Tradisional', 'Daging'],
  //     ingredients: [
  //       {
  //         'id': '17',
  //         'name': 'Ayam Fillet',
  //         'quantity': '500',
  //         'unit': 'gram',
  //         'price': 'Rp35.000',
  //         'image_url': 'public/assets/images/ingredient/sate_madura/1.png',
  //       },
  //       {
  //         'id': '18',
  //         'name': 'Kacang Tanah',
  //         'quantity': '200',
  //         'unit': 'gram',
  //         'price': 'Rp8.000',
  //         'image_url': 'public/assets/images/ingredient/sate_madura/2.png',
  //       },
  //       {
  //         'id': '19',
  //         'name': 'Kecap Manis',
  //         'quantity': '5',
  //         'unit': 'sdm',
  //         'price': 'Rp3.000',
  //         'image_url': 'public/assets/images/ingredient/sate_madura/3.png',
  //       },
  //     ],
  //     instructions: [
  //       {'text': 'Potong ayam fillet menjadi dadu kecil.', 'videoUrl': null},
  //       {'text': 'Rendam ayam dalam bumbu marinasi.', 'videoUrl': null},
  //       {'text': 'Tusuk ayam dengan tusuk sate.', 'videoUrl': null},
  //       {
  //         'text': 'Panggang sate di atas bara api/panggangan.',
  //         'videoUrl': null,
  //       },
  //       {
  //         'text': 'Haluskan kacang tanah goreng dan bumbu saus kacang.',
  //         'videoUrl': null,
  //       },
  //       {
  //         'text': 'Sajikan sate dengan saus kacang dan kecap manis.',
  //         'videoUrl': null,
  //       },
  //     ],
  //     isSaved: true,
  //   ),
  //   Recipe(
  //     id: '6',
  //     name: 'Gado-gado Jakarta',
  //     imageUrl: 'public/assets/images/recipe/6.png',
  //     rating: 4.5,
  //     reviewCount: 156,
  //     estimatedCost: 'Rp20.000',
  //     cookTime: '25 menit',
  //     servings: 2,
  //     description:
  //         'Salad sayuran khas Indonesia dengan saus kacang yang kental dan gurih. Disajikan dengan kerupuk dan telur rebus.',
  //     categories: ['Makanan Utama', 'Tradisional', 'Sayuran'],
  //     ingredients: [
  //       {
  //         'id': '20',
  //         'name': 'Tauge',
  //         'quantity': '100',
  //         'unit': 'gram',
  //         'price': 'Rp2.000',
  //         'image_url': 'public/assets/images/ingredient/gado_gado/1.png',
  //       },
  //       {
  //         'id': '21',
  //         'name': 'Kentang',
  //         'quantity': '2',
  //         'unit': 'buah',
  //         'price': 'Rp5.000',
  //         'image_url': 'public/assets/images/ingredient/gado_gado/2.png',
  //       },
  //       {
  //         'id': '22',
  //         'name': 'Kacang Tanah',
  //         'quantity': '150',
  //         'unit': 'gram',
  //         'price': 'Rp7.000',
  //         'image_url': 'public/assets/images/ingredient/gado_gado/3.png',
  //       },
  //     ],
  //     instructions: [
  //       {'text': 'Rebus semua sayuran hingga matang.', 'videoUrl': null},
  //       {'text': 'Haluskan kacang tanah untuk saus.', 'videoUrl': null},
  //       {'text': 'Tambahkan bumbu-bumbu ke saus kacang.', 'videoUrl': null},
  //       {'text': 'Tata sayuran di piring saji.', 'videoUrl': null},
  //       {
  //         'text': 'Siram dengan saus kacang dan taburi dengan bawang goreng.',
  //         'videoUrl': null,
  //       },
  //     ],
  //     isSaved: false,
  //   ),
  //   Recipe(
  //     id: '7',
  //     name: 'Bakso Malang',
  //     imageUrl: 'public/assets/images/recipe/7.png',
  //     rating: 4.8,
  //     reviewCount: 210,
  //     estimatedCost: 'Rp25.000',
  //     cookTime: '40 menit',
  //     servings: 3,
  //     description:
  //         'Bakso daging sapi dengan tekstur kenyal dan kuah bening yang gurih. Disajikan dengan mie, tahu, dan pangsit.',
  //     categories: ['Makanan Utama', 'Sup', 'Daging'],
  //     ingredients: [
  //       {
  //         'id': '23',
  //         'name': 'Daging Sapi Giling',
  //         'quantity': '500',
  //         'unit': 'gram',
  //         'price': 'Rp60.000',
  //         'image_url': 'public/assets/images/ingredient/bakso/1.png',
  //       },
  //     ],
  //     instructions: [
  //       {
  //         'text': 'Campur daging giling dengan tepung dan bumbu.',
  //         'videoUrl': null,
  //       },
  //       {'text': 'Bentuk adonan menjadi bola-bola.', 'videoUrl': null},
  //       {'text': 'Rebus bakso hingga mengapung.', 'videoUrl': null},
  //       {'text': 'Siapkan kuah dengan bumbu yang gurih.', 'videoUrl': null},
  //       {
  //         'text': 'Sajikan bakso dengan mie, tahu, dan pangsit.',
  //         'videoUrl': null,
  //       },
  //     ],
  //     isSaved: true,
  //   ),
  ];

//   /// List of Indonesia-relevant pantry items
//   static List<PantryItem> pantryItems = [
//     PantryItem(
//       id: '1',
//       name: 'Beras',
//       imageUrl: 'public/assets/images/pantry/1.png',
//       quantity: '5',
//       unit: 'kg',
//       price: 'Rp70.000',
//       category: 'Bahan Pokok',
//       expirationDate: DateTime.now().add(const Duration(days: 120)),
//     ),
//     PantryItem(
//       id: '2',
//       name: 'Telur Ayam',
//       imageUrl: 'public/assets/images/pantry/2.png',
//       quantity: '1',
//       unit: 'kg',
//       price: 'Rp30.000',
//       category: 'Protein',
//       expirationDate: DateTime.now().add(const Duration(days: 14)),
//     ),
//     PantryItem(
//       id: '3',
//       name: 'Kecap Manis Cap Bango',
//       imageUrl: 'public/assets/images/pantry/3.png',
//       quantity: '1',
//       unit: 'botol',
//       price: 'Rp15.000',
//       category: 'Bumbu',
//       expirationDate: DateTime.now().add(const Duration(days: 360)),
//     ),
//     PantryItem(
//       id: '4',
//       name: 'Minyak Goreng',
//       imageUrl: 'public/assets/images/pantry/4.png',
//       quantity: '2',
//       unit: 'liter',
//       price: 'Rp45.000',
//       category: 'Minyak',
//       expirationDate: DateTime.now().add(const Duration(days: 180)),
//     ),
//     PantryItem(
//       id: '5',
//       name: 'Cabai Merah',
//       imageUrl: 'public/assets/images/pantry/5.png',
//       quantity: '250',
//       unit: 'gram',
//       price: 'Rp15.000',
//       category: 'Sayuran',
//       expirationDate: DateTime.now().add(const Duration(days: 7)),
//     ),
//     PantryItem(
//       id: '6',
//       name: 'Tempe',
//       imageUrl: 'public/assets/images/pantry/6.png',
//       quantity: '2',
//       unit: 'papan',
//       price: 'Rp8.000',
//       category: 'Protein',
//       expirationDate: DateTime.now().add(const Duration(days: 5)),
//     ),
//     PantryItem(
//       id: '7',
//       name: 'Santan Kara',
//       imageUrl: 'public/assets/images/pantry/7.png',
//       quantity: '3',
//       unit: 'bungkus',
//       price: 'Rp18.000',
//       category: 'Bumbu',
//       expirationDate: DateTime.now().add(const Duration(days: 120)),
//     ),
//     PantryItem(
//       id: '8',
//       name: 'Terasi Udang',
//       imageUrl: 'public/assets/images/pantry/8.png',
//       quantity: '50',
//       unit: 'gram',
//       price: 'Rp5.000',
//       category: 'Bumbu',
//       expirationDate: DateTime.now().add(const Duration(days: 90)),
//     ),
//   ];

//   /// List of Indonesian user profiles
//   static List<UserProfile> users = [
//     UserProfile(
//       id: '1',
//       name: 'Budi Santoso',
//       email: 'budi.santoso@email.com',
//       imageUrl: 'public/assets/images/profile/1.png',
//       savedRecipesCount: 12,
//       postsCount: 5,
//       isNotificationsEnabled: true,
//       language: 'id',
//       isDarkModeEnabled: false,
//     ),
//     UserProfile(
//       id: '2',
//       name: 'Siti Rahayu',
//       email: 'siti.rahayu@email.com',
//       imageUrl: 'https://i.pravatar.cc/300?img=5',
//       savedRecipesCount: 28,
//       postsCount: 15,
//       isNotificationsEnabled: true,
//       language: 'id',
//       isDarkModeEnabled: true,
//     ),
//     UserProfile(
//       id: '3',
//       name: 'Agus Wijaya',
//       email: 'agus.wijaya@email.com',
//       imageUrl: 'https://i.pravatar.cc/300?img=3',
//       savedRecipesCount: 7,
//       postsCount: 3,
//       isNotificationsEnabled: false,
//       language: 'id',
//       isDarkModeEnabled: false,
//     ),
//     UserProfile(
//       id: '4',
//       name: 'Dewi Lestari',
//       email: 'dewi.lestari@email.com',
//       imageUrl: 'https://i.pravatar.cc/300?img=9',
//       savedRecipesCount: 42,
//       postsCount: 21,
//       isNotificationsEnabled: true,
//       language: 'id',
//       isDarkModeEnabled: true,
//     ),
//   ];

  /// List of Indonesian community posts
  static List<CommunityPost> communityPosts = [
    CommunityPost(
      id: '1',
      userId: '2',
      userName: 'Siti Rahayu',
      userImageUrl: 'https://i.pravatar.cc/300?img=5',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      content:
          'Hari ini saya coba resep rendang daging sapi pertama kali dan hasilnya enak banget! Bumbu meresap sampai ke dalam dan dagingnya empuk. Siapa yang mau resepnya?',
      imageUrl: 'public/assets/images/community/5.png',
      taggedIngredients: ['Daging Sapi', 'Santan', 'Bumbu Rendang'],
      category: 'Makanan Utama',
      likeCount: 45,
      commentCount: 12,
      isLiked: true,
    ),
    CommunityPost(
      id: '4',
      userId: '3',
      userName: 'Agus Wijaya',
      userImageUrl: 'https://i.pravatar.cc/300?img=3',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      content:
          'Berbagi kebahagiaan bersama keluarga dengan masak nasi tumpeng mini untuk ulang tahun istri. Tumpeng kuning dengan lauk pauk tradisional lengkap.',
      imageUrl: 'public/assets/images/community/3.png',
      taggedIngredients: ['Beras', 'Kunyit', 'Ayam', 'Telur'],
      category: 'Tradisional',
      likeCount: 56,
      commentCount: 14,
      isLiked: false,
    ),
  ];

//   /// List of common kitchen tools in Indonesian homes
//   static List<String> kitchenTools = [
//     'Wajan',
//     'Panci',
//     'Dandang',
//     'Cobek & Ulekan',
//     'Serok',
//     'Sutil',
//     'Pisau',
//     'Talenan',
//     'Rice Cooker',
//     'Blender',
//     'Kompor Gas',
//     'Kukusan',
//     'Parutan',
//   ];

//   /// List of common ingredients for search functionality
//   static List<String> commonIngredients = [
//     // Vegetables
//     'bawang merah', 'bawang putih', 'tomat', 'cabai merah', 'cabai rawit',
//     'wortel',
//     'kentang',
//     'ketimun',
//     'brokoli',
//     'kembang kol',
//     'bayam',
//     'kangkung',
//     'terong', 'tauge', 'jagung',

//     // Fruits
//     'apel', 'pisang', 'jeruk', 'stroberi', 'mangga', 'nanas',
//     'semangka',
//     'melon',
//     'pepaya',
//     'alpukat',
//     'jambu biji',
//     'durian',
//     'rambutan',

//     // Spices
//     'lada', 'garam', 'ketumbar', 'jintan', 'pala', 'kayu manis',
//     'cengkeh',
//     'kunyit',
//     'jahe',
//     'lengkuas',
//     'daun salam',
//     'daun jeruk',
//     'serai',

//     // Proteins
//     'daging sapi', 'daging ayam', 'telur', 'ikan', 'udang', 'tempe', 'tahu',

//     // Dairy
//     'susu', 'keju', 'mentega', 'yogurt', 'krim',

//     // Grains
//     'beras', 'tepung terigu', 'tepung tapioka', 'tepung beras', 'mie', 'pasta',

//     // Canned/Processed
//     'sarden kalengan',
//     'kornet',
//     'kecap manis',
//     'kecap asin',
//     'saus tiram',
//     'saus tomat',
//     'minyak goreng', 'santan', 'gula pasir', 'gula merah', 'terasi',

//     // Other
//     'air mineral', 'es batu', 'roti', 'kerupuk', 'kacang tanah', 'kacang hijau',
//   ];

//   /// List of vegetables for category auto-detection
//   static List<String> vegetablesList = [
//     'bawang merah',
//     'bawang putih',
//     'tomat',
//     'cabai merah',
//     'cabai rawit',
//     'wortel',
//     'kentang',
//     'ketimun',
//     'brokoli',
//     'kembang kol',
//     'bayam',
//     'kangkung',
//     'terong',
//     'tauge',
//     'jagung',
//     'labu',
//     'timun',
//     'selada',
//     'kol',
//     'daun bawang',
//     'seledri',
//     'kemangi',
//     'sawi',
//   ];

//   /// List of fruits for category auto-detection
//   static List<String> fruitsList = [
//     'apel',
//     'pisang',
//     'jeruk',
//     'stroberi',
//     'mangga',
//     'nanas',
//     'semangka',
//     'melon',
//     'pepaya',
//     'alpukat',
//     'jambu biji',
//     'durian',
//     'rambutan',
//     'manggis',
//     'kelapa',
//     'kiwi',
//     'lemon',
//     'anggur',
//     'salak',
//     'belimbing',
//   ];

//   /// List of meats for category auto-detection
//   static List<String> meatList = [
//     'daging sapi',
//     'daging ayam',
//     'daging kambing',
//     'daging babi',
//     'daging kelinci',
//     'ikan',
//     'udang',
//     'cumi',
//     'kepiting',
//     'kerang',
//     'telur',
//     'bakso',
//   ];

//   /// List of dairy products for category auto-detection
//   static List<String> dairyList = [
//     'susu',
//     'keju',
//     'mentega',
//     'yogurt',
//     'krim',
//     'es krim',
//     'susu bubuk',
//     'susu kental manis',
//   ];

//   /// List of spices for category auto-detection
//   static List<String> spicesList = [
//     'lada',
//     'garam',
//     'ketumbar',
//     'jintan',
//     'pala',
//     'kayu manis',
//     'vanili',
//     'cengkeh',
//     'kunyit',
//     'jahe',
//     'lengkuas',
//     'daun salam',
//     'daun jeruk',
//     'serai',
//     'cabai bubuk',
//     'kari',
//     'kapulaga',
//     'merica',
//     'adas',
//     'kemiri',
//   ];
// }
