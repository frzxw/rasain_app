-- ========================================
-- Rasain App - Supabase Database Seeder
-- Based on mock_data.dart
-- ========================================

-- Clean up existing data before seeding (CAUTION: This will delete all data!)
-- Uncomment the lines below if you want to reset the database completely
/*
TRUNCATE TABLE chat_messages CASCADE;
TRUNCATE TABLE notifications CASCADE;
TRUNCATE TABLE recipe_reviews CASCADE;
TRUNCATE TABLE user_saved_recipes CASCADE;
TRUNCATE TABLE post_likes CASCADE;
TRUNCATE TABLE post_tagged_ingredients CASCADE;
TRUNCATE TABLE community_posts CASCADE;
TRUNCATE TABLE pantry_items CASCADE;
TRUNCATE TABLE recipe_instructions CASCADE;
TRUNCATE TABLE recipe_ingredients CASCADE;
TRUNCATE TABLE recipe_categories CASCADE;
TRUNCATE TABLE recipes CASCADE;
TRUNCATE TABLE user_profiles CASCADE;
DELETE FROM auth.users WHERE email LIKE '%@email.com';
*/

-- Create temporary variables to store all UUIDs for referencing
DO $$
DECLARE
    -- User UUIDs
    user_budi_id UUID := gen_random_uuid();
    user_siti_id UUID := gen_random_uuid();
    user_agus_id UUID := gen_random_uuid();
    user_dewi_id UUID := gen_random_uuid();
    user_indra_id UUID := gen_random_uuid();
    
    -- Recipe UUIDs
    recipe_nasi_goreng_id UUID := gen_random_uuid();
    recipe_rendang_id UUID := gen_random_uuid();
    recipe_soto_ayam_id UUID := gen_random_uuid();
    recipe_martabak_id UUID := gen_random_uuid();
    recipe_sate_ayam_id UUID := gen_random_uuid();
    recipe_gado_gado_id UUID := gen_random_uuid();
    recipe_bakso_id UUID := gen_random_uuid();
    recipe_gudeg_id UUID := gen_random_uuid();
    
    -- Pantry Item UUIDs
    pantry_beras_id UUID := gen_random_uuid();
    pantry_telur_id UUID := gen_random_uuid();
    pantry_kecap_id UUID := gen_random_uuid();
    pantry_minyak_id UUID := gen_random_uuid();
    pantry_cabai_id UUID := gen_random_uuid();
    pantry_tempe_id UUID := gen_random_uuid();
    pantry_santan_id UUID := gen_random_uuid();
    pantry_terasi_id UUID := gen_random_uuid();
    pantry_nangka_id UUID := gen_random_uuid();
    pantry_gula_merah_id UUID := gen_random_uuid();
    
    -- Community Post UUIDs
    post_rendang_id UUID := gen_random_uuid();
    post_sambal_id UUID := gen_random_uuid();
    post_cendol_id UUID := gen_random_uuid();
    post_tumpeng_id UUID := gen_random_uuid();
    post_gudeg_id UUID := gen_random_uuid();
    
    -- Notification UUIDs
    notif_expiry_cabai_id UUID := gen_random_uuid();
    notif_expiry_tempe_id UUID := gen_random_uuid();
    notif_recipe_rec_id UUID := gen_random_uuid();
    notif_new_recipe_id UUID := gen_random_uuid();
    notif_review_id UUID := gen_random_uuid();
    notif_expiry_nangka_id UUID := gen_random_uuid();
    
    -- Chat Message UUIDs
    chat_1_id UUID := gen_random_uuid();
    chat_2_id UUID := gen_random_uuid();
    chat_3_id UUID := gen_random_uuid();
    chat_4_id UUID := gen_random_uuid();
    chat_5_id UUID := gen_random_uuid();
    chat_6_id UUID := gen_random_uuid();
BEGIN

