-- ========================================
-- Rasain App - Supabase Database Seeder (Restore Version)
-- Based on backup_seed.sql - Uses ON CONFLICT DO NOTHING for safety
-- Jalankan SETELAH schema restore berhasil
-- ========================================

-- Create temporary variables to store all UUIDs for referencing
DO $$
DECLARE
    -- User UUIDs (fixed for consistency)
    user_budi_id UUID := 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
    user_siti_id UUID := 'b2c3d4e5-f6g7-8901-bcde-f12345678901';
    user_agus_id UUID := 'c3d4e5f6-g7h8-9012-cdef-123456789012';
    user_dewi_id UUID := 'd4e5f6g7-h8i9-0123-defa-234567890123';
    user_indra_id UUID := 'e5f6g7h8-i9j0-1234-efab-345678901234';
    
    -- Recipe UUIDs
    recipe_nasi_goreng_id UUID := 'f6g7h8i9-j0k1-2345-fabc-456789012345';
    recipe_rendang_id UUID := 'g7h8i9j0-k1l2-3456-abcd-567890123456';
    recipe_soto_ayam_id UUID := 'h8i9j0k1-l2m3-4567-bcde-678901234567';
    recipe_martabak_id UUID := 'i9j0k1l2-m3n4-5678-cdef-789012345678';
    recipe_sate_ayam_id UUID := 'j0k1l2m3-n4o5-6789-defa-890123456789';
    recipe_gado_gado_id UUID := 'k1l2m3n4-o5p6-7890-efab-901234567890';
    recipe_bakso_id UUID := 'l2m3n4o5-p6q7-8901-fabc-012345678901';
    recipe_gudeg_id UUID := 'm3n4o5p6-q7r8-9012-abcd-123456789012';
    
    -- Tool UUIDs
    tool_wajan_id UUID := 'n4o5p6q7-r8s9-0123-bcde-234567890123';
    tool_panci_id UUID := 'o5p6q7r8-s9t0-1234-cdef-345678901234';
    tool_pisau_id UUID := 'p6q7r8s9-t0u1-2345-defa-456789012345';
    tool_talenan_id UUID := 'q7r8s9t0-u1v2-3456-efab-567890123456';
    tool_spatula_id UUID := 'r8s9t0u1-v2w3-4567-fabc-678901234567';
    tool_blender_id UUID := 's9t0u1v2-w3x4-5678-abcd-789012345678';
    tool_rice_cooker_id UUID := 't0u1v2w3-x4y5-6789-bcde-890123456789';
    tool_kompor_id UUID := 'u1v2w3x4-y5z6-7890-cdef-901234567890';
    tool_cobek_id UUID := 'v2w3x4y5-z6a7-8901-defa-012345678901';
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
    'Rp 15.000 - 25.000',
    '20 menit',
    '15 menit',
    '35 menit',
    4,
    'mudah',
    'Nasi goreng kampung yang autentik dengan cita rasa Indonesia yang khas. Menggunakan bumbu tradisional dan teknik memasak yang tepat.',
    '{"kalori": 380, "protein": "12g", "karbohidrat": "58g", "lemak": "12g"}'::jsonb,
    'Gunakan nasi yang sudah dingin agar tidak lengket. Tumis bumbu hingga harum sebelum menambahkan nasi.',
    user_budi_id,
    TRUE,
    TRUE
),
(
    recipe_rendang_id,
    'Rendang Daging Sapi',
    'rendang-daging-sapi',
    'https://images.unsplash.com/photo-1562967914-608f82629710?w=400',
    4.8,
    25,
    'Rp 80.000 - 120.000',
    '4 jam',
    '30 menit',
    '4 jam 30 menit',
    6,
    'sulit',
    'Rendang daging sapi Padang yang autentik dengan bumbu lengkap dan proses memasak tradisional. Cita rasa yang kaya dan mendalam.',
    '{"kalori": 520, "protein": "35g", "karbohidrat": "8g", "lemak": "38g"}'::jsonb,
    'Masak dengan sabar dan api kecil. Aduk sesekali agar tidak gosong. Rendang siap ketika berwarna cokelat kehitaman.',
    user_siti_id,
    TRUE,
    TRUE
),
(
    recipe_soto_ayam_id,
    'Soto Ayam Lamongan',
    'soto-ayam-lamongan',
    'https://images.unsplash.com/photo-1505253758473-96b7015fcd40?w=400',
    4.3,
    18,
    'Rp 25.000 - 40.000',
    '1 jam 30 menit',
    '20 menit',
    '1 jam 50 menit',
    4,
    'sedang',
    'Soto ayam khas Lamongan dengan kuah bening yang segar dan bumbu yang harum. Disajikan dengan pelengkap tradisional.',
    '{"kalori": 280, "protein": "25g", "karbohidrat": "15g", "lemak": "15g"}'::jsonb,
    'Rebus ayam hingga empuk dan kaldu benar-benar jernih. Saring kaldu untuk hasil yang optimal.',
    user_agus_id,
    FALSE,
    TRUE
),
(
    recipe_martabak_id,
    'Martabak Manis',
    'martabak-manis',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400',
    4.2,
    8,
    'Rp 20.000 - 35.000',
    '30 menit',
    '45 menit',
    '1 jam 15 menit',
    4,
    'sedang',
    'Martabak manis dengan adonan yang lembut dan topping yang melimpah. Cocok untuk camilan atau hidangan penutup.',
    '{"kalori": 420, "protein": "8g", "karbohidrat": "55g", "lemak": "18g"}'::jsonb,
    'Diamkan adonan minimal 30 menit. Gunakan api kecil agar matang merata.',
    user_dewi_id,
    FALSE,
    TRUE
),
(
    recipe_sate_ayam_id,
    'Sate Ayam Madura',
    'sate-ayam-madura',
    'https://images.unsplash.com/photo-1529563021893-cc83c992d75d?w=400',
    4.6,
    22,
    'Rp 30.000 - 50.000',
    '45 menit',
    '30 menit',
    '1 jam 15 menit',
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
    'Gado-gado khas Jakarta dengan sayuran segar dan bumbu kacang yang creamy. Hidangan sehat dan bergizi.',
    '{"kalori": 220, "protein": "12g", "karbohidrat": "25g", "lemak": "8g"}'::jsonb,
    'Rebus sayuran sesuai tingkat kematangan yang diinginkan. Bumbu kacang sebaiknya tidak terlalu encer.',
    user_siti_id,
    FALSE,
    TRUE
),
(
    recipe_bakso_id,
    'Bakso Malang',
    'bakso-malang',
    'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
    4.7,
    30,
    'Rp 20.000 - 35.000',
    '2 jam',
    '45 menit',
    '2 jam 45 menit',
    4,
    'sulit',
    'Bakso Malang dengan tekstur kenyal dan kuah kaldu yang kaya rasa. Disajikan dengan mie dan pelengkap tradisional.',
    '{"kalori": 320, "protein": "22g", "karbohidrat": "35g", "lemak": "10g"}'::jsonb,
    'Gunakan daging sapi segar. Proses penggilingan yang baik akan menghasilkan tekstur bakso yang kenyal.',
    user_agus_id,
    TRUE,
    TRUE
),
(
    recipe_gudeg_id,
    'Gudeg Yogyakarta',
    'gudeg-yogyakarta',
    'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400',
    4.5,
    20,
    'Rp 35.000 - 55.000',
    '3 jam',
    '30 menit',
    '3 jam 30 menit',
    6,
    'sulit',
    'Gudeg khas Yogyakarta dengan cita rasa manis dan gurih yang khas. Dimasak dengan santan dan gula merah.',
    '{"kalori": 280, "protein": "8g", "karbohidrat": "45g", "lemak": "8g"}'::jsonb,
    'Masak dengan sabar dan api kecil. Aduk sesekali agar santan tidak pecah. Gudeg siap ketika kuah menyusut.',
    user_indra_id,
    FALSE,
    TRUE
)
ON CONFLICT (id) DO NOTHING;

