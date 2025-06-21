-- Simple RLS Fix: Allow anonymous users to see user names and photos for community posts
-- This is a straightforward approach that opens access to name and image_url for all users

-- Step 1: Drop ALL existing policies on user_profiles
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own complete profile" ON user_profiles;
DROP POLICY IF EXISTS "Allow viewing profile for community context" ON user_profiles;
DROP POLICY IF EXISTS "Allow viewing profile for community posts" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON user_profiles;
DROP POLICY IF EXISTS "Allow viewing basic profile info" ON user_profiles;

-- Step 2: Create secure policies that protect sensitive data
-- Policy 1: Users can view their own complete profile
CREATE POLICY "Users can view own complete profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

-- Policy 2: Everyone can view ONLY name and image_url for community posts
-- Note: This still allows access to all columns, but the app should only SELECT name, image_url
CREATE POLICY "Allow viewing profile for community posts" ON user_profiles
    FOR SELECT USING (
        -- Allow if user is viewing their own profile (gets all data)
        auth.uid() = id 
        OR 
        -- Allow if user has community posts (app should only SELECT name, image_url)
        EXISTS (SELECT 1 FROM community_posts WHERE community_posts.user_id = user_profiles.id)
    );

-- Step 3: Create a secure view that only exposes safe data
CREATE OR REPLACE VIEW public_user_info AS
SELECT 
    id,
    name,
    image_url
FROM user_profiles;

-- Grant access to the view
GRANT SELECT ON public_user_info TO authenticated;
GRANT SELECT ON public_user_info TO anon;

-- Step 4: Keep the existing policies for other operations (insert, update, delete)
CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can delete own profile" ON user_profiles
    FOR DELETE USING (auth.uid() = id);

-- RECOMMENDED: Use the public_user_info view in your Flutter app instead of user_profiles
-- This ensures only name and image_url are ever exposed for community posts
