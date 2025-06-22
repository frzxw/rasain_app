-- ========================================
-- Fix for Like Count and Comment Count Issues
-- Run this in Supabase SQL Editor to ensure triggers work correctly
-- ========================================

-- First, ensure the post_likes table exists with proper structure
CREATE TABLE IF NOT EXISTS post_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, post_id)
);

-- Ensure the post_comments table exists with proper structure
CREATE TABLE IF NOT EXISTS post_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES post_comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ensure community_posts has both like_count and comment_count columns
ALTER TABLE community_posts ADD COLUMN IF NOT EXISTS like_count INTEGER DEFAULT 0;
ALTER TABLE community_posts ADD COLUMN IF NOT EXISTS comment_count INTEGER DEFAULT 0;

-- Enable RLS
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS update_post_like_count_after_like_insert ON post_likes;
DROP TRIGGER IF EXISTS update_post_like_count_after_like_delete ON post_likes;
DROP TRIGGER IF EXISTS update_post_comment_count_after_comment_insert ON post_comments;
DROP TRIGGER IF EXISTS update_post_comment_count_after_comment_delete ON post_comments;
DROP FUNCTION IF EXISTS update_post_like_count();
DROP FUNCTION IF EXISTS update_post_comment_count();

-- Create the function to update like count
CREATE OR REPLACE FUNCTION update_post_like_count()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the like_count in community_posts table
    UPDATE community_posts 
    SET like_count = (
        SELECT COUNT(*) 
        FROM post_likes 
        WHERE post_id = COALESCE(NEW.post_id, OLD.post_id)
    )
    WHERE id = COALESCE(NEW.post_id, OLD.post_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- Create the function to update comment count
CREATE OR REPLACE FUNCTION update_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the comment_count in community_posts table
    UPDATE community_posts 
    SET comment_count = (
        SELECT COUNT(*) 
        FROM post_comments 
        WHERE post_id = COALESCE(NEW.post_id, OLD.post_id)
    )
    WHERE id = COALESCE(NEW.post_id, OLD.post_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- Create triggers for post like count updates
CREATE TRIGGER update_post_like_count_after_like_insert
    AFTER INSERT ON post_likes
    FOR EACH ROW EXECUTE FUNCTION update_post_like_count();

CREATE TRIGGER update_post_like_count_after_like_delete
    AFTER DELETE ON post_likes
    FOR EACH ROW EXECUTE FUNCTION update_post_like_count();

-- Create triggers for post comment count updates
CREATE TRIGGER update_post_comment_count_after_comment_insert
    AFTER INSERT ON post_comments
    FOR EACH ROW EXECUTE FUNCTION update_post_comment_count();

CREATE TRIGGER update_post_comment_count_after_comment_delete
    AFTER DELETE ON post_comments
    FOR EACH ROW EXECUTE FUNCTION update_post_comment_count();

-- Fix existing like counts (run once to synchronize existing data)
UPDATE community_posts 
SET like_count = (
    SELECT COUNT(*) 
    FROM post_likes 
    WHERE post_likes.post_id = community_posts.id
);

-- Fix existing comment counts (run once to synchronize existing data)
UPDATE community_posts 
SET comment_count = (
    SELECT COUNT(*) 
    FROM post_comments 
    WHERE post_comments.post_id = community_posts.id
);

-- RLS Policies for post_likes
DROP POLICY IF EXISTS "Anyone can view post likes" ON post_likes;
DROP POLICY IF EXISTS "Users can like posts" ON post_likes;
DROP POLICY IF EXISTS "Users can unlike posts" ON post_likes;

CREATE POLICY "Anyone can view post likes" ON post_likes
    FOR SELECT USING (true);

CREATE POLICY "Users can like posts" ON post_likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike posts" ON post_likes
    FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for post_comments
DROP POLICY IF EXISTS "Anyone can view post comments" ON post_comments;
DROP POLICY IF EXISTS "Authenticated users can create comments" ON post_comments;
DROP POLICY IF EXISTS "Users can update own comments" ON post_comments;
DROP POLICY IF EXISTS "Users can delete own comments" ON post_comments;

CREATE POLICY "Anyone can view post comments" ON post_comments
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create comments" ON post_comments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments" ON post_comments
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments" ON post_comments
    FOR DELETE USING (auth.uid() = user_id);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_post_likes_post_id ON post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_user_id ON post_likes(user_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_user_post ON post_likes(user_id, post_id);

CREATE INDEX IF NOT EXISTS idx_post_comments_post_id ON post_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_post_comments_user_id ON post_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_post_comments_parent_id ON post_comments(parent_comment_id);

-- Test the triggers (optional - you can run this to verify)
-- INSERT INTO post_likes (user_id, post_id) VALUES (auth.uid(), 'some-post-id');
-- DELETE FROM post_likes WHERE user_id = auth.uid() AND post_id = 'some-post-id';
-- INSERT INTO post_comments (user_id, post_id, content) VALUES (auth.uid(), 'some-post-id', 'Test comment');
-- DELETE FROM post_comments WHERE user_id = auth.uid() AND post_id = 'some-post-id';

COMMIT;