-- Insert recipe category mappings
INSERT INTO recipe_category_mappings (recipe_id, category_id) VALUES 
(recipe_nasi_goreng_id, 1), -- Makanan Utama
(recipe_nasi_goreng_id, 2), -- Nasi
(recipe_rendang_id, 1), -- Makanan Utama
(recipe_rendang_id, 3), -- Daging
(recipe_rendang_id, 4), -- Tradisional
(recipe_soto_ayam_id, 1), -- Makanan Utama
(recipe_soto_ayam_id, 5), -- Sup
(recipe_soto_ayam_id, 6), -- Ayam
(recipe_martabak_id, 7), -- Makanan Penutup
(recipe_martabak_id, 8), -- Kue
(recipe_sate_ayam_id, 1), -- Makanan Utama
(recipe_sate_ayam_id, 6), -- Ayam
(recipe_sate_ayam_id, 9), -- Panggang
(recipe_gado_gado_id, 10), -- Salad
(recipe_gado_gado_id, 11), -- Sayuran
(recipe_bakso_id, 1), -- Makanan Utama
(recipe_bakso_id, 5), -- Sup
(recipe_bakso_id, 3), -- Daging
(recipe_gudeg_id, 1), -- Makanan Utama
(recipe_gudeg_id, 4), -- Tradisional
(recipe_gudeg_id, 11) -- Sayuran
ON CONFLICT (recipe_id, category_id) DO NOTHING;

