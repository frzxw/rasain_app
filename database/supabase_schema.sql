-- ========================================
-- Rasain App - Supabase Database Schema
-- Generated from Flutter Dart models
-- Optimized for Supabase with RLS and Auth
-- ========================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- Custom Types (Enums)
-- ========================================
CREATE TYPE message_type AS ENUM ('text', 'image');
CREATE TYPE message_sender AS ENUM ('user', 'ai');
CREATE TYPE notification_type AS ENUM (
    'recipeRecommendation', 
    'expirationWarning', 
    'lowStock', 
    'newRecipe', 
    'review', 
    'achievement', 
    'system'
);

-- ========================================
-- User Profiles Table (extends auth.users)
-- ========================================
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    image_url TEXT,
    saved_recipes_count INTEGER DEFAULT 0,
    posts_count INTEGER DEFAULT 0,
    is_notifications_enabled BOOLEAN DEFAULT TRUE,
    language VARCHAR(10) DEFAULT 'en',
    is_dark_mode_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_profiles
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Indexes for user_profiles
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
CREATE INDEX idx_user_profiles_name ON user_profiles(name);

-- ========================================
-- Recipes Table
-- ========================================
CREATE TABLE recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    image_url TEXT,
    rating DECIMAL(3,2) DEFAULT 0.00,
    review_count INTEGER DEFAULT 0,
    estimated_cost VARCHAR(100),
    cook_time VARCHAR(100),
    servings INTEGER,
    description TEXT,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

-- RLS Policies for recipes (public read, authenticated create/update)
CREATE POLICY "Anyone can view recipes" ON recipes
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create recipes" ON recipes
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Users can update own recipes" ON recipes
    FOR UPDATE USING (auth.uid() = created_by);

-- Indexes for recipes
CREATE INDEX idx_recipes_name ON recipes(name);
CREATE INDEX idx_recipes_slug ON recipes(slug);
CREATE INDEX idx_recipes_rating ON recipes(rating);
CREATE INDEX idx_recipes_cook_time ON recipes(cook_time);
CREATE INDEX idx_recipes_servings ON recipes(servings);
CREATE INDEX idx_recipes_created_by ON recipes(created_by);

-- ========================================
-- Recipe Categories Table
-- ========================================
CREATE TABLE recipe_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    category VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE recipe_categories ENABLE ROW LEVEL SECURITY;

-- RLS Policies for recipe_categories
CREATE POLICY "Anyone can view recipe categories" ON recipe_categories
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can manage recipe categories" ON recipe_categories
    FOR ALL USING (auth.role() = 'authenticated');

-- Indexes for recipe_categories
CREATE INDEX idx_recipe_categories_recipe_category ON recipe_categories(recipe_id, category);
CREATE INDEX idx_recipe_categories_category ON recipe_categories(category);

-- ========================================
-- Recipe Ingredients Table
-- ========================================
CREATE TABLE recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    ingredient_name VARCHAR(255) NOT NULL,
    quantity VARCHAR(100),
    unit VARCHAR(50),
    notes TEXT,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE recipe_ingredients ENABLE ROW LEVEL SECURITY;

-- RLS Policies for recipe_ingredients
CREATE POLICY "Anyone can view recipe ingredients" ON recipe_ingredients
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can manage recipe ingredients" ON recipe_ingredients
    FOR ALL USING (auth.role() = 'authenticated');

-- Indexes for recipe_ingredients
CREATE INDEX idx_recipe_ingredients_recipe_id ON recipe_ingredients(recipe_id);
CREATE INDEX idx_recipe_ingredients_name ON recipe_ingredients(ingredient_name);
CREATE INDEX idx_recipe_ingredients_order ON recipe_ingredients(recipe_id, order_index);

-- ========================================
-- Recipe Instructions Table
-- ========================================
CREATE TABLE recipe_instructions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    step_number INTEGER NOT NULL,
    instruction_text TEXT NOT NULL,
    video_url TEXT,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT unique_recipe_step UNIQUE (recipe_id, step_number)
);

-- Enable RLS
ALTER TABLE recipe_instructions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for recipe_instructions
CREATE POLICY "Anyone can view recipe instructions" ON recipe_instructions
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can manage recipe instructions" ON recipe_instructions
    FOR ALL USING (auth.role() = 'authenticated');

-- Indexes for recipe_instructions
CREATE INDEX idx_recipe_instructions_recipe_steps ON recipe_instructions(recipe_id, step_number);

