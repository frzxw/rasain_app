-- ========================================
-- Migration Script: Fix User Names in Reviews
-- Purpose: Add foreign key relationship and user name columns
-- Date: 2025-06-19
-- ========================================

-- Step 1: Add foreign key constraint to recipe_reviews -> user_profiles
-- This will enable JOIN queries between recipe_reviews and user_profiles

-- First, ensure user_profiles table exists and has the right structure
-- (This should already exist based on your schema)

-- Add foreign key constraint if it doesn't exist
DO $$ 
BEGIN
    -- Check if foreign key constraint already exists
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.table_constraints 
        WHERE constraint_name = 'recipe_reviews_user_id_fkey_profiles'
        AND table_name = 'recipe_reviews'
        AND constraint_type = 'FOREIGN KEY'
    ) THEN
        -- Add foreign key constraint
        ALTER TABLE recipe_reviews 
        ADD CONSTRAINT recipe_reviews_user_id_fkey_profiles 
        FOREIGN KEY (user_id) REFERENCES user_profiles(id) ON DELETE CASCADE;
        
        RAISE NOTICE 'Added foreign key constraint: recipe_reviews -> user_profiles';
    ELSE
        RAISE NOTICE 'Foreign key constraint already exists: recipe_reviews -> user_profiles';
    END IF;
END $$;

-- Step 2: Alternative approach - Add user_name and user_image_url columns
-- This approach stores denormalized data for better performance

-- Add user_name column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'recipe_reviews' 
        AND column_name = 'user_name'
    ) THEN
        ALTER TABLE recipe_reviews ADD COLUMN user_name TEXT;
        RAISE NOTICE 'Added user_name column to recipe_reviews';
    ELSE
        RAISE NOTICE 'user_name column already exists in recipe_reviews';
    END IF;
END $$;

-- Add user_image_url column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'recipe_reviews' 
        AND column_name = 'user_image_url'
    ) THEN
        ALTER TABLE recipe_reviews ADD COLUMN user_image_url TEXT;
        RAISE NOTICE 'Added user_image_url column to recipe_reviews';
    ELSE
        RAISE NOTICE 'user_image_url column already exists in recipe_reviews';
    END IF;
END $$;

-- Step 3: Populate existing records with user data
-- Update existing recipe_reviews with user names and images from user_profiles

UPDATE recipe_reviews 
SET 
    user_name = up.name,
    user_image_url = up.image_url
FROM user_profiles up 
WHERE recipe_reviews.user_id = up.id 
AND (recipe_reviews.user_name IS NULL OR recipe_reviews.user_name = '');

-- Step 4: Create trigger to automatically populate user data on INSERT/UPDATE
-- This ensures new reviews automatically get user name and image

-- Create or replace the trigger function
CREATE OR REPLACE FUNCTION populate_review_user_data()
RETURNS TRIGGER AS $$
BEGIN
    -- Get user data from user_profiles
    SELECT name, image_url 
    INTO NEW.user_name, NEW.user_image_url
    FROM user_profiles 
    WHERE id = NEW.user_id;
    
    -- Fallback if user profile not found
    IF NEW.user_name IS NULL THEN
        NEW.user_name := 'Pengguna Anonymous';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS populate_review_user_data_trigger ON recipe_reviews;

-- Create the trigger
CREATE TRIGGER populate_review_user_data_trigger
    BEFORE INSERT OR UPDATE ON recipe_reviews
    FOR EACH ROW
    EXECUTE FUNCTION populate_review_user_data();

-- Step 5: Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_recipe_reviews_user_id_profiles 
ON recipe_reviews(user_id);

CREATE INDEX IF NOT EXISTS idx_recipe_reviews_user_name 
ON recipe_reviews(user_name);

-- Step 6: Test the setup with a sample query
-- This query should now work with JOIN or direct column access

-- Test JOIN approach (if foreign key is working)
SELECT 
    rr.id,
    rr.recipe_id,
    rr.rating,
    rr.comment,
    rr.created_at,
    -- From JOIN
    up.name as user_name_from_join,
    up.image_url as user_image_from_join,
    -- From direct columns  
    rr.user_name as user_name_direct,
    rr.user_image_url as user_image_direct
FROM recipe_reviews rr
LEFT JOIN user_profiles up ON rr.user_id = up.id
LIMIT 5;

-- Verification queries
SELECT 'recipe_reviews columns:' as info;
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'recipe_reviews'
ORDER BY ordinal_position;

SELECT 'Foreign key constraints:' as info;
SELECT constraint_name, table_name, constraint_type
FROM information_schema.table_constraints 
WHERE table_name = 'recipe_reviews' 
AND constraint_type = 'FOREIGN KEY';

SELECT 'Sample data check:' as info;
SELECT id, user_id, user_name, rating, comment
FROM recipe_reviews 
LIMIT 3;

-- Success message
SELECT '✅ Migration completed successfully! Recipe reviews should now display correct user names.' as result;
