-- ========================================
-- Rasain App - Supabase Database Seeder (Safe Version)
-- Based on mock_data.dart - Uses ON CONFLICT DO NOTHING for safety
-- ========================================

-- Create temporary variables to store all UUIDs for referencing
DO $$
DECLARE
    -- User UUIDs (fixed for consistency)
    user_budi_id UUID := 'f4b57646-647f-4bd1-8cc0-3ebbe2b5b1f0';
    user_siti_id UUID := 'a8c92d41-2f5e-4a3b-9d8e-1c5f7b4e8a2d';
    user_agus_id UUID := 'b7d83e52-3a6f-5b4c-ae9f-2d6e8c5f9b3e';
    user_dewi_id UUID := 'c9e74f63-4b7a-6c5d-bf0a-3e7f9d6a0c4f';
    user_indra_id UUID := 'd0f85a74-5c8b-7d6e-c01b-4f8a0e7b1d5a';
    
    -- Recipe UUIDs (fixed for consistency)
    recipe_nasi_goreng_id UUID := 'e1a96b85-6d9c-8e7f-d12c-5a9b1f8c2e6b';
    recipe_rendang_id UUID := 'f2ba7c96-7ea0-9f8a-e23d-6bac2a9d3f7c';
    recipe_soto_ayam_id UUID := 'a3cb8da7-8fb1-0a9b-f34e-7cbd3ba4e08d';
    recipe_martabak_id UUID := 'b4dc9eb8-9ac2-1bac-a45f-8dce4cb5f19e';
    recipe_sate_ayam_id UUID := 'c5ed0fc9-abd3-2cbd-b56a-9edf5dc6a20f';
    recipe_gado_gado_id UUID := 'd6fe1ada-bce4-3dce-c67b-0fea6ed7b31a';
    recipe_bakso_id UUID := 'e7af2beb-cdf5-4edf-d78c-1afb7fe8c42b';
    recipe_gudeg_id UUID := 'f8ba3cfc-dea6-5fea-e89d-2bac8af9d53c';
    
    -- Pantry Item UUIDs (fixed for consistency)
    pantry_beras_id UUID := 'a9cb4dad-efb7-6afb-f90e-3cbd9ba0e64d';
    pantry_telur_id UUID := 'bade5ebe-fac8-7bac-a01f-4dce0cb1f75e';
    pantry_kecap_id UUID := 'cbef6fcf-abd9-8cbd-b12a-5edf1dc2a86f';
    pantry_minyak_id UUID := 'dcfa7ada-bcea-9dce-c23b-6fea2ed3b97a';
    pantry_cabai_id UUID := 'edab8beb-cdfb-0edf-d34c-7afb3fe4ca8b';
    pantry_tempe_id UUID := 'febc9cfc-dea0-1fea-e45d-8bac4af5db9c';
    pantry_santan_id UUID := 'afcd0dad-efb1-2afb-f56e-9cbd5ba6ec0d';
    pantry_terasi_id UUID := 'bade1ebe-fac2-3bac-a67f-0dce6cb7fd1e';
    pantry_nangka_id UUID := 'cbef2fcf-abd3-4cbd-b78a-1edf7dc8ae2f';
    pantry_gula_merah_id UUID := 'dcfa3ada-bce4-5dce-c89b-2fea8ed9bf3a';
    
    -- Community Post UUIDs (fixed for consistency)
    post_rendang_id UUID := 'edab4beb-cdf5-6edf-d90c-3afb9fe0ca4b';
    post_sambal_id UUID := 'febc5cfc-dea6-7fea-ea1d-4bac0af1db5c';
    post_cendol_id UUID := 'afcd6dad-efb7-8afb-fb2e-5cbd1ba2ec6d';
    post_tumpeng_id UUID := 'bade7ebe-fac8-9bac-ac3f-6dce2cb3fd7e';
    post_gudeg_id UUID := 'cbef8fcf-abd9-0cbd-bd4a-7edf3dc4ae8f';
    
    -- Notification UUIDs (fixed for consistency)
    notif_expiry_cabai_id UUID := 'dcfa9ada-bce0-1dce-ce5b-8fea4ed5bf9a';
    notif_expiry_tempe_id UUID := 'edab0beb-cdf1-2edf-df6c-9afb5fe6ca0b';
    notif_recipe_rec_id UUID := 'febc1cfc-dea2-3fea-ea7d-0bac6af7db1c';
    notif_new_recipe_id UUID := 'afcd2dad-efb3-4afb-fb8e-1cbd7ba8ec2d';
    notif_review_id UUID := 'bade3ebe-fac4-5bac-ac9f-2dce8cb9fd3e';
    notif_expiry_nangka_id UUID := 'cbef4fcf-abd5-6cbd-bd0a-3edf9dc0ae4f';
      -- Chat Message UUIDs (fixed for consistency)
    chat_1_id UUID := 'dcfa5ada-bce6-7dce-ce1b-4fea0ed1bf5a';
    chat_2_id UUID := 'edab6beb-cdf7-8edf-df2c-5afb1fe2ca6b';
    chat_3_id UUID := 'febc7cfc-dea8-9fea-ea3d-6bac2af3db7c';
    chat_4_id UUID := 'afcd8dad-efb9-0afb-fb4e-7cbd3ba4ec8d';
    chat_5_id UUID := 'bade9ebe-fac0-1bac-ac5f-8dce4cb5fd9e';
    chat_6_id UUID := 'cbef0fcf-abd1-2cbd-bd6a-9edf5dc6ae0f';
    
    -- Tool UUIDs (fixed for consistency)
    tool_wajan_id UUID := 'a1b2c3d4-5e6f-7a8b-9c0d-1e2f3a4b5c6d';
    tool_panci_id UUID := 'b2c3d4e5-6f7a-8b9c-0d1e-2f3a4b5c6d7e';
    tool_pisau_id UUID := 'c3d4e5f6-7a8b-9c0d-1e2f-3a4b5c6d7e8f';
    tool_talenan_id UUID := 'd4e5f6a7-8b9c-0d1e-2f3a-4b5c6d7e8f9a';
    tool_spatula_id UUID := 'e5f6a7b8-9c0d-1e2f-3a4b-5c6d7e8f9a0b';
    tool_blender_id UUID := 'f6a7b8c9-0d1e-2f3a-4b5c-6d7e8f9a0b1c';
    tool_rice_cooker_id UUID := 'a7b8c9d0-1e2f-3a4b-5c6d-7e8f9a0b1c2d';
    tool_kompor_id UUID := 'b8c9d0e1-2f3a-4b5c-6d7e-8f9a0b1c2d3e';
    tool_cobek_id UUID := 'c9d0e1f2-3a4b-5c6d-7e8f-9a0b1c2d3e4f';
    tool_kukusan_id UUID := 'd0e1f2a3-4b5c-6d7e-8f9a-0b1c2d3e4f5a';
