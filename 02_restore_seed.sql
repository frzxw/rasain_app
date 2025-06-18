-- ========================================
-- RASAIN APP - SEED DATA RESTORATION SCRIPT
-- Fixed UUID format and ready for Supabase
-- Run AFTER schema restoration is complete
-- ========================================

-- Create temporary variables to store all UUIDs for referencing
DO $$
DECLARE
    -- User UUIDs (fixed for consistency - all valid hex)
    user_budi_id UUID := 'f4b57646-647f-4bd1-8cc0-3ebbe2b5b1f0';
    user_siti_id UUID := 'a8c92d41-2f5e-4a3b-9d8e-1c5f7b4e8a2d';
    user_agus_id UUID := 'b7d83e52-3a6f-5b4c-ae9f-2d6e8c5f9b3e';
    user_dewi_id UUID := 'c9e74f63-4b7a-6c5d-bf0a-3e7f9d6a0c4f';
    user_indra_id UUID := 'd0f85a74-5c8b-7d6e-c01b-4f8a0e7b1d5a';
    
    -- Recipe UUIDs (fixed for consistency - all valid hex)
    recipe_nasi_goreng_id UUID := 'e1a96b85-6d9c-8e7f-d12c-5a9b1f8c2e6b';
    recipe_rendang_id UUID := 'f2ba7c96-7ea0-9f8a-e23d-6bac2a9d3f7c';
    recipe_soto_ayam_id UUID := 'a3cb8da7-8fb1-0a9b-f34e-7cbd3ba4e08d';
    recipe_martabak_id UUID := 'b4dc9eb8-9ac2-1bac-a45f-8dce4cb5f19e';
    recipe_sate_ayam_id UUID := 'c5ed0fc9-abd3-2cbd-b56a-9edf5dc6a20f';
    recipe_gado_gado_id UUID := 'd6fe1ada-bce4-3dce-c67b-0fea6ed7b31a';
    recipe_bakso_id UUID := 'e7af2beb-cdf5-4edf-d78c-1afb7fe8c42b';
    recipe_gudeg_id UUID := 'f8ba3cfc-dea6-5fea-e89d-2bac8af9d53c';
    
    -- Pantry Item UUIDs (fixed for consistency - all valid hex)
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
    
    -- Community Post UUIDs (fixed for consistency - all valid hex)
    post_rendang_id UUID := 'edab4beb-cdf5-6edf-d90c-3afb9fe0ca4b';
    post_sambal_id UUID := 'febc5cfc-dea6-7fea-ea1d-4bac0af1db5c';
    post_cendol_id UUID := 'afcd6dad-efb7-8afb-fb2e-5cbd1ba2ec6d';
    post_tumpeng_id UUID := 'bade7ebe-fac8-9bac-ac3f-6dce2cb3fd7e';
    post_gudeg_id UUID := 'cbef8fcf-abd9-0cbd-bd4a-7edf3dc4ae8f';
    
    -- Notification UUIDs (fixed for consistency - all valid hex)
    notif_expiry_cabai_id UUID := 'dcfa9ada-bce0-1dce-ce5b-8fea4ed5bf9a';
    notif_expiry_tempe_id UUID := 'edab0beb-cdf1-2edf-df6c-9afb5fe6ca0b';
    notif_recipe_rec_id UUID := 'febc1cfc-dea2-3fea-ea7d-0bac6af7db1c';
    notif_new_recipe_id UUID := 'afcd2dad-efb3-4afb-fb8e-1cbd7ba8ec2d';
    notif_review_id UUID := 'bade3ebe-fac4-5bac-ac9f-2dce8cb9fd3e';
    notif_expiry_nangka_id UUID := 'cbef4fcf-abd5-6cbd-bd0a-3edf9dc0ae4f';
    
    -- Chat Message UUIDs (fixed for consistency - all valid hex)
    chat_1_id UUID := 'dcfa5ada-bce6-7dce-ce1b-4fea0ed1bf5a';
    chat_2_id UUID := 'edab6beb-cdf7-8edf-df2c-5afb1fe2ca6b';
    chat_3_id UUID := 'febc7cfc-dea8-9fea-ea3d-6bac2af3db7c';
    chat_4_id UUID := 'afcd8dad-efb9-0afb-fb4e-7cbd3ba4ec8d';
    chat_5_id UUID := 'bade9ebe-fac0-1bac-ac5f-8dce4cb5fd9e';
    chat_6_id UUID := 'cbef0fcf-abd1-2cbd-bd6a-9edf5dc6ae0f';
    
    -- Tool UUIDs (fixed for consistency - all valid hex)
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
    email,
    email_confirmed_at,
    created_at,
    updated_at,
    aud,
    role
) VALUES 
(
    user_budi_id,
    'budi.santoso@email.com',
    NOW(),
    NOW(),
    NOW(),
    'authenticated',
    'authenticated'
),
(
    user_siti_id,
    'siti.nurhaliza@email.com',
    NOW(),
    NOW(),
    NOW(),
    'authenticated',
    'authenticated'
),
(
    user_agus_id,
    'agus.salim@email.com',
    NOW(),
    NOW(),
    NOW(),
    'authenticated',
    'authenticated'
),
(
    user_dewi_id,
    'dewi.sartika@email.com',
    NOW(),
    NOW(),
    NOW(),
    'authenticated',
    'authenticated'
),
(
    user_indra_id,
    'indra.gunawan@email.com',
    NOW(),
    NOW(),
    NOW(),
    'authenticated',
    'authenticated'
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
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    3,
    2,
    TRUE,
    'id',
    FALSE
),
(
    user_siti_id,
    'Siti Nurhaliza',
    'siti.nurhaliza@email.com',
    'https://images.unsplash.com/photo-1494790108755-2616b612b123?w=150',
    5,
    1,
    TRUE,
    'id',
    TRUE
),
(
    user_agus_id,
    'Agus Salim',
    'agus.salim@email.com',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    2,
    3,
    TRUE,
    'id',
    FALSE
),
(
    user_dewi_id,
    'Dewi Sartika',
    'dewi.sartika@email.com',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
    4,
    1,
    FALSE,
    'id',
    TRUE
),
(
    user_indra_id,
    'Indra Gunawan',
    'indra.gunawan@email.com',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    1,
    2,
    TRUE,
    'id',
    FALSE
)
ON CONFLICT (id) DO NOTHING;

