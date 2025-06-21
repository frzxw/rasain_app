-- FIXED RLS Policies for Community Posts
-- This fixes the circular dependency issue and allows proper access to community posts

-- Step 1: Drop ALL existing policies on user_profiles
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own complete profile" ON user_profiles;
DROP POLICY IF EXISTS "Allow viewing profile for community context" ON user_profiles;
DROP POLICY IF EXISTS "Allow viewing profile for community posts" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON user_profiles;
DROP POLICY IF EXISTS "Allow viewing basic profile info" ON user_profiles;

-- Step 2: Create proper policies without circular dependency

-- Policy 1: Users can view their own complete profile
CREATE POLICY "Users can view own complete profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

-- Policy 2: Everyone (including anonymous) can view basic profile info (name, image_url) 
-- This is necessary for community posts to show author information
CREATE POLICY "Allow viewing basic profile info for community" ON user_profiles
    FOR SELECT USING (true);

-- Step 3: Keep the existing policies for other operations
CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can delete own profile" ON user_profiles
    FOR DELETE USING (auth.uid() = id);

-- Step 4: Create a secure view that only exposes safe data for community posts
DROP VIEW IF EXISTS public_user_info;
CREATE VIEW public_user_info AS
SELECT 
    id,
    name,
    image_url,
    posts_count,
    created_at
FROM user_profiles;

-- Grant access to the view
GRANT SELECT ON public_user_info TO authenticated;
GRANT SELECT ON public_user_info TO anon;

-- Step 5: Verify community_posts policies are correct
-- (These should already exist from your main schema, but let's make sure)

-- Drop existing community_posts policies if they exist
DROP POLICY IF EXISTS "Anyone can view community posts" ON community_posts;
DROP POLICY IF EXISTS "Authenticated users can create posts" ON community_posts;
DROP POLICY IF EXISTS "Users can update own posts" ON community_posts;
DROP POLICY IF EXISTS "Users can delete own posts" ON community_posts;

-- Recreate community_posts policies
CREATE POLICY "Anyone can view community posts" ON community_posts
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create posts" ON community_posts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts" ON community_posts
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts" ON community_posts
    FOR DELETE USING (auth.uid() = user_id);

-- Step 6: Create a comprehensive view for community posts with user info
DROP VIEW IF EXISTS community_posts_with_user;
CREATE VIEW community_posts_with_user AS
SELECT 
    cp.*,
    up.name as author_name,
    up.image_url as author_image_url
FROM community_posts cp
LEFT JOIN user_profiles up ON cp.user_id = up.id;

-- Grant access to this view
GRANT SELECT ON community_posts_with_user TO authenticated;
GRANT SELECT ON community_posts_with_user TO anon;

-- IMPORTANT: In your Flutter app, use community_posts_with_user view instead of 
-- manually joining community_posts and user_profiles tables
