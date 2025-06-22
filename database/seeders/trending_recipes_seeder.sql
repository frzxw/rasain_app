-- Seed data untuk resep trending/populer
-- File: database/seeders/trending_recipes_seeder.sql

-- Insert trending/popular recipes dengan rating tinggi
INSERT INTO recipes (
    id,
    name,
    slug,
    description,
    image_url,
    rating,
    review_count,
    cook_time,
    servings,
    tingkat_kesulitan,
    is_featured,
    created_by,
    categories
) VALUES 
-- Resep trending 1
(
    uuid_generate_v4(),
    'Nasi Goreng Spesial',
    'nasi-goreng-spesial',
    'Nasi goreng dengan bumbu rahasia yang menggugah selera, dilengkapi telur mata sapi dan kerupuk.',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=500',
    4.8,
    127,
    25,
    4,
    'mudah',
    true,
    null,
    ARRAY['Makanan Utama', 'Nasi', 'Praktis']
),
-- Resep trending 2
(
    uuid_generate_v4(),
    'Rendang Daging Sapi',
    'rendang-daging-sapi',
    'Rendang autentik Padang dengan daging sapi empuk dan bumbu rempah yang kaya.',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
    4.9,
    89,
    180,
    6,
    'sulit',
    true,
    null,
    ARRAY['Makanan Utama', 'Daging', 'Tradisional']
),
-- Resep trending 3
(
    uuid_generate_v4(),
    'Ayam Geprek Crispy',
    'ayam-geprek-crispy',
    'Ayam goreng crispy yang dipukul dengan sambal pedas manis yang nagih.',
    'https://images.unsplash.com/photo-1569058242252-92bd747b5c1e?w=500',
    4.7,
    156,
    35,
    3,
    'mudah',
    true,
    null,
    ARRAY['Makanan Utama', 'Ayam', 'Pedas']
),
-- Resep trending 4
(
    uuid_generate_v4(),
    'Soto Ayam Lamongan',
    'soto-ayam-lamongan',
    'Soto ayam khas Lamongan dengan kuah bening segar dan taburan kerupuk.',
    'https://images.unsplash.com/photo-1547592180-85f173990554?w=500',
    4.6,
    93,
    45,
    4,
    'sedang',
    true,
    null,
    ARRAY['Sup', 'Ayam', 'Tradisional']
),
-- Resep trending 5
(
    uuid_generate_v4(),
    'Gado-Gado Jakarta',
    'gado-gado-jakarta',
    'Gado-gado segar dengan sayuran rebus, tempe, tahu, dan bumbu kacang.',
    'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500',
    4.5,
    78,
    20,
    3,
    'mudah',
    true,
    null,
    ARRAY['Salad', 'Vegetarian', 'Sehat']
),
-- Resep trending 6
(
    uuid_generate_v4(),
    'Bakso Malang',
    'bakso-malang',
    'Bakso khas Malang dengan berbagai macam bakso dan mie kuning.',
    'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500',
    4.8,
    134,
    40,
    5,
    'sedang',
    true,
    null,
    ARRAY['Sup', 'Daging', 'Comfort Food']
),
-- Resep trending 7
(
    uuid_generate_v4(),
    'Es Cendol Durian',
    'es-cendol-durian',
    'Minuman segar es cendol dengan santan dan durian yang creamy.',
    'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=500',
    4.4,
    67,
    15,
    2,
    'mudah',
    true,
    null,
    ARRAY['Minuman', 'Dessert', 'Dingin']
),
-- Resep trending 8
(
    uuid_generate_v4(),
    'Gudeg Yogya',
    'gudeg-yogya',
    'Gudeg manis khas Yogyakarta dengan nangka muda dan ayam kampung.',
    'https://images.unsplash.com/photo-1565299585323-38174c264975?w=500',
    4.7,
    98,
    120,
    4,
    'sedang',
    true,
    null,
    ARRAY['Makanan Utama', 'Tradisional', 'Manis']
);

-- Insert ingredients untuk setiap resep (contoh untuk Nasi Goreng)
INSERT INTO recipe_ingredients (recipe_id, ingredient_name, quantity, unit, order_index)
SELECT 
    r.id,
    ingredient_name,
    quantity,
    unit,
    order_index
FROM recipes r,
(VALUES
    ('Nasi putih', '3', 'piring', 1),
    ('Telur ayam', '2', 'butir', 2),
    ('Bawang merah', '3', 'siung', 3),
    ('Bawang putih', '2', 'siung', 4),
    ('Kecap manis', '2', 'sdm', 5),
    ('Minyak goreng', '3', 'sdm', 6),
    ('Garam', '1', 'sdt', 7),
    ('Merica bubuk', '1/2', 'sdt', 8)
) AS ingredients(ingredient_name, quantity, unit, order_index)
WHERE r.slug = 'nasi-goreng-spesial';

-- Insert instructions untuk Nasi Goreng
INSERT INTO recipe_instructions (recipe_id, step_number, instruction_text)
SELECT 
    r.id,
    step_number,
    instruction_text
FROM recipes r,
(VALUES
    (1, 'Panaskan minyak goreng dalam wajan besar.'),
    (2, 'Tumis bawang merah dan bawang putih hingga harum.'),
    (3, 'Masukkan telur, orak-arik hingga matang.'),
    (4, 'Tambahkan nasi putih, aduk rata dengan bumbu.'),
    (5, 'Tuang kecap manis, garam, dan merica. Aduk hingga tercampur rata.'),
    (6, 'Masak hingga nasi terlihat kering dan bumbu meresap.'),
    (7, 'Angkat dan sajikan dengan kerupuk dan acar.')
) AS instructions(step_number, instruction_text)
WHERE r.slug = 'nasi-goreng-spesial';

-- Tambahkan review untuk membuat resep ini trending
INSERT INTO recipe_reviews (recipe_id, user_id, rating, comment)
SELECT 
    r.id,
    auth.uid(),
    rating,
    comment
FROM recipes r,
(VALUES
    (5.0, 'Enak banget! Bumbu meresap sempurna.'),
    (4.5, 'Resep yang mudah diikuti, hasilnya lezat.'),
    (5.0, 'Jadi langganan keluarga nih resep ini.'),
    (4.8, 'Nasi goreng terenak yang pernah saya buat!'),
    (4.9, 'Perfect! Akan saya buat lagi.')
) AS reviews(rating, comment)
WHERE r.slug = 'nasi-goreng-spesial'
AND auth.uid() IS NOT NULL;

-- Update recipe stats (ini akan otomatis ter-trigger oleh database functions)
-- Tapi kita bisa manual update juga untuk memastikan
UPDATE recipes 
SET 
    rating = (SELECT AVG(rating) FROM recipe_reviews WHERE recipe_id = recipes.id),
    review_count = (SELECT COUNT(*) FROM recipe_reviews WHERE recipe_id = recipes.id)
WHERE slug IN ('nasi-goreng-spesial', 'rendang-daging-sapi', 'ayam-geprek-crispy', 
               'soto-ayam-lamongan', 'gado-gado-jakarta', 'bakso-malang', 
               'es-cendol-durian', 'gudeg-yogya');