-- Insert recipe categories
INSERT INTO recipe_categories (name, name_id, name_en, description) VALUES 
('Makanan Utama', 'makanan_utama', 'Main Course', 'Hidangan utama untuk makan'),
('Nasi', 'nasi', 'Rice', 'Hidangan berbasis nasi'),
('Daging', 'daging', 'Meat', 'Hidangan berbasis daging'),
('Tradisional', 'tradisional', 'Traditional', 'Makanan tradisional Indonesia'),
('Sup', 'sup', 'Soup', 'Hidangan berkuah'),
('Ayam', 'ayam', 'Chicken', 'Hidangan berbasis ayam'),
('Makanan Penutup', 'makanan_penutup', 'Dessert', 'Hidangan penutup'),
('Kue', 'kue', 'Cake', 'Kue dan roti'),
('Panggang', 'panggang', 'Grilled', 'Hidangan panggang'),
('Salad', 'salad', 'Salad', 'Hidangan salad'),
('Sayuran', 'sayuran', 'Vegetables', 'Hidangan berbasis sayuran')
ON CONFLICT (name) DO NOTHING;

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
    prep_time,
    total_time,
    servings,
    difficulty_level,
    description,
    nutrition_info,
    tips,
    created_by,
    is_featured,
    is_published
) VALUES 
(
    recipe_nasi_goreng_id,
    'Nasi Goreng Kampung',
    'nasi-goreng-kampung',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400',
    4.5,
    12,
    'Rp 10.000 - 15.000',
    '15 menit',
    '10 menit',
    '25 menit',
    2,
    'mudah',
    'Nasi goreng kampung khas Indonesia dengan bumbu sederhana namun lezat. Menggunakan kecap manis dan cabai rawit untuk rasa yang autentik.',
    '{"kalori": 450, "protein": "12g", "karbohidrat": "65g", "lemak": "18g"}'::jsonb,
    'Gunakan nasi yang sudah dingin untuk hasil yang tidak lengket. Tumis bumbu hingga harum sebelum menambahkan nasi.',
    user_budi_id,
    TRUE,
    TRUE
),
(
    recipe_rendang_id,
    'Rendang Daging Sapi',
    'rendang-daging-sapi',
    'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=400',
    4.8,
    25,
    'Rp 50.000 - 75.000',
    '3 jam',
    '30 menit',
    '3 jam 30 menit',
    6,
    'sulit',
    'Rendang daging sapi autentik Minang dengan bumbu rempah yang kaya. Dimasak dengan santan hingga bumbu meresap sempurna.',
    '{"kalori": 520, "protein": "35g", "karbohidrat": "8g", "lemak": "38g"}'::jsonb,
    'Masak dengan api kecil dan aduk sesekali. Rendang matang ditandai dengan warna cokelat gelap dan minyak yang keluar.',
    user_budi_id,
    TRUE,
    TRUE
),
(
    recipe_soto_ayam_id,
    'Soto Ayam Lamongan',
    'soto-ayam-lamongan',
    'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400',
    4.3,
    18,
    'Rp 20.000 - 30.000',
    '45 menit',
    '20 menit',
    '1 jam 5 menit',
    4,
    'sedang',
    'Soto ayam khas Lamongan dengan kuah bening yang segar. Dilengkapi dengan daging ayam, telur, dan sayuran.',
    '{"kalori": 280, "protein": "22g", "karbohidrat": "15g", "lemak": "15g"}'::jsonb,
    'Rebus ayam dengan rempah untuk kaldu yang gurih. Sajikan dengan nasi dan kerupuk.',
    user_siti_id,
    FALSE,
    TRUE
),
(
    recipe_martabak_id,
    'Martabak Manis Pandan',
    'martabak-manis-pandan',
    'https://images.unsplash.com/photo-1559847844-5315695dadae?w=400',
    4.2,
    15,
    'Rp 15.000 - 25.000',
    '20 menit',
    '15 menit',
    '35 menit',
    4,
    'sedang',
    'Martabak manis dengan aroma pandan yang harum. Diisi dengan mentega, gula, keju, dan kacang tanah.',
    '{"kalori": 420, "protein": "8g", "karbohidrat": "55g", "lemak": "20g"}'::jsonb,
    'Adonan harus istirahat minimal 30 menit. Panaskan teflon dengan api kecil untuk hasil yang matang merata.',
    user_agus_id,
    FALSE,
    TRUE
),
(
    recipe_sate_ayam_id,
    'Sate Ayam Madura',
    'sate-ayam-madura',
    'https://images.unsplash.com/photo-1529042410759-befb1204b468?w=400',
    4.6,
    20,
    'Rp 25.000 - 35.000',
    '30 menit',
    '1 jam 15 menit',
    '1 jam 45 menit',
    4,
    'sedang',
    'Sate ayam khas Madura dengan bumbu kacang yang kental dan gurih. Dibakar dengan arang untuk aroma yang autentik.',
    '{"kalori": 350, "protein": "28g", "karbohidrat": "12g", "lemak": "22g"}'::jsonb,
    'Rendam tusukan sate dalam air sebelum digunakan. Bakar dengan api sedang sambil diolesi bumbu.',
    user_budi_id,
    TRUE,
    TRUE
),
(
    recipe_gado_gado_id,
    'Gado-gado Jakarta',
    'gado-gado-jakarta',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400',
    4.4,
    15,
    'Rp 15.000 - 25.000',
    '30 menit',
    '25 menit',
    '55 menit',
    4,
    'mudah',
    'Gado-gado Jakarta dengan sayuran segar dan bumbu kacang yang gurih. Menu sehat dan bergizi.',
    '{"kalori": 320, "protein": "15g", "karbohidrat": "25g", "lemak": "20g"}'::jsonb,
    'Rebus sayuran jangan terlalu lama agar tetap renyah. Bumbu kacang sebaiknya dibuat fresh.',
    user_dewi_id,
    FALSE,
    TRUE
),
(
    recipe_bakso_id,
    'Bakso Malang',
    'bakso-malang',
    'https://images.unsplash.com/photo-1581299894007-aaa50297cf16?w=400',
    4.7,
    22,
    'Rp 30.000 - 45.000',
    '1 jam',
    '45 menit',
    '1 jam 45 menit',
    6,
    'sulit',
    'Bakso Malang dengan berbagai variasi bakso dan mie. Kuah kaldu sapi yang gurih dan hangat.',
    '{"kalori": 380, "protein": "25g", "karbohidrat": "30g", "lemak": "18g"}'::jsonb,
    'Daging harus digiling halus dan dicampur es agar bakso kenyal. Rebus dengan air mendidih.',
    user_budi_id,
    TRUE,
    TRUE
),
(
    recipe_gudeg_id,
    'Gudeg Yogyakarta',
    'gudeg-yogyakarta',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
    4.5,
    16,
    'Rp 20.000 - 35.000',
    '2 jam 30 menit',
    '30 menit',
    '3 jam',
    4,
    'sulit',
    'Gudeg khas Yogyakarta dengan nangka muda yang manis dan gurih. Dimasak dengan santan dan gula merah.',
    '{"kalori": 300, "protein": "8g", "karbohidrat": "45g", "lemak": "12g"}'::jsonb,
    'Masak dengan api kecil dan sabar. Semakin lama dimasak, rasa akan semakin meresap.',
    user_siti_id,
    FALSE,
    TRUE
)
ON CONFLICT (id) DO NOTHING;

