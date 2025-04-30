import '../models/recipe.dart';
import '../models/pantry_item.dart';
import '../models/user_profile.dart';
import '../models/community_post.dart';
import '../models/chat_message.dart';

/// Mock data with Indonesian-themed content for the Rasain app
class MockData {
  /// List of Indonesian recipes
  static List<Recipe> recipes = [
    Recipe(
      id: '1',
      name: 'Nasi Goreng Kampung',
      imageUrl: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=600&h=400&q=80',
      rating: 4.8,
      reviewCount: 245,
      estimatedCost: 'Rp25.000',
      cookTime: '25 menit',
      servings: 2,
      description: 'Nasi goreng khas Indonesia dengan cita rasa kampung yang otentik. Dimasak dengan bumbu tradisional dan tambahan telur mata sapi serta kerupuk.',
      categories: ['Makanan Utama', 'Tradisional', 'Pedas'],
      ingredients: [
        {
          'id': '1',
          'name': 'Nasi Putih',
          'quantity': '2',
          'unit': 'piring',
          'price': 'Rp5.000',
          'image_url': 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&h=150&q=80'
        },
        {
          'id': '2',
          'name': 'Bawang Merah',
          'quantity': '5',
          'unit': 'siung',
          'price': 'Rp2.000',
          'image_url': 'https://placeholder.com/150x150/B22222/FFFFFF?text=Bawang+Merah'
        },
        {
          'id': '3',
          'name': 'Bawang Putih',
          'quantity': '3',
          'unit': 'siung',
          'price': 'Rp1.500',
          'image_url': 'https://placeholder.com/150x150/FFFFFF/000000?text=Bawang+Putih'
        },
        {
          'id': '4',
          'name': 'Cabai Merah',
          'quantity': '4',
          'unit': 'buah',
          'price': 'Rp2.500',
          'image_url': 'https://placeholder.com/150x150/FF0000/FFFFFF?text=Cabai+Merah'
        },
        {
          'id': '5',
          'name': 'Telur Ayam',
          'quantity': '2',
          'unit': 'butir',
          'price': 'Rp3.000',
          'image_url': 'https://placeholder.com/150x150/FFF8DC/000000?text=Telur+Ayam'
        },
        {
          'id': '6',
          'name': 'Kecap Manis',
          'quantity': '2',
          'unit': 'sdm',
          'price': 'Rp1.000',
          'image_url': 'https://placeholder.com/150x150/4A2100/FFFFFF?text=Kecap+Manis'
        }
      ],
      instructions: [
        'Haluskan bawang merah, bawang putih, dan cabai.',
        'Panaskan minyak, tumis bumbu halus hingga harum.',
        'Masukkan nasi putih, aduk rata.',
        'Tambahkan kecap manis, garam, dan penyedap rasa secukupnya.',
        'Aduk hingga semua bumbu tercampur rata.',
        'Goreng telur mata sapi terpisah.',
        'Sajikan nasi goreng dengan telur mata sapi di atasnya dan kerupuk.'
      ],
      isSaved: true,
    ),
    Recipe(
      id: '2',
      name: 'Rendang Daging Sapi',
      imageUrl: 'https://images.unsplash.com/photo-1628689469838-524a4a973b8e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=600&h=400&q=80',
      rating: 4.9,
      reviewCount: 312,
      estimatedCost: 'Rp85.000',
      cookTime: '4 jam',
      servings: 6,
      description: 'Rendang daging sapi khas Padang dengan rempah-rempah kaya dan santan kelapa yang dimasak hingga empuk dan bumbu meresap sempurna.',
      categories: ['Makanan Utama', 'Tradisional', 'Pedas', 'Padang'],
      ingredients: [
        {
          'id': '7',
          'name': 'Daging Sapi',
          'quantity': '1',
          'unit': 'kg',
          'price': 'Rp140.000',
          'image_url': 'https://placeholder.com/150x150/8B0000/FFFFFF?text=Daging+Sapi'
        },
        {
          'id': '8',
          'name': 'Santan Kelapa',
          'quantity': '2',
          'unit': 'liter',
          'price': 'Rp25.000',
          'image_url': 'https://placeholder.com/150x150/FFFFFF/000000?text=Santan+Kelapa'
        },
        {
          'id': '9',
          'name': 'Bumbu Rendang',
          'quantity': '1',
          'unit': 'paket',
          'price': 'Rp15.000',
          'image_url': 'https://placeholder.com/150x150/CD853F/000000?text=Bumbu+Rendang'
        }
      ],
      instructions: [
        'Haluskan semua bumbu rendang (bawang merah, bawang putih, cabai, lengkuas, serai, dll).',
        'Tumis bumbu halus hingga harum dan matang.',
        'Masukkan daging sapi, aduk rata dengan bumbu.',
        'Tuang santan, masak dengan api kecil sambil sesekali diaduk.',
        'Masak hingga santan menyusut dan daging empuk (sekitar 3-4 jam).',
        'Rendang siap disajikan dengan nasi putih hangat.'
      ],
      isSaved: false,
    ),
    Recipe(
      id: '3',
      name: 'Soto Ayam Lamongan',
      imageUrl: 'https://images.unsplash.com/photo-1593001872095-7d5b3868dd30?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=600&h=400&q=80',
      rating: 4.7,
      reviewCount: 178,
      estimatedCost: 'Rp35.000',
      cookTime: '60 menit',
      servings: 4,
      description: 'Soto ayam khas Lamongan dengan kuah kuning bening, potongan ayam suwir, dan pelengkap seperti koya, telur rebus, serta sambal.',
      categories: ['Sup', 'Tradisional', 'Ayam'],
      ingredients: [
        {
          'id': '10',
          'name': 'Ayam Kampung',
          'quantity': '1',
          'unit': 'ekor',
          'price': 'Rp65.000',
          'image_url': 'https://placeholder.com/150x150/F5DEB3/000000?text=Ayam+Kampung'
        },
        {
          'id': '11',
          'name': 'Kunyit',
          'quantity': '3',
          'unit': 'ruas',
          'price': 'Rp2.000',
          'image_url': 'https://placeholder.com/150x150/FFA500/000000?text=Kunyit'
        },
        {
          'id': '12',
          'name': 'Koya (Kerupuk Udang + Bawang)',
          'quantity': '100',
          'unit': 'gram',
          'price': 'Rp10.000',
          'image_url': 'https://placeholder.com/150x150/FAFAD2/000000?text=Koya'
        }
      ],
      instructions: [
        'Rebus ayam hingga matang dan empuk.',
        'Tumis bumbu halus hingga harum.',
        'Masukkan bumbu ke dalam rebusan ayam.',
        'Angkat ayam, suwir-suwir dagingnya.',
        'Sajikan kuah soto dengan ayam suwir, telur rebus, tauge, seledri, dan koya di atasnya.'
      ],
      isSaved: true,
    ),
    Recipe(
      id: '4',
      name: 'Martabak Manis Coklat Keju',
      imageUrl: 'https://images.unsplash.com/photo-1529402754141-f043d81841d8?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=600&h=400&q=80',
      rating: 4.6,
      reviewCount: 203,
      estimatedCost: 'Rp45.000',
      cookTime: '30 menit',
      servings: 8,
      description: 'Kue terang bulan atau martabak manis dengan topping coklat dan keju yang lumer di mulut. Tekstur lembut dan kenyal.',
      categories: ['Makanan Penutup', 'Kue', 'Manis'],
      ingredients: [
        {
          'id': '13',
          'name': 'Tepung Terigu',
          'quantity': '250',
          'unit': 'gram',
          'price': 'Rp5.000',
          'image_url': 'https://placeholder.com/150x150/FFFFF0/000000?text=Tepung+Terigu'
        },
        {
          'id': '14',
          'name': 'Gula Pasir',
          'quantity': '150',
          'unit': 'gram',
          'price': 'Rp3.000',
          'image_url': 'https://placeholder.com/150x150/FFFFFF/000000?text=Gula+Pasir'
        },
        {
          'id': '15',
          'name': 'Coklat Meses',
          'quantity': '100',
          'unit': 'gram',
          'price': 'Rp10.000',
          'image_url': 'https://placeholder.com/150x150/3B1E00/FFFFFF?text=Coklat+Meses'
        },
        {
          'id': '16',
          'name': 'Keju Cheddar',
          'quantity': '100',
          'unit': 'gram',
          'price': 'Rp15.000',
          'image_url': 'https://placeholder.com/150x150/FFCC33/000000?text=Keju+Cheddar'
        }
      ],
      instructions: [
        'Campurkan tepung terigu, gula, ragi, dan air. Aduk rata.',
        'Diamkan adonan sekitar 30 menit hingga mengembang.',
        'Panaskan cetakan martabak dengan api sedang.',
        'Tuang adonan ke dalam cetakan, tutup sebentar.',
        'Setelah berlubang-lubang, taburi gula pasir dan tutup kembali.',
        'Setelah matang, olesi dengan margarin, taburi meses dan keju parut.',
        'Lipat martabak dan potong sesuai selera.'
      ],
      isSaved: false,
    ),
    Recipe(
      id: '5',
      name: 'Sate Ayam Madura',
      imageUrl: 'https://images.unsplash.com/photo-1529563021893-cc83c992d75d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=600&h=400&q=80',
      rating: 4.7,
      reviewCount: 189,
      estimatedCost: 'Rp30.000',
      cookTime: '45 menit',
      servings: 3,
      description: 'Sate ayam khas Madura dengan bumbu kacang yang gurih dan sedikit pedas. Disajikan dengan lontong atau nasi putih.',
      categories: ['Makanan Utama', 'Tradisional', 'Daging'],
      ingredients: [
        {
          'id': '17',
          'name': 'Ayam Fillet',
          'quantity': '500',
          'unit': 'gram',
          'price': 'Rp35.000',
          'image_url': 'https://placeholder.com/150x150/FFF5EE/000000?text=Ayam+Fillet'
        },
        {
          'id': '18',
          'name': 'Kacang Tanah',
          'quantity': '200',
          'unit': 'gram',
          'price': 'Rp8.000',
          'image_url': 'https://placeholder.com/150x150/D2B48C/000000?text=Kacang+Tanah'
        },
        {
          'id': '19',
          'name': 'Kecap Manis',
          'quantity': '5',
          'unit': 'sdm',
          'price': 'Rp3.000',
          'image_url': 'https://placeholder.com/150x150/4A2100/FFFFFF?text=Kecap+Manis'
        }
      ],
      instructions: [
        'Potong ayam fillet menjadi dadu kecil.',
        'Rendam ayam dalam bumbu marinasi.',
        'Tusuk ayam dengan tusuk sate.',
        'Panggang sate di atas bara api/panggangan.',
        'Haluskan kacang tanah goreng dan bumbu saus kacang.',
        'Sajikan sate dengan saus kacang dan kecap manis.'
      ],
      isSaved: true,
    ),
    Recipe(
      id: '6',
      name: 'Gado-gado Jakarta',
      imageUrl: 'https://images.unsplash.com/photo-1562128755-08b8e992ce63?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&h=400&q=80',
      rating: 4.5,
      reviewCount: 156,
      estimatedCost: 'Rp20.000',
      cookTime: '25 menit',
      servings: 2,
      description: 'Salad sayuran khas Indonesia dengan saus kacang yang kental dan gurih. Disajikan dengan kerupuk dan telur rebus.',
      categories: ['Makanan Utama', 'Tradisional', 'Sayuran'],
      ingredients: [
        {
          'id': '20',
          'name': 'Tauge',
          'quantity': '100',
          'unit': 'gram',
          'price': 'Rp2.000',
          'image_url': 'https://images.unsplash.com/photo-1573590330099-d6c7355ec595?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&h=150&q=80'
        },
        {
          'id': '21',
          'name': 'Kentang',
          'quantity': '2',
          'unit': 'buah',
          'price': 'Rp5.000',
          'image_url': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&h=150&q=80'
        },
        {
          'id': '22',
          'name': 'Kacang Tanah',
          'quantity': '150',
          'unit': 'gram',
          'price': 'Rp7.000',
          'image_url': 'https://images.unsplash.com/photo-1567315143464-34a4acf97337?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&h=150&q=80'
        }
      ],
      instructions: [
        'Rebus semua sayuran hingga matang.',
        'Haluskan kacang tanah untuk saus.',
        'Tambahkan bumbu-bumbu ke saus kacang.',
        'Tata sayuran di piring saji.',
        'Siram dengan saus kacang dan taburi dengan bawang goreng.'
      ],
      isSaved: false,
    ),
    Recipe(
      id: '7',
      name: 'Bakso Malang',
      imageUrl: 'https://images.unsplash.com/photo-1585032767761-878270336a0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&h=400&q=80',
      rating: 4.8,
      reviewCount: 210,
      estimatedCost: 'Rp25.000',
      cookTime: '40 menit',
      servings: 3,
      description: 'Bakso daging sapi dengan tekstur kenyal dan kuah bening yang gurih. Disajikan dengan mie, tahu, dan pangsit.',
      categories: ['Makanan Utama', 'Sup', 'Daging'],
      ingredients: [
        {
          'id': '23',
          'name': 'Daging Sapi Giling',
          'quantity': '500',
          'unit': 'gram',
          'price': 'Rp60.000',
          'image_url': 'https://images.unsplash.com/photo-1602470521006-8c09ceeef197?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&h=150&q=80'
        }
      ],
      instructions: [
        'Campur daging giling dengan tepung dan bumbu.',
        'Bentuk adonan menjadi bola-bola.',
        'Rebus bakso hingga mengapung.',
        'Siapkan kuah dengan bumbu yang gurih.',
        'Sajikan bakso dengan mie, tahu, dan pangsit.'
      ],
      isSaved: true,
    ),
  ];

