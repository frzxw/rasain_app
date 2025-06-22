-- Simple migration to add missing columns
-- Run this in Supabase SQL Editor

-- Add missing columns to recipe_ingredients
ALTER TABLE recipe_ingredients 
ADD COLUMN IF NOT EXISTS ingredient_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS amount VARCHAR(100);

-- Add missing column to recipe_instructions
ALTER TABLE recipe_instructions 
ADD COLUMN IF NOT EXISTS timer_minutes INTEGER;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_ingredient_id ON recipe_ingredients(ingredient_id);

-- Verify the changes (optional)
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'recipe_ingredients'
ORDER BY ordinal_position;

SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'recipe_instructions'
ORDER BY ordinal_position;
