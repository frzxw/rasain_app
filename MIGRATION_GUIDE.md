# Fix User Names in Reviews - Migration Guide

## 🔧 Problem Description

Recipe reviews were showing "Pengguna Anonymous" instead of actual user names because:

1. `recipe_reviews` table only had `user_id` but no `user_name` or `user_image_url` columns
2. No foreign key relationship existed between `recipe_reviews` and `user_profiles`
3. Flutter code was hardcoded to use "Pengguna Anonymous"

## ✅ Solution Implemented

### Database Changes (`migration_fix_user_names.sql`)

1. **Added Foreign Key Constraint**

   - Links `recipe_reviews.user_id` → `user_profiles.id`
   - Enables JOIN queries for getting user data

2. **Added User Data Columns**

   - `user_name TEXT` - stores user's display name
   - `user_image_url TEXT` - stores user's avatar URL

3. **Auto-Population Trigger**

   - Automatically fills user data when inserting/updating reviews
   - Ensures data consistency

4. **Data Migration**
   - Populates existing reviews with correct user names
   - Backfills historical data

### Flutter Code Changes (`recipe_service.dart`)

1. **Smart Query Strategy**

   - First tries direct column access (fastest)
   - Falls back to JOIN query if columns don't exist
   - Final fallback to basic query

2. **Improved User Data Processing**
   - Uses direct columns when available
   - Falls back to JOIN data
   - Provides debug logging

## 🚀 How to Run Migration

### Option 1: Using Supabase Dashboard

1. Open your Supabase project dashboard
2. Go to SQL Editor
3. Copy contents of `migration_fix_user_names.sql`
4. Execute the SQL script

### Option 2: Using psql Command Line

```bash
# Connect to your Supabase database
psql "postgresql://[user]:[password]@[host]:[port]/[database]"

# Run the migration
\i migration_fix_user_names.sql
```

### Option 3: Using Supabase CLI

```bash
# If you have Supabase CLI installed
supabase db reset --db-url "your-database-url"
# Then apply the migration
```

## 🧪 Testing After Migration

1. **Run the Flutter App**

   ```bash
   flutter run -d chrome
   ```

2. **Navigate to a Recipe**

   - Click on any recipe to view details
   - Check the Reviews section

3. **Add a New Review**

   - Log in with a user account
   - Add a review and rating
   - Verify the correct username appears

4. **Check Logs**
   Look for these success messages:
   ```
   ✅ Direct column query successful for reviews
   👤 Review user: [Real User Name] (from direct column)
   ```

## 🔍 Verification Queries

After running migration, verify in Supabase SQL Editor:

```sql
-- Check if columns were added
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'recipe_reviews'
AND column_name IN ('user_name', 'user_image_url');

-- Check if foreign key exists
SELECT constraint_name, table_name
FROM information_schema.table_constraints
WHERE table_name = 'recipe_reviews'
AND constraint_type = 'FOREIGN KEY';

-- Test data population
SELECT
    id,
    user_id,
    user_name,
    rating,
    comment,
    created_at
FROM recipe_reviews
LIMIT 5;

-- Test JOIN query (should work now)
SELECT
    rr.id,
    rr.user_name as direct_name,
    up.name as join_name,
    rr.rating,
    rr.comment
FROM recipe_reviews rr
LEFT JOIN user_profiles up ON rr.user_id = up.id
LIMIT 3;
```

## 📱 Expected Results

After migration:

- ✅ New reviews show actual user names
- ✅ Existing reviews get user names populated
- ✅ Performance is improved (no JOIN needed for new data)
- ✅ Backward compatibility maintained
- ✅ No data loss or corruption

## 🔄 Rollback Plan

If needed, you can rollback:

```sql
-- Remove added columns
ALTER TABLE recipe_reviews DROP COLUMN IF EXISTS user_name;
ALTER TABLE recipe_reviews DROP COLUMN IF EXISTS user_image_url;

-- Remove trigger
DROP TRIGGER IF EXISTS populate_review_user_data_trigger ON recipe_reviews;
DROP FUNCTION IF EXISTS populate_review_user_data();

-- Remove foreign key (replace constraint name as needed)
ALTER TABLE recipe_reviews DROP CONSTRAINT IF EXISTS recipe_reviews_user_id_fkey_profiles;
```

## 🎯 Success Criteria

Migration is successful when:

1. ✅ Reviews display actual user names instead of "Pengguna Anonymous"
2. ✅ New reviews automatically get correct user data
3. ✅ No errors in Flutter logs during review loading
4. ✅ Performance is maintained or improved
5. ✅ All existing functionality continues to work

---

**Last Updated:** 2025-06-19  
**Status:** Ready for deployment
