# How to Run the Migration

## Step 1: Access Supabase SQL Editor

1. Go to your Supabase project dashboard at [https://supabase.com](https://supabase.com)
2. Select your project
3. Navigate to **SQL Editor** in the left sidebar
4. Click **New Query**

## Step 2: Run the Migration

1. Copy the entire contents of `migration_fix_user_names.sql`
2. Paste it into the SQL Editor
3. Click **Run** to execute the migration

## Step 3: Verify the Migration

After running the migration, you should see output messages like:

- ✅ "Added foreign key constraint: recipe_reviews -> user_profiles"
- ✅ "Added user_name column to recipe_reviews"
- ✅ "Added user_image_url column to recipe_reviews"
- ✅ "Migration completed successfully! Recipe reviews should now display correct user names."

## Step 4: Test the App

1. Run your Flutter app
2. Log in with a user account
3. Navigate to a recipe page
4. Post a new review
5. Verify that:
   - New reviews show the correct user name and avatar
   - Existing reviews now show correct user names (after refresh)

## Troubleshooting

If you encounter any errors:

1. **Foreign key constraint fails**: Your `user_profiles` table might be missing. Check if it exists.
2. **Column already exists**: The migration is safe to run multiple times - it will skip existing columns.
3. **Permission denied**: Make sure you're running this as a database admin/owner.

## Rollback (if needed)

If you need to rollback the changes:

```sql
-- Remove the columns (this will lose the user name data)
ALTER TABLE recipe_reviews DROP COLUMN IF EXISTS user_name;
ALTER TABLE recipe_reviews DROP COLUMN IF EXISTS user_image_url;

-- Remove the foreign key constraint
ALTER TABLE recipe_reviews DROP CONSTRAINT IF EXISTS recipe_reviews_user_id_fkey_profiles;

-- Remove the trigger
DROP TRIGGER IF EXISTS populate_review_user_data_trigger ON recipe_reviews;
DROP FUNCTION IF EXISTS populate_review_user_data();
```

## Next Steps

After running the migration successfully, your reviews should display the correct user names and avatars immediately in the app.