-- Check if data already exists, if so, exit early
IF EXISTS (SELECT 1 FROM user_profiles WHERE email = 'budi.santoso@email.com') THEN
    RAISE NOTICE 'Seeder data already exists. Skipping insertion.';
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
);

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
);

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
    'Rp45.000',
    '30 menit',
    8,
    'Kue terang bulan atau martabak manis dengan topping coklat dan keju yang lumer di mulut. Tekstur lembut dan kenyal.',
    user_dewi_id
),
(
    recipe_sate_ayam_id,
    'Sate Ayam Madura',
    'sate-ayam-madura',
    'public/assets/images/recipe/5.png',
    4.7,
    189,
    'Rp30.000',
    '45 menit',
    3,
    'Sate ayam khas Madura dengan bumbu kacang yang gurih dan sedikit pedas. Disajikan dengan lontong atau nasi putih.',
    user_budi_id
),
(
    recipe_gado_gado_id,
    'Gado-gado Jakarta',
    'gado-gado-jakarta',
    'public/assets/images/recipe/6.png',
    4.5,
    156,
    'Rp20.000',
    '25 menit',
    2,
    'Salad sayuran khas Indonesia dengan saus kacang yang kental dan gurih. Disajikan dengan kerupuk dan telur rebus.',
    user_siti_id
),
(
    recipe_bakso_id,
    'Bakso Malang',
    'bakso-malang',
    'public/assets/images/recipe/7.png',
    4.8,
    210,
    'Rp25.000',
    '40 menit',
    3,
    'Bakso daging sapi dengan tekstur kenyal dan kuah bening yang gurih. Disajikan dengan mie, tahu, dan pangsit.',
    user_agus_id
),
(
    recipe_gudeg_id,
    'Gudeg Yogyakarta',
    'gudeg-yogyakarta',
    'public/assets/images/recipe/8.png',
    4.6,
    165,
    'Rp40.000',
    '3 jam',
    4,
    'Gudeg khas Yogyakarta dengan nangka muda yang dimasak dengan santan dan bumbu rempah. Disajikan dengan ayam, telur, dan sambal krecek.',
    user_indra_id
);

-- Insert recipe categories
INSERT INTO recipe_categories (recipe_id, category) VALUES 
(recipe_nasi_goreng_id, 'Makanan Utama'),
(recipe_nasi_goreng_id, 'Tradisional'),
(recipe_nasi_goreng_id, 'Pedas'),
(recipe_rendang_id, 'Makanan Utama'),
(recipe_rendang_id, 'Tradisional'),
(recipe_rendang_id, 'Pedas'),
(recipe_rendang_id, 'Padang'),
(recipe_soto_ayam_id, 'Sup'),
(recipe_soto_ayam_id, 'Tradisional'),
(recipe_soto_ayam_id, 'Ayam'),
(recipe_martabak_id, 'Makanan Penutup'),
(recipe_martabak_id, 'Kue'),
(recipe_martabak_id, 'Manis'),
(recipe_sate_ayam_id, 'Makanan Utama'),
(recipe_sate_ayam_id, 'Tradisional'),
(recipe_sate_ayam_id, 'Daging'),
(recipe_gado_gado_id, 'Makanan Utama'),
(recipe_gado_gado_id, 'Tradisional'),
(recipe_gado_gado_id, 'Sayuran'),
(recipe_bakso_id, 'Makanan Utama'),
(recipe_bakso_id, 'Sup'),
(recipe_bakso_id, 'Daging'),
(recipe_gudeg_id, 'Makanan Utama'),
(recipe_gudeg_id, 'Tradisional'),
(recipe_gudeg_id, 'Yogyakarta');

-- Insert recipe ingredients
-- Nasi Goreng Kampung ingredients
INSERT INTO recipe_ingredients (recipe_id, ingredient_name, quantity, unit, notes, order_index) VALUES 
(recipe_nasi_goreng_id, 'Nasi Putih', '2', 'piring', 'Rp5.000', 1),
(recipe_nasi_goreng_id, 'Bawang Merah', '5', 'siung', 'Rp2.000', 2),
(recipe_nasi_goreng_id, 'Bawang Putih', '3', 'siung', 'Rp1.500', 3),
(recipe_nasi_goreng_id, 'Cabai Merah', '4', 'buah', 'Rp2.500', 4),
(recipe_nasi_goreng_id, 'Telur Ayam', '2', 'butir', 'Rp3.000', 5),
(recipe_nasi_goreng_id, 'Kecap Manis', '2', 'sdm', 'Rp1.000', 6);