  /// List of Indonesia-relevant pantry items
  static List<PantryItem> pantryItems = [
    PantryItem(
      id: '1',
      name: 'Beras',
      imageUrl: 'https://placeholder.com/150x150/FFFFFF/000000?text=Beras',
      quantity: '5',
      unit: 'kg',
      price: 'Rp70.000',
      category: 'Bahan Pokok',
      expirationDate: DateTime.now().add(const Duration(days: 120)),
    ),
    PantryItem(
      id: '2',
      name: 'Telur Ayam',
      imageUrl: 'https://placeholder.com/150x150/FFF8DC/000000?text=Telur+Ayam',
      quantity: '1',
      unit: 'kg',
      price: 'Rp30.000',
      category: 'Protein',
      expirationDate: DateTime.now().add(const Duration(days: 14)),
    ),
    PantryItem(
      id: '3',
      name: 'Kecap Manis Cap Bango',
      imageUrl: 'https://placeholder.com/150x150/4A2100/FFFFFF?text=Kecap+Bango',
      quantity: '1',
      unit: 'botol',
      price: 'Rp15.000',
      category: 'Bumbu',
      expirationDate: DateTime.now().add(const Duration(days: 360)),
    ),
    PantryItem(
      id: '4',
      name: 'Minyak Goreng',
      imageUrl: 'https://placeholder.com/150x150/FFD700/000000?text=Minyak+Goreng',
      quantity: '2',
      unit: 'liter',
      price: 'Rp45.000',
      category: 'Minyak',
      expirationDate: DateTime.now().add(const Duration(days: 180)),
    ),
    PantryItem(
      id: '5',
      name: 'Cabai Merah',
      imageUrl: 'https://placeholder.com/150x150/FF0000/FFFFFF?text=Cabai+Merah',
      quantity: '250',
      unit: 'gram',
      price: 'Rp15.000',
      category: 'Sayuran',
      expirationDate: DateTime.now().add(const Duration(days: 7)),
    ),
    PantryItem(
      id: '6',
      name: 'Tempe',
      imageUrl: 'https://placeholder.com/150x150/DEB887/000000?text=Tempe',
      quantity: '2',
      unit: 'papan',
      price: 'Rp8.000',
      category: 'Protein',
      expirationDate: DateTime.now().add(const Duration(days: 5)),
    ),
    PantryItem(
      id: '7',
      name: 'Santan Kara',
      imageUrl: 'https://placeholder.com/150x150/FFFAF0/000000?text=Santan+Kara',
      quantity: '3',
      unit: 'bungkus',
      price: 'Rp18.000',
      category: 'Bumbu',
      expirationDate: DateTime.now().add(const Duration(days: 120)),
    ),
    PantryItem(
      id: '8',
      name: 'Terasi Udang',
      imageUrl: 'https://placeholder.com/150x150/8B4513/FFFFFF?text=Terasi+Udang',
      quantity: '50',
      unit: 'gram',
      price: 'Rp5.000',
      category: 'Bumbu',
      expirationDate: DateTime.now().add(const Duration(days: 90)),
    ),
  ];