-- Insert recipe-category relationships using subqueries to get correct IDs
INSERT INTO recipe_categories_recipes (recipe_id, category_id) 
SELECT recipe_id, category_id FROM (
    VALUES 
    -- Nasi Goreng Kampung
    (recipe_nasi_goreng_id, (SELECT id FROM recipe_categories WHERE name_id = 'makanan_utama')),
    (recipe_nasi_goreng_id, (SELECT id FROM recipe_categories WHERE name_id = 'nasi')),
    (recipe_nasi_goreng_id, (SELECT id FROM recipe_categories WHERE name_id = 'tradisional')),

    -- Rendang Daging Sapi
    (recipe_rendang_id, (SELECT id FROM recipe_categories WHERE name_id = 'makanan_utama')),
    (recipe_rendang_id, (SELECT id FROM recipe_categories WHERE name_id = 'daging')),
    (recipe_rendang_id, (SELECT id FROM recipe_categories WHERE name_id = 'tradisional')),

    -- Soto Ayam Lamongan
    (recipe_soto_ayam_id, (SELECT id FROM recipe_categories WHERE name_id = 'makanan_utama')),
    (recipe_soto_ayam_id, (SELECT id FROM recipe_categories WHERE name_id = 'sup')),
    (recipe_soto_ayam_id, (SELECT id FROM recipe_categories WHERE name_id = 'ayam')),

    -- Martabak Manis Pandan
    (recipe_martabak_id, (SELECT id FROM recipe_categories WHERE name_id = 'makanan_penutup')),
    (recipe_martabak_id, (SELECT id FROM recipe_categories WHERE name_id = 'kue')),

    -- Sate Ayam Madura
    (recipe_sate_ayam_id, (SELECT id FROM recipe_categories WHERE name_id = 'makanan_utama')),
    (recipe_sate_ayam_id, (SELECT id FROM recipe_categories WHERE name_id = 'ayam')),
    (recipe_sate_ayam_id, (SELECT id FROM recipe_categories WHERE name_id = 'panggang')),

    -- Gado-gado Jakarta
    (recipe_gado_gado_id, (SELECT id FROM recipe_categories WHERE name_id = 'salad')),
    (recipe_gado_gado_id, (SELECT id FROM recipe_categories WHERE name_id = 'sayuran')),

    -- Bakso Malang
    (recipe_bakso_id, (SELECT id FROM recipe_categories WHERE name_id = 'makanan_utama')),
    (recipe_bakso_id, (SELECT id FROM recipe_categories WHERE name_id = 'daging')),
    (recipe_bakso_id, (SELECT id FROM recipe_categories WHERE name_id = 'sup')),

    -- Gudeg Yogyakarta
    (recipe_gudeg_id, (SELECT id FROM recipe_categories WHERE name_id = 'makanan_utama')),
    (recipe_gudeg_id, (SELECT id FROM recipe_categories WHERE name_id = 'tradisional')),
    (recipe_gudeg_id, (SELECT id FROM recipe_categories WHERE name_id = 'sayuran'))
) AS t(recipe_id, category_id)
WHERE category_id IS NOT NULL
ON CONFLICT (recipe_id, category_id) DO NOTHING;