-- Rendang ingredients
INSERT INTO recipe_ingredients (recipe_id, ingredient_name, quantity, unit, notes, order_index) VALUES 
(recipe_rendang_id, 'Daging Sapi', '1', 'kg', 'Rp140.000', 1),
(recipe_rendang_id, 'Santan Kelapa', '2', 'liter', 'Rp25.000', 2),
(recipe_rendang_id, 'Bumbu Rendang', '1', 'paket', 'Rp15.000', 3);

-- Soto Ayam ingredients
INSERT INTO recipe_ingredients (recipe_id, ingredient_name, quantity, unit, notes, order_index) VALUES 
(recipe_soto_ayam_id, 'Ayam Kampung', '1', 'ekor', 'Rp65.000', 1),
(recipe_soto_ayam_id, 'Kunyit', '3', 'ruas', 'Rp2.000', 2),
(recipe_soto_ayam_id, 'Koya (Kerupuk Udang + Bawang)', '100', 'gram', 'Rp10.000', 3);

-- Martabak ingredients
INSERT INTO recipe_ingredients (recipe_id, ingredient_name, quantity, unit, notes, order_index) VALUES 
(recipe_martabak_id, 'Tepung Terigu', '250', 'gram', 'Rp5.000', 1),
(recipe_martabak_id, 'Gula Pasir', '150', 'gram', 'Rp3.000', 2),
(recipe_martabak_id, 'Coklat Meses', '100', 'gram', 'Rp10.000', 3),
(recipe_martabak_id, 'Keju Cheddar', '100', 'gram', 'Rp15.000', 4);

-- Sate Ayam ingredients
INSERT INTO recipe_ingredients (recipe_id, ingredient_name, quantity, unit, notes, order_index) VALUES 
(recipe_sate_ayam_id, 'Ayam Fillet', '500', 'gram', 'Rp35.000', 1),
(recipe_sate_ayam_id, 'Kacang Tanah', '200', 'gram', 'Rp8.000', 2),
(recipe_sate_ayam_id, 'Kecap Manis', '5', 'sdm', 'Rp3.000', 3);

-- Gado-gado ingredients
INSERT INTO recipe_ingredients (recipe_id, ingredient_name, quantity, unit, notes, order_index) VALUES 
(recipe_gado_gado_id, 'Tauge', '100', 'gram', 'Rp2.000', 1),
(recipe_gado_gado_id, 'Kentang', '2', 'buah', 'Rp5.000', 2),
(recipe_gado_gado_id, 'Kacang Tanah', '150', 'gram', 'Rp7.000', 3);

-- Bakso ingredients
INSERT INTO recipe_ingredients (recipe_id, ingredient_name, quantity, unit, notes, order_index) VALUES 
(recipe_bakso_id, 'Daging Sapi Giling', '500', 'gram', 'Rp60.000', 1);

-- Gudeg ingredients
INSERT INTO recipe_ingredients (recipe_id, ingredient_name, quantity, unit, notes, order_index) VALUES 
(recipe_gudeg_id, 'Nangka Muda', '1', 'kg', 'Rp20.000', 1),
(recipe_gudeg_id, 'Santan Kelapa', '1', 'liter', 'Rp15.000', 2),
(recipe_gudeg_id, 'Gula Merah', '200', 'gram', 'Rp8.000', 3),
(recipe_gudeg_id, 'Daun Salam', '5', 'lembar', 'Rp2.000', 4);