-- Insert recipe ingredients
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
(recipe_rendang_id, 'Santan kelapa', '1', 'liter', 2),
(recipe_rendang_id, 'Cabai merah keriting', '15', 'buah', 3),
(recipe_rendang_id, 'Bawang merah', '8', 'siung', 4),
(recipe_rendang_id, 'Bawang putih', '6', 'siung', 5),
(recipe_rendang_id, 'Jahe', '3', 'cm', 6),
(recipe_rendang_id, 'Lengkuas', '3', 'cm', 7),
(recipe_rendang_id, 'Kunyit', '2', 'cm', 8),

-- Soto Ayam Lamongan
(recipe_soto_ayam_id, 'Ayam kampung', '1', 'ekor', 1),
(recipe_soto_ayam_id, 'Kunyit', '2', 'cm', 2),
(recipe_soto_ayam_id, 'Jahe', '2', 'cm', 3),
(recipe_soto_ayam_id, 'Daun jeruk', '3', 'lembar', 4),
(recipe_soto_ayam_id, 'Serai', '2', 'batang', 5),
(recipe_soto_ayam_id, 'Bawang goreng', '2', 'sdm', 6),

-- Martabak Manis
(recipe_martabak_id, 'Tepung terigu', '250', 'gram', 1),
(recipe_martabak_id, 'Telur ayam', '2', 'butir', 2),
(recipe_martabak_id, 'Susu cair', '200', 'ml', 3),
(recipe_martabak_id, 'Coklat meses', '100', 'gram', 4),
(recipe_martabak_id, 'Keju parut', '100', 'gram', 5),

-- Sate Ayam Madura
(recipe_sate_ayam_id, 'Daging ayam', '500', 'gram', 1),
(recipe_sate_ayam_id, 'Kacang tanah', '200', 'gram', 2),
(recipe_sate_ayam_id, 'Gula merah', '2', 'sdm', 3),
(recipe_sate_ayam_id, 'Kecap manis', '3', 'sdm', 4),

