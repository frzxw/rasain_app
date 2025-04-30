import '../models/recipe.dart';
import '../models/pantry_item.dart';
import '../models/user_profile.dart';
import '../models/community_post.dart';

/// Mock data with Indonesian-themed content for the Rasain app
class MockData {
  /// List of Indonesian recipes
  static List<Recipe> recipes = [
    Recipe(
      id: '1',
      name: 'Nasi Goreng Kampung',
      imageUrl: 'https://www.istockphoto.com/photo/yummy-nasi-goreng-tiwul-ikan-asin-pete-or-stink-bean-petai-petes-salted-fish-tiwul-gm2171902924-591703175?utm_campaign=srp_photos_top&utm_content=https%3A%2F%2Funsplash.com%2Fs%2Fphotos%2Fnasi-goreng&utm_medium=affiliate&utm_source=unsplash&utm_term=nasi+goreng%3A%3A%3A',
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
          'image_url': 'https://www.freepik.com/free-photo/rice-cooked-white-dish_8085222.htm#fromView=keyword&page=1&position=0&uuid=1293548d-f718-4064-96fe-3b83662b524b&query=Nasi+Putih'
        },
        {
          'id': '2',
          'name': 'Bawang Merah',
          'quantity': '5',
          'unit': 'siung',
          'price': 'Rp2.000',
          'image_url': 'https://www.google.com/imgres?q=bawang%20merah%20HD&imgurl=https%3A%2F%2Fimages.tokopedia.net%2Fimg%2Fcache%2F700%2Fproduct-1%2F2020%2F6%2F18%2F99105105%2F99105105_707d145c-e762-4543-9189-7e1ee3d5a247_800_800&imgrefurl=https%3A%2F%2Fwww.tokopedia.com%2Faeeshastore-1%2Fbawang-merah-batu-bawang-merah-besar-bawang-merah-1000-gram&docid=8VTYIAc99lTZHM&tbnid=KzI_zRhM6fPkQM&vet=12ahUKEwi4s5698_-MAxXV8zgGHWMeF34QM3oECHcQAA..i&w=700&h=700&hcb=2&ved=2ahUKEwi4s5698_-MAxXV8zgGHWMeF34QM3oECHcQAA'
        },
        {
          'id': '3',
          'name': 'Bawang Putih',
          'quantity': '3',
          'unit': 'siung',
          'price': 'Rp1.500',
          'image_url': 'https://www.google.com/imgres?q=bawang%20putih%20HD&imgurl=https%3A%2F%2Fwww.lapakbuah.com%2Fwp-content%2Fuploads%2F2021%2F07%2Fbawang-putih.jpg&imgrefurl=https%3A%2F%2Fhome.lapakbuah.com%2Fproduct%2Fbawang-putih-500gram%2F&docid=NuOuQ3QpwuAvaM&tbnid=YFAODz_9v7PvEM&vet=12ahUKEwjljq7b8_-MAxVLyzgGHcZHOpoQM3oECFsQAA..i&w=499&h=334&hcb=2&ved=2ahUKEwjljq7b8_-MAxVLyzgGHcZHOpoQM3oECFsQAA'
        },
        {
          'id': '4',
          'name': 'Cabai Merah',
          'quantity': '4',
          'unit': 'buah',
          'price': 'Rp2.500',
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.shutterstock.com%2Fsearch%2Fcabe-rawit-merah&psig=AOvVaw3klAOWxtv9sZdEMym1udBJ&ust=1746107596440000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCIDQke_z_4wDFQAAAAAdAAAAABAQ'
        },
        {
          'id': '5',
          'name': 'Telur Ayam',
          'quantity': '2',
          'unit': 'butir',
          'price': 'Rp3.000',
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fid.pngtree.com%2Ffree-backgrounds-photos%2Fputih-telur-ayam-foto&psig=AOvVaw28gEKC-2zJLEK7umuPxa8d&ust=1746107647673000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCLi8_of0_4wDFQAAAAAdAAAAABAE'
        },
        {
          'id': '6',
          'name': 'Kecap Manis',
          'quantity': '2',
          'unit': 'sdm',
          'price': 'Rp1.000',
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.masakapahariini.com%2Fproduk%2Fkecap-bango-manis%2F&psig=AOvVaw2erybyyGogyTfwHfL0QKMn&ust=1746107703115000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCIDJs5z0_4wDFQAAAAAdAAAAABAE'
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
      imageUrl: 'https://www.google.com/imgres?q=rendang%20HD&imgurl=https%3A%2F%2Fdoku.promo%2Fbl-content%2Fuploads%2Fpages%2Ffb0da6279f88f310e0d704ee19401837%2FResepRahasiaRendangEnakyangAutentikdariMinang.jpg&imgrefurl=https%3A%2F%2Fdoku.promo%2Fresep-rendang-enak&docid=hCRYtxiN5kcjWM&tbnid=p6_mSePHTVTudM&vet=12ahUKEwi54IKm9P-MAxVUzDgGHR4xJFwQM3oECFQQAA..i&w=5000&h=3419&hcb=2&ved=2ahUKEwi54IKm9P-MAxVUzDgGHR4xJFwQM3oECFQQAA',
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
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.kompas.com%2Ffood%2Fimage%2F2021%2F07%2F15%2F180800975%2F3-cara-pilih-daging-sapi-segar-tips-dari-koki&psig=AOvVaw3rpZjdQWeGnMaXXBcPmrag&ust=1746107854970000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCPD5-Ob0_4wDFQAAAAAdAAAAABAE'
        },
        {
          'id': '8',
          'name': 'Santan Kelapa',
          'quantity': '2',
          'unit': 'liter',
          'price': 'Rp25.000',
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.sasa.co.id%2Four-products%2Fview%2Fsantan-cair&psig=AOvVaw13dp4xEw_mY3Wz1GIFwDwU&ust=1746107898579000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCOiQz_v0_4wDFQAAAAAdAAAAABAE'
        },
        {
          'id': '9',
          'name': 'Bumbu Rendang',
          'quantity': '1',
          'unit': 'paket',
          'price': 'Rp15.000',
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.mirotakampus.com%2Fid%2FProducts%2F45%2F2040&psig=AOvVaw0cI6zG_djhUGLkWyY3Y_XZ&ust=1746107944366000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCOCqpJD1_4wDFQAAAAAdAAAAABAE'
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
      imageUrl: 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.freepik.com%2Fpremium-photo%2Fsoto-ayam-indonesian-delicious-traditional-chicken-soup-isolated-white-background_23325816.htm&psig=AOvVaw1vXnh2EyDPDuip0P7freCw&ust=1746108026824000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCKC16rb1_4wDFQAAAAAdAAAAABAJ',
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
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fid%2Ffoto-foto%2Fdaging-ayam&psig=AOvVaw3DpFDhULLgnqz1WSSJrWr3&ust=1746108079220000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCPDg6c_1_4wDFQAAAAAdAAAAABAE'
        },
        {
          'id': '11',
          'name': 'Kunyit',
          'quantity': '3',
          'unit': 'ruas',
          'price': 'Rp2.000',
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fid%2Ffoto%2Fkunyit-segar-dengan-daun-di-latar-belakang-putih-gambar-komersial-tanaman-obat-gm1226214001-361218275&psig=AOvVaw3YGCULqC89jYJHyhEv-CpR&ust=1746108102811000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCNioh9v1_4wDFQAAAAAdAAAAABAE'
        },
        {
          'id': '12',
          'name': 'Koya (Kerupuk Udang + Bawang)',
          'quantity': '100',
          'unit': 'gram',
          'price': 'Rp10.000',
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.hipwee.com%2Ftips%2Fcara-bikin-bubuk-koya%2F&psig=AOvVaw2Wu3ZADwxGMKHZaBICj3Ha&ust=1746108132363000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCOiGmu_1_4wDFQAAAAAdAAAAABAE'
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
      imageUrl: 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fmymilk.com%2Fmilkeveryday%2Frecipe%2Fresep-martabak-keju-makin-lembut-dan-gurih-dengan-susu&psig=AOvVaw2Q9wPrwH-2MYMVuJBWbKi7&ust=1746108169695000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCJCNsvz1_4wDFQAAAAAdAAAAABAQ',
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
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.mirotakampus.com%2Fid%2FProducts%2F44%2F1093&psig=AOvVaw0hurBT-T9ADsJexm-In-3E&ust=1746108205119000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCIDW-Zn2_4wDFQAAAAAdAAAAABAE'
        },
        {
          'id': '14',
          'name': 'Gula Pasir',
          'quantity': '150',
          'unit': 'gram',
          'price': 'Rp3.000',
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.monotaro.id%2Fp106952420.html&psig=AOvVaw3abz-eCnatYCSxcilN2jNB&ust=1746108258491000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCMDh3aj2_4wDFQAAAAAdAAAAABAJ'
        },
        {
          'id': '15',
          'name': 'Coklat Meses',
          'quantity': '100',
          'unit': 'gram',
          'price': 'Rp10.000',
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwarindo.de%2Fwarung%2Fcokelat-meses-ceres-classic-225g-verpackung-ist-etwas-beschaedigt%2F&psig=AOvVaw2i0WO1bdvJonQFMSFh6pO_&ust=1746108322160000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCKDBpMn2_4wDFQAAAAAdAAAAABAE'
        },
        {
          'id': '16',
          'name': 'Keju Cheddar',
          'quantity': '100',
          'unit': 'gram',
          'price': 'Rp15.000',
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fbundakraft.com%2Fproduk&psig=AOvVaw1qyouO2WLPpeTE2OqSNzWi&ust=1746108355584000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCLCe_NT2_4wDFQAAAAAdAAAAABAZ'
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
      imageUrl: 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fbundakraft.com%2Fproduk&psig=AOvVaw1qyouO2WLPpeTE2OqSNzWi&ust=1746108355584000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCLCe_NT2_4wDFQAAAAAdAAAAABAZ',
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
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fraisa.aeonstore.id%2Fshop%2Fseafood-meat%2Fpoultry%2Ffillet%2F&psig=AOvVaw1C2awyqM_Djd1JbWIV2lwY&ust=1746108431491000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCLCH7vf2_4wDFQAAAAAdAAAAABAE'
        },
        {
          'id': '18',
          'name': 'Kacang Tanah',
          'quantity': '200',
          'unit': 'gram',
          'price': 'Rp8.000',
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fid.lovepik.com%2Fimage-501580591%2Fpeanut.html&psig=AOvVaw3nFUlBj6Q7ujQ2i-H-t3um&ust=1746108454914000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCPCjgoP3_4wDFQAAAAAdAAAAABAR'
        },
        {
          'id': '19',
          'name': 'Kecap Manis',
          'quantity': '5',
          'unit': 'sdm',
          'price': 'Rp3.000',
          'image_url': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.masakapahariini.com%2Fproduk%2Fkecap-bango-manis%2F&psig=AOvVaw35bdM0KMWdJz4q36mzCuIe&ust=1746108485256000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCLD6zZH3_4wDFQAAAAAdAAAAABAE'
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