-- Insert recipe instructions
-- Nasi Goreng instructions
INSERT INTO recipe_instructions (recipe_id, step_number, instruction_text) VALUES 
(recipe_nasi_goreng_id, 1, 'Haluskan bawang merah, bawang putih, dan cabai.'),
(recipe_nasi_goreng_id, 2, 'Panaskan minyak, tumis bumbu halus hingga harum.'),
(recipe_nasi_goreng_id, 3, 'Masukkan nasi putih, aduk rata.'),
(recipe_nasi_goreng_id, 4, 'Tambahkan kecap manis, garam, dan penyedap rasa secukupnya.'),
(recipe_nasi_goreng_id, 5, 'Aduk hingga semua bumbu tercampur rata.'),
(recipe_nasi_goreng_id, 6, 'Goreng telur mata sapi terpisah.'),
(recipe_nasi_goreng_id, 7, 'Sajikan nasi goreng dengan telur mata sapi di atasnya dan kerupuk.');

-- Rendang instructions
INSERT INTO recipe_instructions (recipe_id, step_number, instruction_text) VALUES 
(recipe_rendang_id, 1, 'Haluskan semua bumbu rendang (bawang merah, bawang putih, cabai, lengkuas, serai, dll).'),
(recipe_rendang_id, 2, 'Tumis bumbu halus hingga harum dan matang.'),
(recipe_rendang_id, 3, 'Masukkan daging sapi, aduk rata dengan bumbu.'),
(recipe_rendang_id, 4, 'Tuang santan, masak dengan api kecil sambil sesekali diaduk.'),
(recipe_rendang_id, 5, 'Masak hingga santan menyusut dan daging empuk (sekitar 3-4 jam).'),
(recipe_rendang_id, 6, 'Rendang siap disajikan dengan nasi putih hangat.');

-- Soto Ayam instructions
INSERT INTO recipe_instructions (recipe_id, step_number, instruction_text) VALUES 
(recipe_soto_ayam_id, 1, 'Rebus ayam hingga matang dan empuk.'),
(recipe_soto_ayam_id, 2, 'Tumis bumbu halus hingga harum.'),
(recipe_soto_ayam_id, 3, 'Masukkan bumbu ke dalam rebusan ayam.'),
(recipe_soto_ayam_id, 4, 'Angkat ayam, suwir-suwir dagingnya.'),
(recipe_soto_ayam_id, 5, 'Sajikan kuah soto dengan ayam suwir, telur rebus, tauge, seledri, dan koya di atasnya.');

-- Martabak instructions
INSERT INTO recipe_instructions (recipe_id, step_number, instruction_text) VALUES 
(recipe_martabak_id, 1, 'Campurkan tepung terigu, gula, ragi, dan air. Aduk rata.'),
(recipe_martabak_id, 2, 'Diamkan adonan sekitar 30 menit hingga mengembang.'),
(recipe_martabak_id, 3, 'Panaskan cetakan martabak dengan api sedang.'),
(recipe_martabak_id, 4, 'Tuang adonan ke dalam cetakan, tutup sebentar.'),
(recipe_martabak_id, 5, 'Setelah berlubang-lubang, taburi gula pasir dan tutup kembali.'),
(recipe_martabak_id, 6, 'Setelah matang, olesi dengan margarin, taburi meses dan keju parut.'),
(recipe_martabak_id, 7, 'Lipat martabak dan potong sesuai selera.');

-- Sate Ayam instructions
INSERT INTO recipe_instructions (recipe_id, step_number, instruction_text) VALUES 
(recipe_sate_ayam_id, 1, 'Potong ayam fillet menjadi dadu kecil.'),
(recipe_sate_ayam_id, 2, 'Rendam ayam dalam bumbu marinasi.'),
(recipe_sate_ayam_id, 3, 'Tusuk ayam dengan tusuk sate.'),
(recipe_sate_ayam_id, 4, 'Panggang sate di atas bara api/panggangan.'),
(recipe_sate_ayam_id, 5, 'Haluskan kacang tanah goreng dan bumbu saus kacang.'),
(recipe_sate_ayam_id, 6, 'Sajikan sate dengan saus kacang dan kecap manis.');

