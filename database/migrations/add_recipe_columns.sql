-- Migration: Add missing columns to recipes table
-- Date: 2025-06-22
-- Description: Add difficulty_level, nutrition_info, and tips columns to recipes table

-- Add difficulty_level column (enum: mudah, sedang, sulit)
ALTER TABLE recipes ADD COLUMN difficulty_level VARCHAR(20) DEFAULT 'sedang' CHECK (difficulty_level IN ('mudah', 'sedang', 'sulit'));

-- Add nutrition_info column (JSON format for flexibility)
ALTER TABLE recipes ADD COLUMN nutrition_info JSONB DEFAULT '{}';

-- Add tips column (text for cooking tips)
ALTER TABLE recipes ADD COLUMN tips TEXT;

-- Add indexes for new columns
CREATE INDEX idx_recipes_difficulty_level ON recipes(difficulty_level);
CREATE INDEX idx_recipes_nutrition_info ON recipes USING GIN(nutrition_info);

-- Update existing recipes to have default difficulty level
UPDATE recipes SET difficulty_level = 'sedang' WHERE difficulty_level IS NULL;

COMMENT ON COLUMN recipes.difficulty_level IS 'Recipe difficulty: mudah (easy), sedang (medium), or sulit (hard)';
COMMENT ON COLUMN recipes.nutrition_info IS 'Recipe nutrition information in JSON format (calories, protein, carbs, fat, etc.)';
COMMENT ON COLUMN recipes.tips IS 'Cooking tips and additional information for the recipe';