-- ========================================
-- Pantry Items Table
-- ========================================
CREATE TABLE pantry_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    image_url TEXT,
    quantity VARCHAR(100),
    expiration_date DATE,
    price VARCHAR(100),
    unit VARCHAR(50),
    category VARCHAR(100),
    storage_location VARCHAR(255),
    total_quantity INTEGER,
    low_stock_alert BOOLEAN DEFAULT FALSE,
    expiration_alert BOOLEAN DEFAULT FALSE,
    purchase_date DATE,
    last_used_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE pantry_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies for pantry_items
CREATE POLICY "Users can view own pantry items" ON pantry_items
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own pantry items" ON pantry_items
    FOR ALL USING (auth.uid() = user_id);

-- Indexes for pantry_items
CREATE INDEX idx_pantry_items_user_id ON pantry_items(user_id);
CREATE INDEX idx_pantry_items_name ON pantry_items(name);
CREATE INDEX idx_pantry_items_category ON pantry_items(category);
CREATE INDEX idx_pantry_items_expiration ON pantry_items(expiration_date);
CREATE INDEX idx_pantry_items_storage_location ON pantry_items(storage_location);

-- ========================================
-- Community Posts Table
-- ========================================
CREATE TABLE community_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name VARCHAR(255) NOT NULL,
    user_image_url TEXT,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    content TEXT,
    image_url TEXT,
    category VARCHAR(100),
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;

-- RLS Policies for community_posts
CREATE POLICY "Anyone can view community posts" ON community_posts
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create posts" ON community_posts
    FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = user_id);

CREATE POLICY "Users can update own posts" ON community_posts
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts" ON community_posts
    FOR DELETE USING (auth.uid() = user_id);

-- Indexes for community_posts
CREATE INDEX idx_community_posts_user_id ON community_posts(user_id);
CREATE INDEX idx_community_posts_timestamp ON community_posts(timestamp);
CREATE INDEX idx_community_posts_category ON community_posts(category);
CREATE INDEX idx_community_posts_like_count ON community_posts(like_count);

-- ========================================
-- Community Post Tagged Ingredients Table
-- ========================================
CREATE TABLE post_tagged_ingredients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    ingredient_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE post_tagged_ingredients ENABLE ROW LEVEL SECURITY;

-- RLS Policies for post_tagged_ingredients
CREATE POLICY "Anyone can view post tagged ingredients" ON post_tagged_ingredients
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can manage post tagged ingredients" ON post_tagged_ingredients
    FOR ALL USING (auth.role() = 'authenticated');

-- Indexes for post_tagged_ingredients
CREATE INDEX idx_post_tagged_ingredients_post_id ON post_tagged_ingredients(post_id);
CREATE INDEX idx_post_tagged_ingredients_name ON post_tagged_ingredients(ingredient_name);

-- ========================================
-- Community Post Likes Table
-- ========================================
CREATE TABLE post_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT unique_user_post_like UNIQUE (user_id, post_id)
);

-- Enable RLS
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;

-- RLS Policies for post_likes
CREATE POLICY "Anyone can view post likes" ON post_likes
    FOR SELECT USING (true);

CREATE POLICY "Users can manage own likes" ON post_likes
    FOR ALL USING (auth.uid() = user_id);

-- Indexes for post_likes
CREATE INDEX idx_post_likes_post_id ON post_likes(post_id);
CREATE INDEX idx_post_likes_user_id ON post_likes(user_id);

-- ========================================
-- Chat Messages Table
-- ========================================
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type message_type NOT NULL DEFAULT 'text',
    sender message_sender NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    image_url TEXT,
    is_rated_positive BOOLEAN,
    is_rated_negative BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies for chat_messages
CREATE POLICY "Users can view own chat messages" ON chat_messages
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own chat messages" ON chat_messages
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own chat messages" ON chat_messages
    FOR UPDATE USING (auth.uid() = user_id);

-- Indexes for chat_messages
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_timestamp ON chat_messages(timestamp);
CREATE INDEX idx_chat_messages_sender ON chat_messages(sender);
CREATE INDEX idx_chat_messages_type ON chat_messages(message_type);

-- ========================================
-- Notifications Table
-- ========================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    notification_type notification_type NOT NULL,
    image_url TEXT,
    action_url TEXT,
    related_item_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies for notifications
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can create notifications" ON notifications
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- Indexes for notifications
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_timestamp ON notifications(timestamp);
CREATE INDEX idx_notifications_type ON notifications(notification_type);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_related_item ON notifications(related_item_id);

-- ========================================
-- User Saved Recipes Table (Many-to-Many relationship)
-- ========================================
CREATE TABLE user_saved_recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    saved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT unique_user_recipe_save UNIQUE (user_id, recipe_id)
);