BEGIN

-- Check if data already exists, if so, exit early
IF EXISTS (SELECT 1 FROM user_profiles WHERE email = 'budi.santoso@email.com') THEN
    RAISE NOTICE 'Seeder data already exists. Skipping insertion to avoid duplicates.';
    RETURN;
END IF;

-- Insert users into auth.users (Supabase Auth table)
-- Note: In production, users would be created through Supabase Auth signup
-- This is for development/testing purposes only
INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    invited_at,
    confirmation_token,
    confirmation_sent_at,
    recovery_token,
    recovery_sent_at,
    email_change_token_new,
    email_change,
    email_change_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    created_at,
    updated_at,
    phone,
    phone_confirmed_at,
    phone_change,
    phone_change_token,
    phone_change_sent_at,
    email_change_token_current,
    email_change_confirm_status,
    banned_until,
    reauthentication_token,
    reauthentication_sent_at
) VALUES 
(
    user_budi_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'budi.santoso@email.com',
    crypt('password123', gen_salt('bf')),
    NOW(),
    NULL,
    '',
    NULL,
    '',
    NULL,
    '',
    '',
    NULL,
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "Budi Santoso"}',
    FALSE,
    NOW(),
    NOW(),
    NULL,
    NULL,
    '',
    '',
    NULL,
    '',
    0,
    NULL,
    '',
    NULL
),
(
    user_siti_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'siti.rahayu@email.com',
    crypt('password123', gen_salt('bf')),
    NOW(),
    NULL,
    '',
    NULL,
    '',
    NULL,
    '',
    '',
    NULL,
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "Siti Rahayu"}',
    FALSE,
    NOW(),
    NOW(),
    NULL,
    NULL,
    '',
    '',
    NULL,
    '',
    0,
    NULL,
    '',
    NULL
),
(
    user_agus_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'agus.wijaya@email.com',
    crypt('password123', gen_salt('bf')),
    NOW(),
    NULL,
    '',
    NULL,
    '',
    NULL,
    '',
    '',
    NULL,
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "Agus Wijaya"}',
    FALSE,
    NOW(),
    NOW(),
    NULL,
    NULL,
    '',
    '',
    NULL,
    '',
    0,
    NULL,
    '',
    NULL
),
(
    user_dewi_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'dewi.lestari@email.com',
    crypt('password123', gen_salt('bf')),
    NOW(),
    NULL,
    '',
    NULL,
    '',
    NULL,
    '',
    '',
    NULL,
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "Dewi Lestari"}',
    FALSE,
    NOW(),
    NOW(),
    NULL,
    NULL,
    '',
    '',
    NULL,
    '',
    0,
    NULL,
    '',
    NULL
),
(
    user_indra_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'indra.pratama@email.com',
    crypt('password123', gen_salt('bf')),
    NOW(),
    NULL,
    '',
    NULL,
    '',
    NULL,
    '',
    '',
    NULL,
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "Indra Pratama"}',
    FALSE,
    NOW(),
    NOW(),
    NULL,
    NULL,
    '',
    '',
    NULL,
    '',
    0,
    NULL,
    '',
    NULL
)
ON CONFLICT (id) DO NOTHING;

-- Insert user profiles
INSERT INTO user_profiles (
    id,
    name,
    email,
    image_url,
    saved_recipes_count,
    posts_count,
    is_notifications_enabled,
    language,
    is_dark_mode_enabled
) VALUES 
(
    user_budi_id,
    'Budi Santoso',
    'budi.santoso@email.com',
    'public/assets/images/profile/1.png',
    12,
    5,
    TRUE,
    'id',
    FALSE
),
(
    user_siti_id,
    'Siti Rahayu',
    'siti.rahayu@email.com',
    'https://i.pravatar.cc/300?img=5',
    28,
    15,
    TRUE,
    'id',
    TRUE
),
(
    user_agus_id,
    'Agus Wijaya',
    'agus.wijaya@email.com',
    'https://i.pravatar.cc/300?img=3',
    7,
    3,
    FALSE,
    'id',
    FALSE
),
(
    user_dewi_id,
    'Dewi Lestari',
    'dewi.lestari@email.com',
    'https://i.pravatar.cc/300?img=9',
    42,
    21,
    TRUE,
    'id',
    TRUE
),
(
    user_indra_id,
    'Indra Pratama',
    'indra.pratama@email.com',
    'https://i.pravatar.cc/300?img=8',
    18,
    9,
    TRUE,
    'id',
    FALSE
)
ON CONFLICT (id) DO NOTHING;

