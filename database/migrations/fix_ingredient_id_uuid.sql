-- Fix ingredient_id column type and update categories
-- Run this in Supabase SQL Editor

-- 1. Drop and recreate ingredient_id column as UUID with auto-generation
ALTER TABLE recipe_ingredients DROP COLUMN IF EXISTS ingredient_id;
ALTER TABLE recipe_ingredients ADD COLUMN ingredient_id UUID DEFAULT uuid_generate_v4();

-- 2. Recreate index for ingredient_id
DROP INDEX IF EXISTS idx_recipe_ingredients_ingredient_id;
CREATE INDEX idx_recipe_ingredients_ingredient_id ON recipe_ingredients(ingredient_id);

-- 3. Verify recipe_categories table exists and has data
SELECT COUNT(*) as category_count FROM recipe_categories;

-- 4. If no categories exist, insert default ones
INSERT INTO recipe_categories (name, description) VALUES
('Makanan Utama', 'Hidangan utama untuk makan siang dan malam'),
('Appetizer', 'Hidangan pembuka sebelum makanan utama'),
('Dessert', 'Hidangan penutup dan makanan manis'),
('Minuman', 'Berbagai jenis minuman segar dan hangat'),
('Snack', 'Camilan dan makanan ringan'),
('Tradisional', 'Masakan tradisional Indonesia')
ON CONFLICT (name) DO NOTHING;

-- 5. Verify the changes
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'recipe_ingredients' AND column_name = 'ingredient_id';

SELECT name FROM recipe_categories ORDER BY name;