-- Insert recipe ingredients (BAHAN-BAHAN RESEP)
INSERT INTO recipe_ingredients (recipe_id, ingredient_name, quantity, unit, order_index) VALUES 
-- Nasi Goreng Kampung
(recipe_nasi_goreng_id, 'Nasi putih', '3', 'piring', 1),
(recipe_nasi_goreng_id, 'Telur ayam', '2', 'butir', 2),
(recipe_nasi_goreng_id, 'Kecap manis', '3', 'sdm', 3),
(recipe_nasi_goreng_id, 'Bawang merah', '5', 'siung', 4),
(recipe_nasi_goreng_id, 'Bawang putih', '3', 'siung', 5),
(recipe_nasi_goreng_id, 'Cabai merah', '3', 'buah', 6),
(recipe_nasi_goreng_id, 'Minyak goreng', '3', 'sdm', 7),
(recipe_nasi_goreng_id, 'Garam', '1', 'sdt', 8),

-- Rendang Daging Sapi
(recipe_rendang_id, 'Daging sapi', '1', 'kg', 1),
(recipe_rendang_id, 'Santan kelapa', '500', 'ml', 2),
(recipe_rendang_id, 'Cabai merah besar', '10', 'buah', 3),
(recipe_rendang_id, 'Bawang merah', '8', 'siung', 4),
(recipe_rendang_id, 'Bawang putih', '5', 'siung', 5),
(recipe_rendang_id, 'Lengkuas', '3', 'cm', 6),
(recipe_rendang_id, 'Jahe', '2', 'cm', 7),
(recipe_rendang_id, 'Kunyit', '2', 'cm', 8),

-- Soto Ayam Lamongan
(recipe_soto_ayam_id, 'Ayam kampung', '1', 'ekor', 1),
(recipe_soto_ayam_id, 'Bawang merah', '6', 'siung', 2),
(recipe_soto_ayam_id, 'Bawang putih', '4', 'siung', 3),
(recipe_soto_ayam_id, 'Jahe', '2', 'cm', 4),
(recipe_soto_ayam_id, 'Serai', '2', 'batang', 5),

-- Martabak Manis Pandan
(recipe_martabak_id, 'Tepung terigu', '250', 'gram', 1),
(recipe_martabak_id, 'Telur ayam', '2', 'butir', 2),
(recipe_martabak_id, 'Susu cair', '300', 'ml', 3),
(recipe_martabak_id, 'Gula pasir', '3', 'sdm', 4),
(recipe_martabak_id, 'Pasta pandan', '1', 'sdt', 5),

-- Sate Ayam Madura
(recipe_sate_ayam_id, 'Daging ayam', '500', 'gram', 1),
(recipe_sate_ayam_id, 'Kecap manis', '4', 'sdm', 2),
(recipe_sate_ayam_id, 'Bawang merah', '6', 'siung', 3),
(recipe_sate_ayam_id, 'Bawang putih', '4', 'siung', 4),
(recipe_sate_ayam_id, 'Kemiri', '3', 'butir', 5),

-- Gado-gado Jakarta
(recipe_gado_gado_id, 'Kangkung', '200', 'gram', 1),
(recipe_gado_gado_id, 'Tauge', '150', 'gram', 2),
(recipe_gado_gado_id, 'Tempe', '200', 'gram', 3),
(recipe_gado_gado_id, 'Kentang', '2', 'buah', 4),
(recipe_gado_gado_id, 'Tahu', '4', 'potong', 5),