-- Insert recipes
INSERT INTO recipes (
    id,
    name,
    slug,
    image_url,
    rating,
    review_count,
    estimated_cost,
    cook_time,
    servings,
    tingkat_kesulitan,
    description,
    created_by
) VALUES 
(
    recipe_nasi_goreng_id,
    'Nasi Goreng Kampung',
    'nasi-goreng-kampung',
    'public/assets/images/recipe/1.png',
    4.8,
    245,
    'Rp25.000',
    '25 menit',
    2,
    'mudah',
    'Nasi goreng khas Indonesia dengan cita rasa kampung yang otentik. Dimasak dengan bumbu tradisional dan tambahan telur mata sapi serta kerupuk.',
    user_budi_id
),
(
    recipe_rendang_id,
    'Rendang Daging Sapi',
    'rendang-daging-sapi',
    'public/assets/images/recipe/2.png',
    4.9,
    312,
    'Rp85.000',
    '4 jam',
    6,
    'sulit',
    'Rendang daging sapi khas Padang dengan rempah-rempah kaya dan santan kelapa yang dimasak hingga empuk dan bumbu meresap sempurna.',
    user_siti_id
),
(
    recipe_soto_ayam_id,
    'Soto Ayam Lamongan',
    'soto-ayam-lamongan',
    'public/assets/images/recipe/3.png',
    4.7,
    178,
    'Rp35.000',
    '60 menit',
    4,
    'sedang',
    'Soto ayam khas Lamongan dengan kuah kuning bening, potongan ayam suwir, dan pelengkap seperti koya, telur rebus, serta sambal.',
    user_agus_id
),
(
    recipe_martabak_id,
    'Martabak Manis Coklat Keju',
    'martabak-manis-coklat-keju',
    'public/assets/images/recipe/4.png',
    4.6,
    203,
    'Rp45.000',    '30 menit',
    8,
    'mudah',
    'Kue terang bulan atau martabak manis dengan topping coklat dan keju yang lumer di mulut. Tekstur lembut dan kenyal.',
    user_dewi_id
),
(
    recipe_sate_ayam_id,
    'Sate Ayam Madura',
    'sate-ayam-madura',
    'public/assets/images/recipe/5.png',
    4.7,
    156,
    'Rp40.000',
    '45 menit',
    4,
    'sedang',
    'Sate ayam khas Madura dengan bumbu kacang yang kental dan manis. Daging ayam yang empuk dipanggang hingga kecokelatan.',
    user_budi_id
),
(
    recipe_gado_gado_id,
    'Gado-gado Jakarta',
    'gado-gado-jakarta',
    'public/assets/images/recipe/6.png',
    4.5,
    189,
    'Rp20.000',
    '20 menit',
    2,
    'mudah',
    'Salad sayuran Indonesia dengan bumbu kacang yang gurih. Terdiri dari berbagai sayuran rebus dan mentah dengan lontong.',
    user_siti_id
),
(
    recipe_bakso_id,
    'Bakso Malang',
    'bakso-malang',
    'public/assets/images/recipe/7.png',
    4.6,
    234,
    'Rp30.000',
    '90 menit',
    3,
    'sedang',
    'Bakso khas Malang dengan berbagai jenis bakso dalam kuah kaldu sapi yang gurih. Dilengkapi mie, tahu, dan pangsit.',
    user_agus_id
),
(
    recipe_gudeg_id,
    'Gudeg Yogyakarta',
    'gudeg-yogyakarta',
    'public/assets/images/recipe/8.png',
    4.8,
    198,
    'Rp35.000',
    '3 jam',
    4,
    'sulit',
    'Gudeg khas Yogyakarta dengan nangka muda yang dimasak dengan santan dan gula merah. Manis gurih dengan cita rasa tradisional.',
    user_indra_id
)
ON CONFLICT (id) DO NOTHING;

-- Insert recipe categories
INSERT INTO recipe_categories (recipe_id, category) VALUES 
(recipe_nasi_goreng_id, 'Makanan Utama'),
(recipe_nasi_goreng_id, 'Nasi'),
(recipe_rendang_id, 'Makanan Utama'),
(recipe_rendang_id, 'Daging'),
(recipe_rendang_id, 'Tradisional'),
(recipe_soto_ayam_id, 'Makanan Utama'),
(recipe_soto_ayam_id, 'Sup'),
(recipe_soto_ayam_id, 'Ayam'),
(recipe_martabak_id, 'Makanan Penutup'),
(recipe_martabak_id, 'Kue'),
(recipe_sate_ayam_id, 'Makanan Utama'),
(recipe_sate_ayam_id, 'Ayam'),
(recipe_sate_ayam_id, 'Panggang'),
(recipe_gado_gado_id, 'Salad'),
(recipe_gado_gado_id, 'Sayuran'),
(recipe_bakso_id, 'Makanan Utama'),
(recipe_bakso_id, 'Sup'),
(recipe_bakso_id, 'Daging'),
(recipe_gudeg_id, 'Makanan Utama'),
(recipe_gudeg_id, 'Tradisional'),
(recipe_gudeg_id, 'Sayuran');