-- Gado-gado Jakarta
(recipe_gado_gado_id, 'Kacang tanah', '150', 'gram', 1),
(recipe_gado_gado_id, 'Tauge', '100', 'gram', 2),
(recipe_gado_gado_id, 'Bayam', '100', 'gram', 3),
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

-- Insert recipe instructions
INSERT INTO recipe_instructions (recipe_id, step_number, instruction_text) VALUES 
-- Nasi Goreng Kampung
(recipe_nasi_goreng_id, 1, 'Haluskan bawang merah, bawang putih, dan cabai merah.'),
(recipe_nasi_goreng_id, 2, 'Panaskan minyak, tumis bumbu halus hingga harum.'),
(recipe_nasi_goreng_id, 3, 'Masukkan telur, orak-arik hingga matang.'),
(recipe_nasi_goreng_id, 4, 'Tambahkan nasi putih, aduk rata.'),
(recipe_nasi_goreng_id, 5, 'Tuang kecap manis dan garam, aduk hingga merata.'),
(recipe_nasi_goreng_id, 6, 'Sajikan dengan kerupuk dan acar.'),

-- Rendang Daging Sapi
(recipe_rendang_id, 1, 'Potong daging sapi menjadi kotak-kotak.'),
(recipe_rendang_id, 2, 'Haluskan semua bumbu: cabai, bawang merah, bawang putih, jahe, lengkuas, kunyit.'),
(recipe_rendang_id, 3, 'Tumis bumbu halus hingga harum dan berminyak.'),
(recipe_rendang_id, 4, 'Masukkan daging, aduk hingga berubah warna.'),
(recipe_rendang_id, 5, 'Tuang santan, masak dengan api sedang.'),
(recipe_rendang_id, 6, 'Kecilkan api, masak sambil diaduk hingga bumbu meresap (3-4 jam).'),
(recipe_rendang_id, 7, 'Rendang siap disajikan ketika berwarna cokelat kehitaman.'),

-- Soto Ayam Lamongan
(recipe_soto_ayam_id, 1, 'Rebus ayam dengan jahe dan kunyit hingga empuk.'),
(recipe_soto_ayam_id, 2, 'Angkat ayam, suwir-suwir dagingnya.'),
(recipe_soto_ayam_id, 3, 'Saring kaldu ayam.'),
(recipe_soto_ayam_id, 4, 'Tumis bumbu halus, masukkan ke dalam kaldu.'),
(recipe_soto_ayam_id, 5, 'Didihkan kaldu dengan daun jeruk dan serai.'),
(recipe_soto_ayam_id, 6, 'Sajikan dengan ayam suwir, bawang goreng, dan pelengkap.'),

-- Martabak Manis
(recipe_martabak_id, 1, 'Campurkan tepung terigu, telur, dan susu cair.'),
(recipe_martabak_id, 2, 'Aduk hingga adonan licin, diamkan 30 menit.'),
(recipe_martabak_id, 3, 'Panaskan wajan anti lengket dengan sedikit mentega.'),
(recipe_martabak_id, 4, 'Tuang adonan, ratakan membentuk bulat.'),
(recipe_martabak_id, 5, 'Taburi dengan coklat meses dan keju parut.'),
(recipe_martabak_id, 6, 'Lipat menjadi setengah lingkaran, angkat dan sajikan.'),

-- Sate Ayam Madura
(recipe_sate_ayam_id, 1, 'Potong daging ayam kotak-kotak, tusuk dengan tusukan sate.'),
(recipe_sate_ayam_id, 2, 'Bakar sate sambil dibolak-balik hingga matang.'),
(recipe_sate_ayam_id, 3, 'Sangrai kacang tanah, haluskan.'),
(recipe_sate_ayam_id, 4, 'Campurkan kacang halus dengan gula merah, kecap manis, dan air.'),
(recipe_sate_ayam_id, 5, 'Masak bumbu kacang hingga kental.'),
(recipe_sate_ayam_id, 6, 'Sajikan sate dengan bumbu kacang dan lontong.'),