-- Enable RLS
ALTER TABLE user_saved_recipes ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_saved_recipes
CREATE POLICY "Users can view own saved recipes" ON user_saved_recipes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own saved recipes" ON user_saved_recipes
    FOR ALL USING (auth.uid() = user_id);

-- Indexes for user_saved_recipes
CREATE INDEX idx_user_saved_recipes_user_id ON user_saved_recipes(user_id);
CREATE INDEX idx_user_saved_recipes_recipe_id ON user_saved_recipes(recipe_id);

-- ========================================
-- Recipe Reviews Table
-- ========================================
CREATE TABLE recipe_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating DECIMAL(2,1) NOT NULL CHECK (rating >= 0.0 AND rating <= 5.0),
    review_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT unique_user_recipe_review UNIQUE (user_id, recipe_id)
);

-- Enable RLS
ALTER TABLE recipe_reviews ENABLE ROW LEVEL SECURITY;

-- RLS Policies for recipe_reviews
CREATE POLICY "Anyone can view recipe reviews" ON recipe_reviews
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create reviews" ON recipe_reviews
    FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND auth.uid() = user_id);

CREATE POLICY "Users can update own reviews" ON recipe_reviews
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reviews" ON recipe_reviews
    FOR DELETE USING (auth.uid() = user_id);

-- Indexes for recipe_reviews
CREATE INDEX idx_recipe_reviews_recipe_id ON recipe_reviews(recipe_id);
CREATE INDEX idx_recipe_reviews_user_id ON recipe_reviews(user_id);
CREATE INDEX idx_recipe_reviews_rating ON recipe_reviews(rating);

-- ========================================
-- Functions for Updating Timestamps
-- ========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at columns
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recipes_updated_at BEFORE UPDATE ON recipes 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pantry_items_updated_at BEFORE UPDATE ON pantry_items 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_community_posts_updated_at BEFORE UPDATE ON community_posts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recipe_reviews_updated_at BEFORE UPDATE ON recipe_reviews 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- Functions for Counter Updates
-- ========================================