-- Bakso Malang
(recipe_bakso_id, 'Daging sapi giling', '500', 'gram', 1),
(recipe_bakso_id, 'Tepung tapioka', '100', 'gram', 2),
(recipe_bakso_id, 'Tulang sapi', '500', 'gram', 3),
(recipe_bakso_id, 'Mie', '200', 'gram', 4),

-- Gudeg Yogyakarta
(recipe_gudeg_id, 'Nangka muda', '1', 'kg', 1),
(recipe_gudeg_id, 'Santan kelapa', '500', 'ml', 2),
(recipe_gudeg_id, 'Gula merah', '200', 'gram', 3),
(recipe_gudeg_id, 'Daun salam', '5', 'lembar', 4),
(recipe_gudeg_id, 'Lengkuas', '2', 'cm', 5)
ON CONFLICT (id) DO NOTHING;

-- Insert recipe instructions (LANGKAH-LANGKAH MEMASAK)
INSERT INTO recipe_instructions (recipe_id, step_number, instruction_text) VALUES 
-- Nasi Goreng Kampung
(recipe_nasi_goreng_id, 1, 'Haluskan bawang merah, bawang putih, dan cabai merah.'),
(recipe_nasi_goreng_id, 2, 'Panaskan minyak, tumis bumbu halus hingga harum.'),
(recipe_nasi_goreng_id, 3, 'Masukkan telur, orak-arik hingga matang.'),
(recipe_nasi_goreng_id, 4, 'Tambahkan nasi putih, aduk rata.'),
(recipe_nasi_goreng_id, 5, 'Tuang kecap manis dan garam, aduk hingga merata.'),
(recipe_nasi_goreng_id, 6, 'Sajikan dengan kerupuk dan acar.'),

-- Rendang Daging Sapi
(recipe_rendang_id, 1, 'Potong daging sapi kotak-kotak ukuran sedang.'),
(recipe_rendang_id, 2, 'Haluskan semua bumbu: cabai, bawang merah, bawang putih, lengkuas, jahe, kunyit.'),
(recipe_rendang_id, 3, 'Tumis bumbu halus hingga harum dan matang.'),
(recipe_rendang_id, 4, 'Masukkan daging, aduk hingga berubah warna.'),
(recipe_rendang_id, 5, 'Tuang santan, masak dengan api kecil sambil diaduk.'),
(recipe_rendang_id, 6, 'Masak hingga santan menyusut dan daging empuk (2-3 jam).'),
(recipe_rendang_id, 7, 'Aduk terus hingga rendang berwarna cokelat gelap dan berminyak.'),

-- Soto Ayam Lamongan
(recipe_soto_ayam_id, 1, 'Rebus ayam kampung dengan jahe dan serai hingga empuk.'),
(recipe_soto_ayam_id, 2, 'Angkat ayam, suwir-suwir dagingnya.'),
(recipe_soto_ayam_id, 3, 'Tumis bawang merah dan bawang putih hingga harum.'),
(recipe_soto_ayam_id, 4, 'Masukkan tumisan ke dalam kaldu ayam.'),
(recipe_soto_ayam_id, 5, 'Didihkan dan bumbui dengan garam dan merica.'),
(recipe_soto_ayam_id, 6, 'Sajikan dengan ayam suwir, telur, dan sayuran.'),

-- Martabak Manis Pandan
(recipe_martabak_id, 1, 'Campur tepung terigu, telur, susu cair, dan gula.'),
(recipe_martabak_id, 2, 'Tambahkan pasta pandan, aduk hingga rata.'),
(recipe_martabak_id, 3, 'Diamkan adonan selama 30 menit.'),
(recipe_martabak_id, 4, 'Panaskan teflon dengan api kecil.'),
(recipe_martabak_id, 5, 'Tuang adonan, ratakan, tutup hingga matang.'),
(recipe_martabak_id, 6, 'Beri topping mentega, gula, keju, dan kacang.'),

-- Sate Ayam Madura
(recipe_sate_ayam_id, 1, 'Potong daging ayam kotak-kotak untuk sate.'),
(recipe_sate_ayam_id, 2, 'Haluskan bawang merah, bawang putih, kemiri.'),
(recipe_sate_ayam_id, 3, 'Marinasi daging dengan bumbu halus dan kecap manis.'),
(recipe_sate_ayam_id, 4, 'Diamkan selama 1 jam.'),
(recipe_sate_ayam_id, 5, 'Tusuk daging ke tusukan sate.'),
(recipe_sate_ayam_id, 6, 'Bakar dengan arang sambil diolesi bumbu.'),

-- Gado-gado Jakarta
(recipe_gado_gado_id, 1, 'Rebus kangkung dan tauge sebentar, tiriskan.'),
(recipe_gado_gado_id, 2, 'Goreng tempe dan tahu hingga kuning kecokelatan.'),
(recipe_gado_gado_id, 3, 'Rebus kentang hingga empuk, potong-potong.'),
(recipe_gado_gado_id, 4, 'Buat bumbu kacang dari kacang tanah yang digoreng.'),
(recipe_gado_gado_id, 5, 'Tata semua sayuran dan pelengkap di piring.'),
(recipe_gado_gado_id, 6, 'Siram dengan bumbu kacang yang gurih.'),