-- Gado-gado Jakarta
(recipe_gado_gado_id, 1, 'Rebus sayuran (bayam, tauge, kentang) secara terpisah.'),
(recipe_gado_gado_id, 2, 'Goreng tahu hingga kecokelatan.'),
(recipe_gado_gado_id, 3, 'Sangrai kacang tanah, haluskan.'),
(recipe_gado_gado_id, 4, 'Campurkan kacang halus dengan gula merah dan air.'),
(recipe_gado_gado_id, 5, 'Masak bumbu kacang hingga kental.'),
(recipe_gado_gado_id, 6, 'Tata sayuran dan tahu, siram dengan bumbu kacang.'),

-- Bakso Malang
(recipe_bakso_id, 1, 'Rebus tulang sapi untuk membuat kaldu, masak 2 jam.'),
(recipe_bakso_id, 2, 'Campurkan daging giling dengan tepung tapioka.'),
(recipe_bakso_id, 3, 'Bentuk adonan daging menjadi bulatan-bulatan.'),
(recipe_bakso_id, 4, 'Rebus bakso dalam air mendidih hingga mengapung.'),
(recipe_bakso_id, 5, 'Rebus mie dan tahu secara terpisah.'),
(recipe_bakso_id, 6, 'Sajikan bakso dengan mie, tahu, dan kaldu panas.'),

