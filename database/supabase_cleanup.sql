-- ========================================
-- Rasain App - Supabase Database Cleanup
-- ⚠️  WARNING: This will delete ALL data in the database!
-- ========================================

-- This script completely cleans the database before running the seeder
-- Use this if you want to start fresh or if you're getting duplicate key errors

-- Disable foreign key checks temporarily (if needed)
-- Note: Supabase/PostgreSQL doesn't have this feature, so we use CASCADE

-- Clean up all tables in correct order (respecting foreign key constraints)
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

-- Clean up auth.users (only test users)
DELETE FROM auth.users WHERE email IN (
    'budi.santoso@email.com',
    'siti.rahayu@email.com',
    'agus.wijaya@email.com',
    'dewi.lestari@email.com',
    'indra.pratama@email.com'
);

-- Reset sequences (if any)
-- Note: UUIDs don't use sequences, but included for completeness

-- Success message
SELECT 'Database cleanup completed successfully! You can now run the seeder.' as result;