-- Bakso Malang
(recipe_bakso_id, 1, 'Rebus tulang sapi untuk membuat kaldu.'),
(recipe_bakso_id, 2, 'Campur daging giling dengan tepung tapioka dan es.'),
(recipe_bakso_id, 3, 'Bentuk adonan menjadi bulatan bakso.'),
(recipe_bakso_id, 4, 'Rebus bakso dalam air mendidih hingga mengapung.'),
(recipe_bakso_id, 5, 'Rebus mie sebentar, tiriskan.'),
(recipe_bakso_id, 6, 'Sajikan bakso dengan mie dan kuah kaldu panas.'),

-- Gudeg Yogyakarta
(recipe_gudeg_id, 1, 'Potong nangka muda sesuai selera.'),
(recipe_gudeg_id, 2, 'Rebus nangka muda hingga empuk.'),
(recipe_gudeg_id, 3, 'Haluskan bawang merah, bawang putih, kemiri.'),
(recipe_gudeg_id, 4, 'Tumis bumbu halus dengan lengkuas dan daun salam.'),
(recipe_gudeg_id, 5, 'Masukkan nangka rebus, santan, dan gula merah.'),
(recipe_gudeg_id, 6, 'Masak dengan api kecil hingga kuah menyusut dan bumbu meresap (2-3 jam).'),
(recipe_gudeg_id, 7, 'Sajikan dengan ayam, telur, dan sambal krecek.')
ON CONFLICT (recipe_id, step_number) DO NOTHING;

