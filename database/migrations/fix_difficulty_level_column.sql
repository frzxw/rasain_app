-- Migration: Fix difficulty level column inconsistency
-- Date: 2025-06-22
-- Description: Standardize difficulty level column to use difficulty_level with Indonesian values

-- First, check if tingkat_kesulitan column exists and drop it
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'recipes' AND column_name = 'tingkat_kesulitan') THEN
        
        -- If there's existing data in tingkat_kesulitan, migrate it to difficulty_level
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'recipes' AND column_name = 'difficulty_level') THEN
            -- Add difficulty_level column first
            ALTER TABLE recipes ADD COLUMN difficulty_level VARCHAR(20);
        END IF;
        
        -- Migrate data from tingkat_kesulitan to difficulty_level
        UPDATE recipes SET difficulty_level = tingkat_kesulitan WHERE tingkat_kesulitan IS NOT NULL;
        
        -- Drop the old column
        ALTER TABLE recipes DROP COLUMN tingkat_kesulitan;
    END IF;
END $$;

-- Ensure difficulty_level column exists with proper constraints
DO $$
BEGIN
    -- Add difficulty_level column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'recipes' AND column_name = 'difficulty_level') THEN
        ALTER TABLE recipes ADD COLUMN difficulty_level VARCHAR(20);
    END IF;
    
    -- Drop existing constraint if it exists
    IF EXISTS (SELECT 1 FROM information_schema.table_constraints 
               WHERE table_name = 'recipes' AND constraint_name = 'recipes_difficulty_level_check') THEN
        ALTER TABLE recipes DROP CONSTRAINT recipes_difficulty_level_check;
    END IF;
    
    -- Add the correct constraint with Indonesian values
    ALTER TABLE recipes ADD CONSTRAINT recipes_difficulty_level_check 
        CHECK (difficulty_level IN ('mudah', 'sedang', 'sulit'));
    
    -- Set default value for existing NULL records
    UPDATE recipes SET difficulty_level = 'sedang' WHERE difficulty_level IS NULL;
    
    -- Set default for new records
    ALTER TABLE recipes ALTER COLUMN difficulty_level SET DEFAULT 'sedang';
END $$;

-- Create index for difficulty_level if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_recipes_difficulty_level ON recipes(difficulty_level);

-- Drop old index if it exists
DROP INDEX IF EXISTS idx_recipes_difficulty;

-- Add comments
COMMENT ON COLUMN recipes.difficulty_level IS 'Recipe difficulty: mudah (easy), sedang (medium), or sulit (hard)';