  /// List of Indonesian user profiles
  static List<UserProfile> users = [
    UserProfile(
      id: '1',
      name: 'Budi Santoso',
      email: 'budi.santoso@email.com',
      imageUrl: 'https://i.pravatar.cc/300?img=1',
      savedRecipesCount: 12,
      postsCount: 5,
      isNotificationsEnabled: true,
      language: 'id',
      isDarkModeEnabled: false,
    ),
    UserProfile(
      id: '2',
      name: 'Siti Rahayu',
      email: 'siti.rahayu@email.com',
      imageUrl: 'https://i.pravatar.cc/300?img=5',
      savedRecipesCount: 28,
      postsCount: 15,
      isNotificationsEnabled: true,
      language: 'id',
      isDarkModeEnabled: true,
    ),
    UserProfile(
      id: '3',
      name: 'Agus Wijaya',
      email: 'agus.wijaya@email.com',
      imageUrl: 'https://i.pravatar.cc/300?img=3',
      savedRecipesCount: 7,
      postsCount: 3,
      isNotificationsEnabled: false,
      language: 'id',
      isDarkModeEnabled: false,
    ),
    UserProfile(
      id: '4',
      name: 'Dewi Lestari',
      email: 'dewi.lestari@email.com',
      imageUrl: 'https://i.pravatar.cc/300?img=9',
      savedRecipesCount: 42,
      postsCount: 21,
      isNotificationsEnabled: true,
      language: 'id',
      isDarkModeEnabled: true,
    ),
  ];