-- Gado-gado instructions
INSERT INTO recipe_instructions (recipe_id, step_number, instruction_text) VALUES 
(recipe_gado_gado_id, 1, 'Rebus semua sayuran hingga matang.'),
(recipe_gado_gado_id, 2, 'Haluskan kacang tanah untuk saus.'),
(recipe_gado_gado_id, 3, 'Tambahkan bumbu-bumbu ke saus kacang.'),
(recipe_gado_gado_id, 4, 'Tata sayuran di piring saji.'),
(recipe_gado_gado_id, 5, 'Siram dengan saus kacang dan taburi dengan bawang goreng.');

-- Bakso instructions
INSERT INTO recipe_instructions (recipe_id, step_number, instruction_text) VALUES 
(recipe_bakso_id, 1, 'Campur daging giling dengan tepung dan bumbu.'),
(recipe_bakso_id, 2, 'Bentuk adonan menjadi bola-bola.'),
(recipe_bakso_id, 3, 'Rebus bakso hingga mengapung.'),
(recipe_bakso_id, 4, 'Siapkan kuah dengan bumbu yang gurih.'),
(recipe_bakso_id, 5, 'Sajikan bakso dengan mie, tahu, dan pangsit.');

-- Gudeg instructions
INSERT INTO recipe_instructions (recipe_id, step_number, instruction_text) VALUES 
(recipe_gudeg_id, 1, 'Potong nangka muda menjadi ukuran sedang.'),
(recipe_gudeg_id, 2, 'Rebus nangka dengan air dan garam hingga empuk.'),
(recipe_gudeg_id, 3, 'Haluskan bumbu gudeg (bawang merah, bawang putih, kemiri, ketumbar).'),
(recipe_gudeg_id, 4, 'Tumis bumbu halus hingga harum.'),
(recipe_gudeg_id, 5, 'Masukkan nangka rebus, santan, dan gula merah.'),
(recipe_gudeg_id, 6, 'Masak dengan api kecil hingga kuah menyusut dan bumbu meresap (2-3 jam).'),
(recipe_gudeg_id, 7, 'Sajikan dengan ayam, telur, dan sambal krecek.');

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
);

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
);

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
(post_gudeg_id, user_agus_id);

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
(user_indra_id, recipe_rendang_id);

-- Insert recipe reviews
INSERT INTO recipe_reviews (recipe_id, user_id, rating, review_text) VALUES 
(recipe_nasi_goreng_id, user_siti_id, 5.0, 'Resep yang sangat mudah diikuti! Nasi gorengnya enak dan bumbu meresap sempurna.'),
(recipe_nasi_goreng_id, user_agus_id, 4.5, 'Keluarga suka banget sama rasanya, cuma porsi cabenya agak kurang buat saya hehe.'),
(recipe_rendang_id, user_budi_id, 5.0, 'Rendang terenak yang pernah saya masak! Prosesnya memang lama tapi hasilnya sebanding.'),
(recipe_rendang_id, user_dewi_id, 4.8, 'Bumbu rendangnya otentik banget, sama seperti buatan mertua saya di Padang.'),
(recipe_soto_ayam_id, user_budi_id, 4.7, 'Kuahnya segar dan ayamnya empuk. Koyanya bikin nagih!'),
(recipe_martabak_id, user_agus_id, 4.6, 'Anak-anak suka banget! Teksturnya lembut dan toppingnya melimpah.'),
(recipe_gudeg_id, user_siti_id, 4.8, 'Authentic Yogya gudeg! Manis gurihnya pas, persis seperti di Malioboro.');

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
);

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
    'Halo! Untuk membuat nasi goreng kampung, Anda membutuhkan: nasi putih dingin, bawang merah, bawang putih, cabai merah, telur, kecap manis, garam, dan minyak goreng. Dari pantry Anda, saya lihat sudah ada telur dan kecap manis. Apakah Anda ingin rekomendasi resep lengkap?',
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
);

-- Update counters to match the actual data
-- (This will be handled automatically by triggers, but we can run it manually to ensure consistency)

-- Update user posts count
UPDATE user_profiles 
SET posts_count = (
    SELECT COUNT(*) 
    FROM community_posts 
    WHERE user_id = user_profiles.id
);

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
SELECT 'Seeder completed successfully! Database has been populated with Indonesian recipe data for 5 users.' as result;