-- Function to update recipe stats after review changes
CREATE OR REPLACE FUNCTION update_recipe_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE recipes 
    SET 
        review_count = (SELECT COUNT(*) FROM recipe_reviews WHERE recipe_id = COALESCE(NEW.recipe_id, OLD.recipe_id)),
        rating = COALESCE((SELECT AVG(rating) FROM recipe_reviews WHERE recipe_id = COALESCE(NEW.recipe_id, OLD.recipe_id)), 0)
    WHERE id = COALESCE(NEW.recipe_id, OLD.recipe_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Create triggers for recipe stats
CREATE TRIGGER update_recipe_stats_after_review_insert
    AFTER INSERT ON recipe_reviews
    FOR EACH ROW EXECUTE FUNCTION update_recipe_stats();

CREATE TRIGGER update_recipe_stats_after_review_update
    AFTER UPDATE ON recipe_reviews
    FOR EACH ROW EXECUTE FUNCTION update_recipe_stats();

CREATE TRIGGER update_recipe_stats_after_review_delete
    AFTER DELETE ON recipe_reviews
    FOR EACH ROW EXECUTE FUNCTION update_recipe_stats();

-- Function to update user saved recipes count
CREATE OR REPLACE FUNCTION update_user_saved_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE user_profiles 
    SET saved_recipes_count = (SELECT COUNT(*) FROM user_saved_recipes WHERE user_id = COALESCE(NEW.user_id, OLD.user_id))
    WHERE id = COALESCE(NEW.user_id, OLD.user_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Create triggers for user saved count
CREATE TRIGGER update_user_saved_count_after_save_insert
    AFTER INSERT ON user_saved_recipes
    FOR EACH ROW EXECUTE FUNCTION update_user_saved_count();

CREATE TRIGGER update_user_saved_count_after_save_delete
    AFTER DELETE ON user_saved_recipes
    FOR EACH ROW EXECUTE FUNCTION update_user_saved_count();

-- Function to update user posts count
CREATE OR REPLACE FUNCTION update_user_posts_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE user_profiles 
    SET posts_count = (SELECT COUNT(*) FROM community_posts WHERE user_id = COALESCE(NEW.user_id, OLD.user_id))
    WHERE id = COALESCE(NEW.user_id, OLD.user_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Create triggers for user posts count
CREATE TRIGGER update_user_posts_count_after_post_insert
    AFTER INSERT ON community_posts
    FOR EACH ROW EXECUTE FUNCTION update_user_posts_count();

CREATE TRIGGER update_user_posts_count_after_post_delete
    AFTER DELETE ON community_posts
    FOR EACH ROW EXECUTE FUNCTION update_user_posts_count();

-- Function to update post like count
CREATE OR REPLACE FUNCTION update_post_like_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE community_posts 
    SET like_count = (SELECT COUNT(*) FROM post_likes WHERE post_id = COALESCE(NEW.post_id, OLD.post_id))
    WHERE id = COALESCE(NEW.post_id, OLD.post_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Create triggers for post like count
CREATE TRIGGER update_post_like_count_after_like_insert
    AFTER INSERT ON post_likes
    FOR EACH ROW EXECUTE FUNCTION update_post_like_count();

CREATE TRIGGER update_post_like_count_after_like_delete
    AFTER DELETE ON post_likes
    FOR EACH ROW EXECUTE FUNCTION update_post_like_count();

-- ========================================
-- Handle new user profile creation
-- ========================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, name, email)
    VALUES (NEW.id, NEW.raw_user_meta_data->>'name', NEW.email);
    RETURN NEW;
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- Trigger to automatically create profile when user signs up
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ========================================
-- Views for Common Queries
-- ========================================

-- View for user dashboard data
CREATE VIEW user_dashboard AS
SELECT 
    up.id,
    up.name,
    up.email,
    up.image_url,
    up.saved_recipes_count,
    up.posts_count,
    (SELECT COUNT(*) FROM pantry_items WHERE user_id = up.id) as pantry_items_count,
    (SELECT COUNT(*) FROM pantry_items WHERE user_id = up.id AND expiration_date <= CURRENT_DATE + INTERVAL '7 days') as expiring_items_count,
    (SELECT COUNT(*) FROM notifications WHERE user_id = up.id AND is_read = FALSE) as unread_notifications_count
FROM user_profiles up;

-- View for recipe details with categories
CREATE VIEW recipe_details AS
SELECT 
    r.*,
    STRING_AGG(rc.category, ', ') as categories
FROM recipes r
LEFT JOIN recipe_categories rc ON r.id = rc.recipe_id
GROUP BY r.id, r.name, r.slug, r.image_url, r.rating, r.review_count, 
         r.estimated_cost, r.cook_time, r.servings, r.description, 
         r.created_by, r.created_at, r.updated_at;

-- View for popular recipes
CREATE VIEW popular_recipes AS
SELECT 
    r.*,
    STRING_AGG(rc.category, ', ') as categories
FROM recipes r
LEFT JOIN recipe_categories rc ON r.id = rc.recipe_id
WHERE r.rating >= 4.0 AND r.review_count >= 5
GROUP BY r.id, r.name, r.slug, r.image_url, r.rating, r.review_count, 
         r.estimated_cost, r.cook_time, r.servings, r.description, 
         r.created_by, r.created_at, r.updated_at
ORDER BY r.rating DESC, r.review_count DESC;

-- ========================================
-- Real-time subscriptions setup
-- ========================================

-- Enable real-time for key tables
ALTER PUBLICATION supabase_realtime ADD TABLE user_profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE recipes;
ALTER PUBLICATION supabase_realtime ADD TABLE community_posts;
ALTER PUBLICATION supabase_realtime ADD TABLE post_likes;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE pantry_items;

-- ========================================
-- Storage Buckets (to be created in Supabase Dashboard)
-- ========================================

-- Run these in the Supabase SQL editor or Dashboard:
-- 
-- INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);
-- INSERT INTO storage.buckets (id, name, public) VALUES ('recipe-images', 'recipe-images', true);
-- INSERT INTO storage.buckets (id, name, public) VALUES ('post-images', 'post-images', true);
-- INSERT INTO storage.buckets (id, name, public) VALUES ('pantry-images', 'pantry-images', true);
-- INSERT INTO storage.buckets (id, name, public) VALUES ('chat-images', 'chat-images', true);

-- Storage policies (run after creating buckets):
-- 
-- CREATE POLICY "Avatar images are publicly accessible" ON storage.objects 
--     FOR SELECT USING (bucket_id = 'avatars');
-- 
-- CREATE POLICY "Users can upload their own avatar" ON storage.objects 
--     FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
-- 
-- CREATE POLICY "Recipe images are publicly accessible" ON storage.objects 
--     FOR SELECT USING (bucket_id = 'recipe-images');
-- 
-- CREATE POLICY "Authenticated users can upload recipe images" ON storage.objects 
--     FOR INSERT WITH CHECK (bucket_id = 'recipe-images' AND auth.role() = 'authenticated');

-- ========================================
-- Edge Functions Setup
-- ========================================

-- You may want to create these Edge Functions in Supabase:
-- 1. generate-recipe-recommendations
-- 2. check-expiring-items
-- 3. send-push-notifications
-- 4. ai-chat-response