-- Insert recipe ingredients
INSERT INTO recipe_ingredients (recipe_id, ingredient_name, quantity, unit) VALUES 
(recipe_nasi_goreng_id, 'Nasi putih', '3', 'piring'),
(recipe_nasi_goreng_id, 'Telur ayam', '2', 'butir'),
(recipe_nasi_goreng_id, 'Kecap manis', '3', 'sdm'),
(recipe_nasi_goreng_id, 'Bawang merah', '5', 'siung'),
(recipe_nasi_goreng_id, 'Bawang putih', '3', 'siung'),
(recipe_nasi_goreng_id, 'Cabai merah', '3', 'buah'),
(recipe_nasi_goreng_id, 'Minyak goreng', '3', 'sdm'),
(recipe_nasi_goreng_id, 'Garam', '1', 'sdt'),
(recipe_rendang_id, 'Daging sapi', '1', 'kg'),
(recipe_rendang_id, 'Santan kelapa', '1', 'liter'),
(recipe_rendang_id, 'Cabai merah keriting', '15', 'buah'),
(recipe_rendang_id, 'Bawang merah', '8', 'siung'),
(recipe_rendang_id, 'Bawang putih', '6', 'siung'),
(recipe_rendang_id, 'Jahe', '3', 'cm'),
(recipe_rendang_id, 'Lengkuas', '3', 'cm'),
(recipe_rendang_id, 'Kunyit', '2', 'cm'),
(recipe_soto_ayam_id, 'Ayam kampung', '1', 'ekor'),
(recipe_soto_ayam_id, 'Kunyit', '2', 'cm'),
(recipe_soto_ayam_id, 'Jahe', '2', 'cm'),
(recipe_soto_ayam_id, 'Daun jeruk', '3', 'lembar'),
(recipe_soto_ayam_id, 'Serai', '2', 'batang'),
(recipe_soto_ayam_id, 'Bawang goreng', '2', 'sdm'),
(recipe_martabak_id, 'Tepung terigu', '250', 'gram'),
(recipe_martabak_id, 'Telur ayam', '2', 'butir'),
(recipe_martabak_id, 'Susu cair', '200', 'ml'),
(recipe_martabak_id, 'Coklat meses', '100', 'gram'),
(recipe_martabak_id, 'Keju parut', '100', 'gram'),
(recipe_sate_ayam_id, 'Daging ayam', '500', 'gram'),
(recipe_sate_ayam_id, 'Kacang tanah', '200', 'gram'),
(recipe_sate_ayam_id, 'Gula merah', '2', 'sdm'),
(recipe_sate_ayam_id, 'Kecap manis', '3', 'sdm'),
(recipe_gado_gado_id, 'Kacang tanah', '150', 'gram'),
(recipe_gado_gado_id, 'Tauge', '100', 'gram'),
(recipe_gado_gado_id, 'Bayam', '100', 'gram'),
(recipe_gado_gado_id, 'Kentang', '2', 'buah'),
(recipe_gado_gado_id, 'Tahu', '4', 'potong'),
(recipe_bakso_id, 'Daging sapi giling', '500', 'gram'),
(recipe_bakso_id, 'Tepung tapioka', '100', 'gram'),
(recipe_bakso_id, 'Tulang sapi', '500', 'gram'),
(recipe_bakso_id, 'Mie', '200', 'gram'),
(recipe_gudeg_id, 'Nangka muda', '1', 'kg'),
(recipe_gudeg_id, 'Santan kelapa', '500', 'ml'),
(recipe_gudeg_id, 'Gula merah', '200', 'gram'),
(recipe_gudeg_id, 'Daun salam', '5', 'lembar'),
(recipe_gudeg_id, 'Lengkuas', '2', 'cm');

