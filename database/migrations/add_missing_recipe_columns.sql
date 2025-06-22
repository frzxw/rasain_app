-- Add missing columns to recipe_ingredients and recipe_instructions tables
-- This migration addresses the issue where form fields are not properly mapped to database columns

-- ========================================
-- Update recipe_ingredients table
-- ========================================

-- Add missing columns to recipe_ingredients
ALTER TABLE recipe_ingredients 
ADD COLUMN IF NOT EXISTS ingredient_id UUID DEFAULT uuid_generate_v4(),
ADD COLUMN IF NOT EXISTS amount VARCHAR(100);

-- Create index for ingredient_id for better performance
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_ingredient_id ON recipe_ingredients(ingredient_id);

-- Add comments to clarify column purposes
COMMENT ON COLUMN recipe_ingredients.ingredient_id IS 'Unique identifier for the ingredient (auto-generated from ingredient name)';
COMMENT ON COLUMN recipe_ingredients.amount IS 'Total amount combining quantity and unit (e.g., "2 cups", "500g")';
COMMENT ON COLUMN recipe_ingredients.quantity IS 'Numeric quantity (e.g., "2", "500")';
COMMENT ON COLUMN recipe_ingredients.unit IS 'Unit of measurement (e.g., "cups", "g", "ml")';
COMMENT ON COLUMN recipe_ingredients.notes IS 'Additional notes for preparation (e.g., "chopped", "to taste")';

-- ========================================
-- Update recipe_instructions table  
-- ========================================

-- Add missing timer_minutes column to recipe_instructions
ALTER TABLE recipe_instructions 
ADD COLUMN IF NOT EXISTS timer_minutes INTEGER;

-- Add comment to clarify column purpose
COMMENT ON COLUMN recipe_instructions.timer_minutes IS 'Optional timer duration in minutes for cooking steps';
COMMENT ON COLUMN recipe_instructions.image_url IS 'URL of step-by-step image uploaded to recipeimages bucket';

-- ========================================
-- Storage bucket for recipe instruction images
-- ========================================

-- Create storage bucket for recipe instruction images (if it doesn't exist)
-- Note: This should be done through Supabase Dashboard Storage section
-- Bucket name: recipeimages
-- Public: true
-- File size limit: 5MB
-- Allowed MIME types: image/jpeg, image/png, image/webp

-- Alternative: Create bucket via SQL (use this if the above doesn't work)
-- INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
-- VALUES (
--     'recipeimages', 
--     'recipeimages', 
--     true, 
--     5242880, -- 5MB limit
--     ARRAY['image/jpeg', 'image/png', 'image/webp']::text[]
-- ) ON CONFLICT (id) DO NOTHING;

-- Note: For storage policies, please create them manually in Supabase Dashboard:
-- 1. Go to Storage > Policies
-- 2. Create policy for uploads: Authenticated users can upload
-- 3. Create policy for viewing: Anyone can view

-- ========================================
-- Verification queries (uncomment to test)
-- ========================================

-- Verify the changes
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'recipe_ingredients'
ORDER BY ordinal_position;

SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'recipe_instructions'
ORDER BY ordinal_position;

-- SELECT * FROM storage.buckets WHERE id = 'recipeimages';