-- Gudeg Yogyakarta
(recipe_gudeg_id, 1, 'Bersihkan nangka muda, potong sesuai selera.'),
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
    'Wajan untuk menumis dan menggoreng',
    'peralatan_masak'
),
(
    tool_panci_id,
    'Panci',
    'panci',
    'Pot',
    'Panci untuk merebus dan memasak berkuah',
    'peralatan_masak'
),
(
    tool_pisau_id,
    'Pisau Chef',
    'pisau_chef',
    'Chef Knife',
    'Pisau serbaguna untuk memotong bahan',
    'peralatan_potong'
),
(
    tool_talenan_id,
    'Talenan',
    'talenan',
    'Cutting Board',
    'Alas untuk memotong bahan makanan',
    'peralatan_potong'
),
(
    tool_spatula_id,
    'Spatula',
    'spatula',
    'Spatula',
    'Alat untuk mengaduk dan membalik makanan',
    'peralatan_masak'
),
(
    tool_blender_id,
    'Blender',
    'blender',
    'Blender',
    'Alat untuk menghaluskan bumbu dan bahan',
    'peralatan_elektronik'
),
(
    tool_rice_cooker_id,
    'Rice Cooker',
    'rice_cooker',
    'Rice Cooker',
    'Alat untuk memasak nasi',
    'peralatan_elektronik'
),
(
    tool_kompor_id,
    'Kompor',
    'kompor',
    'Stove',
    'Alat untuk memasak dengan api',
    'peralatan_masak'
),
(
    tool_cobek_id,
    'Cobek',
    'cobek',
    'Mortar and Pestle',
    'Alat tradisional untuk menghaluskan bumbu',
    'peralatan_tradisional'
),
(
    tool_kukusan_id,
    'Kukusan',
    'kukusan',
    'Steamer',
    'Alat untuk mengukus makanan',
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
(recipe_bakso_id, tool_panci_id, TRUE, 'Untuk membuat kaldu dan merebus bakso'),
(recipe_bakso_id, tool_pisau_id, TRUE, 'Untuk memotong bahan'),
(recipe_bakso_id, tool_talenan_id, TRUE, 'Untuk alas memotong'),
(recipe_bakso_id, tool_kompor_id, TRUE, 'Untuk memasak'),

-- Gudeg Yogyakarta
(recipe_gudeg_id, tool_panci_id, TRUE, 'Untuk memasak gudeg'),
(recipe_gudeg_id, tool_pisau_id, TRUE, 'Untuk memotong nangka'),
(recipe_gudeg_id, tool_talenan_id, TRUE, 'Untuk alas memotong'),
(recipe_gudeg_id, tool_kompor_id, TRUE, 'Untuk memasak'),
(recipe_gudeg_id, tool_blender_id, FALSE, 'Untuk menghaluskan bumbu')
ON CONFLICT (recipe_id, tool_id) DO NOTHING;

-- Insert pantry categories
INSERT INTO pantry_categories (name, name_id, name_en, description, icon) VALUES 
('Bumbu Dapur', 'bumbu_dapur', 'Spices', 'Bumbu dan rempah-rempah', 'spice'),
('Sayuran', 'sayuran', 'Vegetables', 'Sayur-sayuran segar', 'vegetable'),
('Daging & Unggas', 'daging_unggas', 'Meat & Poultry', 'Daging dan unggas', 'meat'),
('Ikan & Seafood', 'ikan_seafood', 'Fish & Seafood', 'Ikan dan hasil laut', 'fish'),
('Buah-buahan', 'buah_buahan', 'Fruits', 'Buah-buahan segar', 'fruit'),
('Karbohidrat', 'karbohidrat', 'Carbohydrates', 'Nasi, pasta, roti', 'grain'),
('Susu & Olahan', 'susu_olahan', 'Dairy', 'Susu dan produk olahannya', 'dairy'),
('Minyak & Lemak', 'minyak_lemak', 'Oils & Fats', 'Minyak goreng dan lemak', 'oil'),
('Kacang-kacangan', 'kacang_kacangan', 'Nuts & Legumes', 'Kacang dan biji-bijian', 'nut'),
('Minuman', 'minuman', 'Beverages', 'Minuman dan cairan', 'drink')
ON CONFLICT (name) DO NOTHING;

-- Sample pantry items untuk user Budi
INSERT INTO pantry_items (
    user_id,
    name,
    quantity,
    unit,
    category_id,
    storage_location,
    expiration_date,
    low_stock_alert
) VALUES 
(user_budi_id, 'Beras', '5', 'kg', 6, 'Lemari Dapur', '2025-12-31', FALSE),
(user_budi_id, 'Minyak Goreng', '1', 'liter', 8, 'Lemari Dapur', '2025-08-15', TRUE),
(user_budi_id, 'Bawang Merah', '500', 'gram', 2, 'Kulkas', '2025-07-01', FALSE),
(user_budi_id, 'Bawang Putih', '200', 'gram', 2, 'Kulkas', '2025-07-05', FALSE),
(user_budi_id, 'Kecap Manis', '1', 'botol', 1, 'Lemari Dapur', '2025-10-20', FALSE),
(user_budi_id, 'Telur Ayam', '12', 'butir', 7, 'Kulkas', '2025-06-25', TRUE)
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
    type,
    title,
    message,
    is_read
) VALUES 
(user_budi_id, 'expiration_warning', 'Telur Akan Segera Kedaluwarsa', 'Telur ayam di pantry Anda akan kedaluwarsa dalam 2 hari. Segera gunakan atau konsumsi.', FALSE),
(user_budi_id, 'low_stock', 'Stok Minyak Goreng Menipis', 'Minyak goreng di pantry Anda sudah hampir habis. Jangan lupa untuk membeli lagi.', FALSE),
(user_siti_id, 'recipe_recommendation', 'Resep Baru Untukmu', 'Berdasarkan preferensi Anda, kami merekomendasikan resep "Ayam Bakar Kecap" yang baru ditambahkan.', TRUE),
(user_agus_id, 'system', 'Update Aplikasi', 'Versi terbaru aplikasi Rasain telah tersedia. Update sekarang untuk fitur-fitur terbaru!', FALSE)
ON CONFLICT (id) DO NOTHING;

END $$;

-- Success message
SELECT 'Rasain App Seed Data Restore Completed Successfully!' as status,
       COUNT(*) as total_recipes FROM recipes;