-- Insert tools
INSERT INTO tools (
    id,
    name,
    name_id,
    name_en,
    description,
    category
) VALUES 
(
    tool_wajan_id,
    'Wajan',
    'wajan',
    'Wok',
    'Wajan anti lengket untuk menumis dan menggoreng',
    'Peralatan Masak'
),
(
    tool_panci_id,
    'Panci',
    'panci',
    'Pot',
    'Panci untuk merebus dan memasak berkuah',
    'Peralatan Masak'
),
(
    tool_pisau_id,
    'Pisau Chef',
    'pisau_chef',
    'Chef Knife',
    'Pisau tajam untuk memotong berbagai bahan',
    'Peralatan Potong'
),
(
    tool_talenan_id,
    'Talenan',
    'talenan',
    'Cutting Board',
    'Talenan kayu atau plastik untuk alas memotong',
    'Peralatan Potong'
),
(
    tool_spatula_id,
    'Spatula',
    'spatula',
    'Spatula',
    'Spatula untuk mengaduk dan membalik makanan',
    'Peralatan Masak'
),
(
    tool_blender_id,
    'Blender',
    'blender',
    'Blender',
    'Blender untuk menghaluskan bumbu dan membuat jus',
    'Peralatan Elektrik'
),
(
    tool_rice_cooker_id,
    'Rice Cooker',
    'rice_cooker',
    'Rice Cooker',
    'Penanak nasi elektrik untuk memasak nasi',
    'Peralatan Elektrik'
),
(
    tool_kompor_id,
    'Kompor Gas',
    'kompor_gas',
    'Gas Stove',
    'Kompor gas untuk memasak berbagai hidangan',
    'Peralatan Masak'
),
(
    tool_cobek_id,
    'Cobek',
    'cobek',
    'Mortar and Pestle',
    'Cobek dan ulekan untuk menghaluskan bumbu',
    'Peralatan Tradisional'
),
(
    tool_kukusan_id,
    'Kukusan',
    'kukusan',
    'Steamer',
    'Alat untuk mengukus makanan',
    'Peralatan Masak'
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
(recipe_soto_ayam_id, tool_panci_id, TRUE, 'Untuk merebus ayam'),
(recipe_soto_ayam_id, tool_pisau_id, TRUE, 'Untuk memotong ayam'),
(recipe_soto_ayam_id, tool_talenan_id, TRUE, 'Untuk alas memotong'),
(recipe_soto_ayam_id, tool_kompor_id, TRUE, 'Untuk memasak')
ON CONFLICT (recipe_id, tool_id) DO NOTHING;

-- Insert pantry categories
INSERT INTO pantry_categories (name, name_id, name_en, description, icon) VALUES 
('Makanan Pokok', 'makanan_pokok', 'Staples', 'Beras, mie, roti', 'grain'),
('Bumbu Dapur', 'bumbu_dapur', 'Spices', 'Bumbu dan rempah-rempah', 'spice'),
('Sayuran', 'sayuran', 'Vegetables', 'Sayur-sayuran segar', 'vegetable'),
('Daging & Unggas', 'daging_unggas', 'Meat & Poultry', 'Daging dan unggas', 'meat'),
('Ikan & Seafood', 'ikan_seafood', 'Fish & Seafood', 'Ikan dan hasil laut', 'fish'),
('Buah-buahan', 'buah_buahan', 'Fruits', 'Buah-buahan segar', 'fruit'),
('Karbohidrat', 'karbohidrat', 'Carbohydrates', 'Nasi, pasta, roti', 'grain'),
('Susu & Olahan', 'susu_olahan', 'Dairy', 'Susu dan produk olahannya', 'dairy'),
('Makanan Kaleng', 'makanan_kaleng', 'Canned Food', 'Makanan dalam kemasan kaleng', 'can'),
('Bumbu Instant', 'bumbu_instant', 'Instant Seasoning', 'Bumbu siap pakai', 'packet')
ON CONFLICT (name_id) DO NOTHING;

-- Insert pantry items for Budi using dynamic category lookups
INSERT INTO pantry_items (
    id,
    user_id,
    name,
    quantity,
    unit,
    category_id,
    location,
    expiration_date,
    is_running_low
) 
SELECT id, user_id, name, quantity, unit, category_id, location, expiration_date, is_running_low
FROM (
    VALUES 
    (pantry_beras_id, user_budi_id, 'Beras Putih', '5', 'kg', (SELECT id FROM pantry_categories WHERE name_id = 'makanan_pokok'), 'Lemari Dapur', '2025-12-31'::DATE, FALSE),
    (pantry_telur_id, user_budi_id, 'Telur Ayam', '12', 'butir', (SELECT id FROM pantry_categories WHERE name_id = 'susu_olahan'), 'Kulkas', '2025-06-25'::DATE, TRUE),
    (pantry_kecap_id, user_budi_id, 'Kecap Manis', '1', 'botol', (SELECT id FROM pantry_categories WHERE name_id = 'bumbu_dapur'), 'Lemari Dapur', '2025-10-20'::DATE, FALSE),
    (pantry_minyak_id, user_budi_id, 'Minyak Goreng', '1', 'liter', (SELECT id FROM pantry_categories WHERE name_id = 'bumbu_dapur'), 'Lemari Dapur', '2025-08-15'::DATE, FALSE),
    (pantry_cabai_id, user_budi_id, 'Cabai Merah', '200', 'gram', (SELECT id FROM pantry_categories WHERE name_id = 'sayuran'), 'Kulkas', '2025-06-22'::DATE, TRUE),
    (pantry_tempe_id, user_budi_id, 'Tempe', '2', 'papan', (SELECT id FROM pantry_categories WHERE name_id = 'susu_olahan'), 'Kulkas', '2025-06-20'::DATE, TRUE),
    (pantry_santan_id, user_budi_id, 'Santan Instan', '5', 'sachet', (SELECT id FROM pantry_categories WHERE name_id = 'makanan_kaleng'), 'Lemari Dapur', '2025-09-30'::DATE, FALSE),
    (pantry_terasi_id, user_budi_id, 'Terasi', '1', 'kotak', (SELECT id FROM pantry_categories WHERE name_id = 'bumbu_dapur'), 'Lemari Dapur', '2026-01-15'::DATE, FALSE),
    (pantry_nangka_id, user_budi_id, 'Nangka Muda', '500', 'gram', (SELECT id FROM pantry_categories WHERE name_id = 'sayuran'), 'Kulkas', '2025-06-23'::DATE, TRUE),
    (pantry_gula_merah_id, user_budi_id, 'Gula Merah', '250', 'gram', (SELECT id FROM pantry_categories WHERE name_id = 'bumbu_dapur'), 'Lemari Dapur', '2025-11-10'::DATE, FALSE)
) AS t(id, user_id, name, quantity, unit, category_id, location, expiration_date, is_running_low)
WHERE category_id IS NOT NULL
ON CONFLICT (id) DO NOTHING;

-- Sample additional pantry items for other users using dynamic category lookups
INSERT INTO pantry_items (user_id, name, quantity, unit, category_id, location, expiration_date, is_running_low) 
SELECT user_id, name, quantity, unit, category_id, location, expiration_date, is_running_low
FROM (
    VALUES 
    (user_budi_id, 'Bawang Merah', '500', 'gram', (SELECT id FROM pantry_categories WHERE name_id = 'bumbu_dapur'), 'Kulkas', '2025-07-01'::DATE, FALSE),
    (user_budi_id, 'Bawang Putih', '200', 'gram', (SELECT id FROM pantry_categories WHERE name_id = 'bumbu_dapur'), 'Kulkas', '2025-07-05'::DATE, FALSE),
    (user_budi_id, 'Kecap Manis', '1', 'botol', (SELECT id FROM pantry_categories WHERE name_id = 'makanan_pokok'), 'Lemari Dapur', '2025-10-20'::DATE, FALSE),
    (user_budi_id, 'Telur Ayam', '12', 'butir', (SELECT id FROM pantry_categories WHERE name_id = 'susu_olahan'), 'Kulkas', '2025-06-25'::DATE, TRUE)
) AS t(user_id, name, quantity, unit, category_id, location, expiration_date, is_running_low)
WHERE category_id IS NOT NULL
ON CONFLICT (id) DO NOTHING;

-- Sample saved recipes
INSERT INTO saved_recipes (user_id, recipe_id, notes) VALUES 
(user_budi_id, recipe_rendang_id, 'Mau coba buat untuk acara keluarga'),
(user_budi_id, recipe_soto_ayam_id, 'Resep favorit istri'),
(user_siti_id, recipe_nasi_goreng_id, 'Simple tapi enak'),
(user_siti_id, recipe_bakso_id, 'Anak-anak suka bakso'),
(user_agus_id, recipe_sate_ayam_id, 'Cocok untuk BBQ weekend'),
(user_dewi_id, recipe_gado_gado_id, 'Menu diet sehat'),
(user_indra_id, recipe_martabak_id, 'Ide usaha sampingan')
ON CONFLICT (user_id, recipe_id) DO NOTHING;

-- Sample recipe reviews
INSERT INTO recipe_reviews (recipe_id, user_id, rating, comment) VALUES 
(recipe_nasi_goreng_id, user_siti_id, 4.5, 'Enak banget! Anak-anak suka. Bumbu pas dan tidak terlalu pedas.'),
(recipe_nasi_goreng_id, user_agus_id, 4.0, 'Resep yang mudah diikuti. Hasilnya sesuai ekspektasi.'),
(recipe_rendang_id, user_budi_id, 5.0, 'Rendang terenak yang pernah saya buat! Bumbu sangat meresap.'),
(recipe_rendang_id, user_agus_id, 4.5, 'Proses agak lama tapi hasilnya sangat memuaskan.'),
(recipe_soto_ayam_id, user_dewi_id, 4.0, 'Kuahnya segar dan ayamnya empuk. Cocok untuk cuaca dingin.'),
(recipe_bakso_id, user_siti_id, 4.8, 'Baksonya kenyal dan kuahnya gurih. Resep yang sangat recommended!'),
(recipe_sate_ayam_id, user_indra_id, 4.5, 'Bumbu kacangnya mantap! Sate jadi lebih nikmat.')
ON CONFLICT (recipe_id, user_id) DO NOTHING;

-- Sample community posts
INSERT INTO community_posts (
    user_id,
    title,
    content,
    recipe_id,
    category,
    like_count,
    comment_count
) VALUES 
(
    user_budi_id,
    'Tips Membuat Nasi Goreng yang Tidak Lengket',
    'Setelah coba-coba akhirnya ketemu triknya! Kunci utamanya adalah menggunakan nasi yang sudah dingin dan tidak baru matang. Nasi yang masih hangat akan membuat hasil nasi goreng jadi lengket dan tidak terpisah dengan baik.',
    recipe_nasi_goreng_id,
    'Tips & Trik',
    15,
    3
),
(
    user_siti_id,
    'Rendang Buatan Sendiri vs Beli Jadi',
    'Kemarin cobain bikin rendang sendiri pakai resep dari sini. Memang butuh waktu lama dan sabar, tapi hasilnya jauh lebih enak dibanding beli jadi. Bumbu lebih meresap dan rasa lebih autentik.',
    recipe_rendang_id,
    'Review',
    22,
    7
),
(
    user_agus_id,
    'Variasi Topping Martabak Manis',
    'Buat yang bosan dengan topping martabak biasa, coba deh eksperimen dengan topping lain seperti pisang, strawberry, atau bahkan ice cream di atasnya. Dijamin seru!',
    recipe_martabak_id,
    'Kreasi',
    8,
    2
)
ON CONFLICT (id) DO NOTHING;

-- Sample notifications
INSERT INTO notifications (
    user_id,
    notification_type,
    title,
    message,
    is_read
) VALUES 
(user_budi_id, 'expiration_warning', 'Telur Akan Segera Kedaluwarsa', 'Telur ayam di pantry Anda akan kedaluwarsa dalam 2 hari. Segera gunakan atau konsumsi.', FALSE),
(user_budi_id, 'low_stock', 'Stok Minyak Goreng Menipis', 'Minyak goreng di pantry Anda sudah hampir habis. Jangan lupa untuk membeli lagi.', FALSE),
(user_budi_id, 'recipe_recommendation', 'Resep Rekomendasi', 'Berdasarkan pantry Anda, kami merekomendasikan resep "Nasi Goreng Kampung" yang bisa dibuat dengan bahan yang tersedia.', TRUE),
(user_siti_id, 'new_recipe', 'Resep Baru Ditambahkan', 'Resep "Gudeg Yogyakarta" baru saja ditambahkan. Cek dan coba buat di rumah!', FALSE),
(user_agus_id, 'review', 'Review Resep Anda', 'Seseorang memberikan review 5 bintang untuk resep "Martabak Manis Pandan" Anda. Terima kasih sudah berbagi!', FALSE),
(user_siti_id, 'recipe_recommendation', 'Resep Baru Untukmu', 'Berdasarkan preferensi Anda, kami merekomendasikan resep "Ayam Bakar Kecap" yang baru ditambahkan.', TRUE),
(user_agus_id, 'system', 'Update Aplikasi', 'Versi terbaru aplikasi Rasain telah tersedia. Update sekarang untuk fitur-fitur terbaru!', FALSE)
ON CONFLICT (id) DO NOTHING;

END $$;

-- Success message
SELECT 'Rasain App Seed Data Restored Successfully!' as status,
       COUNT(*) as total_recipes FROM recipes;