-- Insert recipe instructions
INSERT INTO recipe_instructions (recipe_id, step_number, instruction_text) VALUES 
(recipe_nasi_goreng_id, 1, 'Haluskan bawang merah, bawang putih, dan cabai merah.'),
(recipe_nasi_goreng_id, 2, 'Panaskan minyak, tumis bumbu halus hingga harum.'),
(recipe_nasi_goreng_id, 3, 'Masukkan telur, orak-arik hingga matang.'),
(recipe_nasi_goreng_id, 4, 'Tambahkan nasi putih, aduk rata.'),
(recipe_nasi_goreng_id, 5, 'Tuang kecap manis dan garam, aduk hingga merata.'),
(recipe_nasi_goreng_id, 6, 'Sajikan dengan kerupuk dan acar.'),
(recipe_rendang_id, 1, 'Potong daging sapi menjadi kotak-kotak.'),
(recipe_rendang_id, 2, 'Haluskan semua bumbu: cabai, bawang merah, bawang putih, jahe, lengkuas, kunyit.'),
(recipe_rendang_id, 3, 'Tumis bumbu halus hingga harum dan berminyak.'),
(recipe_rendang_id, 4, 'Masukkan daging, aduk hingga berubah warna.'),
(recipe_rendang_id, 5, 'Tuang santan, masak dengan api sedang.'),
(recipe_rendang_id, 6, 'Kecilkan api, masak sambil diaduk hingga bumbu meresap (3-4 jam).'),
(recipe_rendang_id, 7, 'Rendang siap disajikan ketika berwarna cokelat kehitaman.'),
(recipe_soto_ayam_id, 1, 'Rebus ayam dengan jahe dan kunyit hingga empuk.'),
(recipe_soto_ayam_id, 2, 'Angkat ayam, suwir-suwir dagingnya.'),
(recipe_soto_ayam_id, 3, 'Saring kaldu ayam.'),
(recipe_soto_ayam_id, 4, 'Tumis bumbu halus, masukkan ke dalam kaldu.'),
(recipe_soto_ayam_id, 5, 'Didihkan kaldu dengan daun jeruk dan serai.'),
(recipe_soto_ayam_id, 6, 'Sajikan dengan ayam suwir, bawang goreng, dan pelengkap.'),
(recipe_martabak_id, 1, 'Campurkan tepung terigu, telur, dan susu cair.'),
(recipe_martabak_id, 2, 'Aduk hingga adonan licin, diamkan 30 menit.'),
(recipe_martabak_id, 3, 'Panaskan wajan anti lengket dengan sedikit mentega.'),
(recipe_martabak_id, 4, 'Tuang adonan, ratakan membentuk bulat.'),
(recipe_martabak_id, 5, 'Taburi dengan coklat meses dan keju parut.'),
(recipe_martabak_id, 6, 'Lipat menjadi setengah lingkaran, angkat dan sajikan.'),
(recipe_sate_ayam_id, 1, 'Potong daging ayam kotak-kotak, tusuk dengan tusukan sate.'),
(recipe_sate_ayam_id, 2, 'Bakar sate sambil dibolak-balik hingga matang.'),
(recipe_sate_ayam_id, 3, 'Sangrai kacang tanah, haluskan.'),
(recipe_sate_ayam_id, 4, 'Campurkan kacang halus dengan gula merah, kecap manis, dan air.'),
(recipe_sate_ayam_id, 5, 'Masak bumbu kacang hingga kental.'),
(recipe_sate_ayam_id, 6, 'Sajikan sate dengan bumbu kacang dan lontong.'),
(recipe_gado_gado_id, 1, 'Rebus sayuran (bayam, tauge, kentang) secara terpisah.'),
(recipe_gado_gado_id, 2, 'Goreng tahu hingga kecokelatan.'),
(recipe_gado_gado_id, 3, 'Sangrai kacang tanah, haluskan.'),
(recipe_gado_gado_id, 4, 'Campurkan kacang halus dengan gula merah dan air.'),
(recipe_gado_gado_id, 5, 'Masak bumbu kacang hingga kental.'),
(recipe_gado_gado_id, 6, 'Tata sayuran dan tahu, siram dengan bumbu kacang.'),
(recipe_bakso_id, 1, 'Rebus tulang sapi untuk membuat kaldu, masak 2 jam.'),
(recipe_bakso_id, 2, 'Campurkan daging giling dengan tepung tapioka.'),
(recipe_bakso_id, 3, 'Bentuk adonan daging menjadi bulatan-bulatan.'),
(recipe_bakso_id, 4, 'Rebus bakso dalam air mendidih hingga mengapung.'),
(recipe_bakso_id, 5, 'Rebus mie dan tahu secara terpisah.'),
(recipe_bakso_id, 6, 'Sajikan bakso dengan mie, tahu, dan kaldu panas.'),
(recipe_gudeg_id, 1, 'Bersihkan nangka muda, potong sesuai selera.'),
(recipe_gudeg_id, 2, 'Rebus nangka muda hingga empuk.'),
(recipe_gudeg_id, 3, 'Haluskan bawang merah, bawang putih, kemiri.'),
(recipe_gudeg_id, 4, 'Tumis bumbu halus dengan lengkuas dan daun salam.'),
(recipe_gudeg_id, 5, 'Masukkan nangka rebus, santan, dan gula merah.'),
(recipe_gudeg_id, 6, 'Masak dengan api kecil hingga kuah menyusut dan bumbu meresap (2-3 jam).'),
(recipe_gudeg_id, 7, 'Sajikan dengan ayam, telur, dan sambal krecek.')
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Insert tools (insert specific tools we'll use in recipes)
INSERT INTO tools (
    id,
    name,
    description,
    category
) VALUES 
(
    tool_wajan_id,
    'Wajan',
    'Wajan untuk menumis dan menggoreng',
    'peralatan_masak'
),
(
    tool_panci_id,
    'Panci',
    'Panci untuk merebus dan membuat sup',
    'peralatan_masak'
),
(
    tool_pisau_id,
    'Pisau Dapur',
    'Pisau untuk memotong bahan makanan',
    'peralatan_potong'
),
(
    tool_talenan_id,
    'Talenan',
    'Alas untuk memotong bahan',
    'peralatan_potong'
),
(
    tool_spatula_id,
    'Spatula',
    'Spatula untuk membalik makanan',
    'peralatan_masak'
),
(
    tool_blender_id,
    'Blender',
    'Untuk menghaluskan bumbu dan membuat jus',
    'peralatan_elektronik'
),
(
    tool_rice_cooker_id,
    'Rice Cooker',
    'Untuk memasak nasi',
    'peralatan_elektronik'
),
(
    tool_kompor_id,
    'Kompor Gas',
    'Untuk memasak dengan api',
    'peralatan_masak'
),
(
    tool_cobek_id,
    'Cobek',
    'Untuk mengulek bumbu tradisional',
    'peralatan_tradisional'
),
(
    tool_kukusan_id,
    'Kukusan',
    'Untuk mengukus kue dan makanan',
    'peralatan_masak'
)
ON CONFLICT (id) DO NOTHING;

-- Insert recipe-tools relationships
INSERT INTO recipe_tools (recipe_id, tool_id, is_required, notes) VALUES 
-- Nasi Goreng Kampung
(recipe_nasi_goreng_id, tool_wajan_id, TRUE, 'Untuk menumis nasi'),
(recipe_nasi_goreng_id, tool_spatula_id, TRUE, 'Untuk mengaduk nasi'),
(recipe_nasi_goreng_id, tool_pisau_id, TRUE, 'Untuk memotong bumbu'),
(recipe_nasi_goreng_id, tool_talenan_id, TRUE, 'Untuk alas memotong'),
(recipe_nasi_goreng_id, tool_kompor_id, TRUE, 'Untuk memasak'),

-- Rendang Daging Sapi
(recipe_rendang_id, tool_panci_id, TRUE, 'Untuk memasak rendang'),
(recipe_rendang_id, tool_blender_id, TRUE, 'Untuk menghaluskan bumbu'),
(recipe_rendang_id, tool_pisau_id, TRUE, 'Untuk memotong daging'),
(recipe_rendang_id, tool_talenan_id, TRUE, 'Untuk alas memotong'),
(recipe_rendang_id, tool_kompor_id, TRUE, 'Untuk memasak'),

-- Soto Ayam Lamongan
(recipe_soto_ayam_id, tool_panci_id, TRUE, 'Untuk membuat kuah soto'),
(recipe_soto_ayam_id, tool_pisau_id, TRUE, 'Untuk memotong ayam'),
(recipe_soto_ayam_id, tool_talenan_id, TRUE, 'Untuk alas memotong'),
(recipe_soto_ayam_id, tool_kompor_id, TRUE, 'Untuk memasak'),

-- Martabak Manis
(recipe_martabak_id, tool_wajan_id, TRUE, 'Untuk memasak martabak'),
(recipe_martabak_id, tool_spatula_id, TRUE, 'Untuk membalik martabak'),
(recipe_martabak_id, tool_kompor_id, TRUE, 'Untuk memasak'),

-- Sate Ayam Madura
(recipe_sate_ayam_id, tool_pisau_id, TRUE, 'Untuk memotong ayam'),
(recipe_sate_ayam_id, tool_talenan_id, TRUE, 'Untuk alas memotong'),
(recipe_sate_ayam_id, tool_kompor_id, TRUE, 'Untuk membakar sate'),

-- Gado-gado Jakarta
(recipe_gado_gado_id, tool_pisau_id, TRUE, 'Untuk memotong sayuran'),
(recipe_gado_gado_id, tool_talenan_id, TRUE, 'Untuk alas memotong'),
(recipe_gado_gado_id, tool_cobek_id, FALSE, 'Untuk menghaluskan bumbu kacang'),

-- Bakso Malang
(recipe_bakso_id, tool_panci_id, TRUE, 'Untuk membuat kuah bakso'),
(recipe_bakso_id, tool_blender_id, FALSE, 'Untuk menghaluskan daging'),
(recipe_bakso_id, tool_kompor_id, TRUE, 'Untuk memasak'),

-- Gudeg Yogyakarta
(recipe_gudeg_id, tool_panci_id, TRUE, 'Untuk memasak gudeg'),
(recipe_gudeg_id, tool_pisau_id, TRUE, 'Untuk memotong nangka'),
(recipe_gudeg_id, tool_talenan_id, TRUE, 'Untuk alas memotong'),
(recipe_gudeg_id, tool_kompor_id, TRUE, 'Untuk memasak'),
(recipe_gudeg_id, tool_cobek_id, TRUE, 'Untuk menghaluskan bumbu tradisional')
ON CONFLICT (recipe_id, tool_id) DO NOTHING;

-- Insert pantry items
INSERT INTO pantry_items (
    id,
    user_id,
    name,
    image_url,
    quantity,
    unit,
    price,
    category,
    expiration_date
) VALUES 
(
    pantry_beras_id,
    user_budi_id,
    'Beras',
    'public/assets/images/pantry/1.png',
    '5',
    'kg',
    'Rp70.000',
    'Bahan Pokok',
    CURRENT_DATE + INTERVAL '120 days'
),
(
    pantry_telur_id,
    user_budi_id,
    'Telur Ayam',
    'public/assets/images/pantry/2.png',
    '1',
    'kg',
    'Rp30.000',
    'Protein',
    CURRENT_DATE + INTERVAL '14 days'
),
(
    pantry_kecap_id,
    user_siti_id,
    'Kecap Manis Cap Bango',
    'public/assets/images/pantry/3.png',
    '1',
    'botol',
    'Rp15.000',
    'Bumbu',
    CURRENT_DATE + INTERVAL '360 days'
),
(
    pantry_minyak_id,
    user_siti_id,
    'Minyak Goreng',
    'public/assets/images/pantry/4.png',
    '2',
    'liter',
    'Rp45.000',
    'Minyak',
    CURRENT_DATE + INTERVAL '180 days'
),
(
    pantry_cabai_id,
    user_agus_id,
    'Cabai Merah',
    'public/assets/images/pantry/5.png',
    '250',
    'gram',
    'Rp15.000',
    'Sayuran',
    CURRENT_DATE + INTERVAL '7 days'
),
(
    pantry_tempe_id,
    user_agus_id,
    'Tempe',
    'public/assets/images/pantry/6.png',
    '2',
    'papan',
    'Rp8.000',
    'Protein',
    CURRENT_DATE + INTERVAL '5 days'
),
(
    pantry_santan_id,
    user_dewi_id,
    'Santan Kara',
    'public/assets/images/pantry/7.png',
    '3',
    'bungkus',
    'Rp18.000',
    'Bumbu',
    CURRENT_DATE + INTERVAL '120 days'
),
(
    pantry_terasi_id,
    user_dewi_id,
    'Terasi Udang',
    'public/assets/images/pantry/8.png',
    '50',
    'gram',
    'Rp5.000',
    'Bumbu',
    CURRENT_DATE + INTERVAL '90 days'
),
(
    pantry_nangka_id,
    user_indra_id,
    'Nangka Muda',
    'public/assets/images/pantry/9.png',
    '500',
    'gram',
    'Rp12.000',
    'Sayuran',
    CURRENT_DATE + INTERVAL '3 days'
),
(
    pantry_gula_merah_id,
    user_indra_id,
    'Gula Merah',
    'public/assets/images/pantry/10.png',
    '300',
    'gram',
    'Rp10.000',
    'Bumbu',
    CURRENT_DATE + INTERVAL '180 days'
)
ON CONFLICT (id) DO NOTHING;

-- Insert community posts
INSERT INTO community_posts (
    id,
    user_id,
    user_name,
    user_image_url,
    timestamp,
    content,
    image_url,
    category,
    like_count,
    comment_count
) VALUES 
(
    post_rendang_id,
    user_siti_id,
    'Siti Rahayu',
    'https://i.pravatar.cc/300?img=5',
    NOW() - INTERVAL '2 hours',
    'Hari ini saya coba resep rendang daging sapi pertama kali dan hasilnya enak banget! Bumbu meresap sampai ke dalam dan dagingnya empuk. Siapa yang mau resepnya?',
    'public/assets/images/community/5.png',
    'Makanan Utama',
    45,
    12
),
(
    post_sambal_id,
    user_dewi_id,
    'Dewi Lestari',
    'https://i.pravatar.cc/300?img=9',
    NOW() - INTERVAL '1 day',
    'Tips untuk membuat sambal yang tidak pahit: jangan sampai biji cabai ikut dihaluskan, dan tumis sampai matang dengan api sedang. Ini sambal bawang buatan saya, pedas nikmat!',
    'public/assets/images/community/1.png',
    'Tips Memasak',
    78,
    23
),
(
    post_cendol_id,
    user_budi_id,
    'Budi Santoso',
    'https://i.pravatar.cc/300?img=1',
    NOW() - INTERVAL '3 days',
    'Ada yang pernah coba membuat es cendol sendiri di rumah? Saya baru coba resep dari nenek dan hasilnya mirip yang dijual di jalan. Segarnya pas untuk cuaca panas Jakarta!',
    'public/assets/images/community/2.png',
    'Minuman',
    34,
    8
),
(
    post_tumpeng_id,
    user_agus_id,
    'Agus Wijaya',
    'https://i.pravatar.cc/300?img=3',
    NOW() - INTERVAL '5 days',
    'Berbagi kebahagiaan bersama keluarga dengan masak nasi tumpeng mini untuk ulang tahun istri. Tumpeng kuning dengan lauk pauk tradisional lengkap.',
    'public/assets/images/community/3.png',
    'Tradisional',
    56,
    14
),
(
    post_gudeg_id,
    user_indra_id,
    'Indra Pratama',
    'https://i.pravatar.cc/300?img=8',
    NOW() - INTERVAL '6 hours',
    'Akhirnya berhasil bikin gudeg Yogya yang otentik! Proses masak 3 jam memang butuh kesabaran, tapi hasilnya sangat memuaskan. Manis gurih nya pas banget!',
    'public/assets/images/community/4.png',
    'Tradisional',
    29,
    7
)
ON CONFLICT (id) DO NOTHING;

-- Insert post tagged ingredients
INSERT INTO post_tagged_ingredients (post_id, ingredient_name) VALUES 
(post_rendang_id, 'Daging Sapi'),
(post_rendang_id, 'Santan'),
(post_rendang_id, 'Bumbu Rendang'),
(post_sambal_id, 'Cabai Rawit'),
(post_sambal_id, 'Bawang Merah'),
(post_sambal_id, 'Bawang Putih'),
(post_cendol_id, 'Tepung Hunkwe'),
(post_cendol_id, 'Daun Pandan'),
(post_cendol_id, 'Gula Merah'),
(post_cendol_id, 'Santan'),
(post_tumpeng_id, 'Beras'),
(post_tumpeng_id, 'Kunyit'),
(post_tumpeng_id, 'Ayam'),
(post_tumpeng_id, 'Telur'),
(post_gudeg_id, 'Nangka Muda'),
(post_gudeg_id, 'Santan Kelapa'),
(post_gudeg_id, 'Gula Merah'),
(post_gudeg_id, 'Daun Salam');

-- Insert some post likes (simulating user interactions)
INSERT INTO post_likes (post_id, user_id) VALUES 
(post_rendang_id, user_budi_id),
(post_rendang_id, user_agus_id),
(post_rendang_id, user_dewi_id),
(post_sambal_id, user_siti_id),
(post_sambal_id, user_agus_id),
(post_cendol_id, user_siti_id),
(post_cendol_id, user_dewi_id),
(post_tumpeng_id, user_budi_id),
(post_tumpeng_id, user_siti_id),
(post_gudeg_id, user_budi_id),
(post_gudeg_id, user_siti_id),
(post_gudeg_id, user_agus_id)
ON CONFLICT (post_id, user_id) DO NOTHING;

-- Insert user saved recipes
INSERT INTO user_saved_recipes (user_id, recipe_id) VALUES 
(user_budi_id, recipe_nasi_goreng_id),
(user_budi_id, recipe_soto_ayam_id),
(user_budi_id, recipe_sate_ayam_id),
(user_siti_id, recipe_rendang_id),
(user_siti_id, recipe_martabak_id),
(user_agus_id, recipe_bakso_id),
(user_dewi_id, recipe_gado_gado_id),
(user_indra_id, recipe_gudeg_id),
(user_indra_id, recipe_rendang_id)
ON CONFLICT (user_id, recipe_id) DO NOTHING;

-- Insert recipe reviews
INSERT INTO recipe_reviews (recipe_id, user_id, rating, review_text) VALUES 
(recipe_nasi_goreng_id, user_siti_id, 5.0, 'Resep yang sangat mudah diikuti! Nasi gorengnya enak dan bumbu meresap sempurna.'),
(recipe_nasi_goreng_id, user_agus_id, 4.5, 'Keluarga suka banget sama rasanya, cuma porsi cabenya agak kurang buat saya hehe.'),
(recipe_rendang_id, user_budi_id, 5.0, 'Rendang terenak yang pernah saya masak! Prosesnya memang lama tapi hasilnya sebanding.'),
(recipe_rendang_id, user_dewi_id, 4.8, 'Bumbu rendangnya otentik banget, sama seperti buatan mertua saya di Padang.'),
(recipe_soto_ayam_id, user_budi_id, 4.7, 'Kuahnya segar dan ayamnya empuk. Koyanya bikin nagih!'),
(recipe_martabak_id, user_agus_id, 4.6, 'Anak-anak suka banget! Teksturnya lembut dan toppingnya melimpah.'),
(recipe_gudeg_id, user_siti_id, 4.8, 'Authentic Yogya gudeg! Manis gurihnya pas, persis seperti di Malioboro.')
ON CONFLICT (recipe_id, user_id) DO NOTHING;

-- Insert notifications
INSERT INTO notifications (
    id,
    user_id,
    title,
    message,
    timestamp,
    notification_type,
    related_item_id,
    is_read
) VALUES 
(
    notif_expiry_cabai_id,
    user_agus_id,
    'Cabai Merah Akan Kadaluarsa',
    'Cabai merah di pantry Anda akan kadaluarsa dalam 3 hari. Gunakan segera atau simpan di freezer.',
    NOW() - INTERVAL '1 hour',
    'expirationWarning',
    pantry_cabai_id,
    FALSE
),
(
    notif_expiry_tempe_id,
    user_agus_id,
    'Tempe Akan Kadaluarsa',
    'Tempe di pantry Anda akan kadaluarsa besok. Segera gunakan untuk masakan hari ini.',
    NOW() - INTERVAL '30 minutes',
    'expirationWarning',
    pantry_tempe_id,
    FALSE
),
(
    notif_recipe_rec_id,
    user_budi_id,
    'Rekomendasi Resep Baru',
    'Coba resep Gado-gado Jakarta yang sesuai dengan bahan di pantry Anda!',
    NOW() - INTERVAL '2 hours',
    'recipeRecommendation',
    recipe_gado_gado_id,
    TRUE
),
(
    notif_new_recipe_id,
    user_dewi_id,
    'Resep Baru Ditambahkan',
    'Resep Bakso Malang yang baru saja ditambahkan oleh Agus Wijaya!',
    NOW() - INTERVAL '1 day',
    'newRecipe',
    recipe_bakso_id,
    FALSE
),
(
    notif_review_id,
    user_siti_id,
    'Review Baru pada Resep Anda',
    'Budi Santoso memberikan review 5 bintang untuk resep Rendang Daging Sapi Anda!',
    NOW() - INTERVAL '3 hours',
    'review',
    recipe_rendang_id,
    FALSE
),
(
    notif_expiry_nangka_id,
    user_indra_id,
    'Nangka Muda Akan Kadaluarsa',
    'Nangka muda di pantry Anda akan kadaluarsa dalam 2 hari. Sempurna untuk membuat gudeg!',
    NOW() - INTERVAL '4 hours',
    'expirationWarning',
    pantry_nangka_id,
    FALSE
)
ON CONFLICT (id) DO NOTHING;

-- Insert chat messages (AI cooking assistant)
INSERT INTO chat_messages (
    id,
    user_id,
    content,
    message_type,
    sender,
    timestamp
) VALUES 
(
    chat_1_id,
    user_budi_id,
    'Halo! Saya ingin membuat nasi goreng kampung. Apa saja bahan yang dibutuhkan?',
    'text',
    'user',
    NOW() - INTERVAL '10 minutes'
),
(
    chat_2_id,
    user_budi_id,
    'Untuk nasi goreng kampung, Anda memerlukan: nasi putih 3 piring, telur ayam 2 butir, kecap manis 3 sdm, bawang merah 5 siung, bawang putih 3 siung, cabai merah 3 buah, minyak goreng 3 sdm, dan garam 1 sdt. Dari pantry Anda, saya lihat ada beras dan telur. Mau saya bantu dengan langkah-langkahnya?',
    'text',
    'ai',
    NOW() - INTERVAL '9 minutes'
),
(
    chat_3_id,
    user_siti_id,
    'Bagaimana cara membuat rendang yang empuk?',
    'text',
    'user',
    NOW() - INTERVAL '1 hour'
),
(
    chat_4_id,
    user_siti_id,
    'Kunci rendang yang empuk adalah masak dengan api kecil dalam waktu lama (3-4 jam) dan gunakan daging bagian has dalam atau gandik. Pastikan santan tidak pecah dengan cara mengaduk perlahan dan tidak menutup panci sepenuhnya. Apakah Anda butuh tips tambahan?',
    'text',
    'ai',
    NOW() - INTERVAL '59 minutes'
),
(
    chat_5_id,
    user_indra_id,
    'Saya punya nangka muda di rumah, bisa dimasak apa ya?',
    'text',
    'user',
    NOW() - INTERVAL '30 minutes'
),
(
    chat_6_id,
    user_indra_id,
    'Nangka muda sangat cocok untuk membuat gudeg! Anda juga bisa membuatnya menjadi sayur lodeh, tumis nangka, atau bahkan keripik nangka. Dari pantry Anda, saya lihat ada gula merah yang sempurna untuk gudeg. Mau saya berikan resep gudeg Yogyakarta?',
    'text',
    'ai',
    NOW() - INTERVAL '29 minutes'
)
ON CONFLICT (id) DO NOTHING;

-- Update user saved recipes count
UPDATE user_profiles 
SET saved_recipes_count = (
    SELECT COUNT(*) 
    FROM user_saved_recipes 
    WHERE user_id = user_profiles.id
);

-- Update recipe review counts and ratings
UPDATE recipes 
SET 
    review_count = (SELECT COUNT(*) FROM recipe_reviews WHERE recipe_id = recipes.id),
    rating = COALESCE((SELECT AVG(rating) FROM recipe_reviews WHERE recipe_id = recipes.id), 0);

-- Update post like counts
UPDATE community_posts 
SET like_count = (
    SELECT COUNT(*) 
    FROM post_likes 
    WHERE post_id = community_posts.id
);

END $$;

-- Success message
SELECT 'Safe seeder completed successfully! Database has been populated with Indonesian recipe data for 5 users using fixed UUIDs.' as result;