  /// List of Indonesian community posts
  static List<CommunityPost> communityPosts = [
    CommunityPost(
      id: '1',
      userId: '2',
      userName: 'Siti Rahayu',
      userImageUrl: 'https://i.pravatar.cc/300?img=5',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      content: 'Hari ini saya coba resep rendang daging sapi pertama kali dan hasilnya enak banget! Bumbu meresap sampai ke dalam dan dagingnya empuk. Siapa yang mau resepnya?',
      imageUrl: 'https://placekitten.com/600/400?image=6',
      taggedIngredients: ['Daging Sapi', 'Santan', 'Bumbu Rendang'],
      category: 'Makanan Utama',
      likeCount: 45,
      commentCount: 12,
      isLiked: true,
    ),
    CommunityPost(
      id: '2',
      userId: '4',
      userName: 'Dewi Lestari',
      userImageUrl: 'https://i.pravatar.cc/300?img=9',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      content: 'Tips untuk membuat sambal yang tidak pahit: jangan sampai biji cabai ikut dihaluskan, dan tumis sampai matang dengan api sedang. Ini sambal bawang buatan saya, pedas nikmat!',
      imageUrl: 'https://placekitten.com/600/400?image=7',
      taggedIngredients: ['Cabai Rawit', 'Bawang Merah', 'Bawang Putih'],
      category: 'Tips Memasak',
      likeCount: 78,
      commentCount: 23,
      isLiked: false,
    ),
    CommunityPost(
      id: '3',
      userId: '1',
      userName: 'Budi Santoso',
      userImageUrl: 'https://i.pravatar.cc/300?img=1',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      content: 'Ada yang pernah coba membuat es cendol sendiri di rumah? Saya baru coba resep dari nenek dan hasilnya mirip yang dijual di jalan. Segarnya pas untuk cuaca panas Jakarta!',
      imageUrl: 'https://placekitten.com/600/400?image=8',
      taggedIngredients: ['Tepung Hunkwe', 'Daun Pandan', 'Gula Merah', 'Santan'],
      category: 'Minuman',
      likeCount: 34,
      commentCount: 8,
      isLiked: true,
    ),
    CommunityPost(
      id: '4',
      userId: '3',
      userName: 'Agus Wijaya',
      userImageUrl: 'https://i.pravatar.cc/300?img=3',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      content: 'Berbagi kebahagiaan bersama keluarga dengan masak nasi tumpeng mini untuk ulang tahun istri. Tumpeng kuning dengan lauk pauk tradisional lengkap.',
      imageUrl: 'https://placekitten.com/600/400?image=9',
      taggedIngredients: ['Beras', 'Kunyit', 'Ayam', 'Telur'],
      category: 'Tradisional',
      likeCount: 56,
      commentCount: 14,
      isLiked: false,
    ),
  ];

  /// List of common kitchen tools in Indonesian homes
  static List<String> kitchenTools = [
    'Wajan',
    'Panci',
    'Dandang',
    'Cobek & Ulekan',
    'Serok',
    'Sutil',
    'Pisau',
    'Talenan',
    'Rice Cooker',
    'Blender',
    'Kompor Gas',
    'Kukusan',
    'Parutan',
  ];
}