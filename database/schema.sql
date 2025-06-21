-- =========================================
-- RASAIN APP DATABASE SCHEMA
-- PostgreSQL Schema for Indonesian Recipe & Cooking Assistant App
-- Optimized for Supabase with built-in authentication
-- =========================================

-- Enable UUID extension for primary keys
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable trigram extension for full-text search
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- =========================================
-- ENUMS
-- =========================================

-- Message types for chat system
CREATE TYPE message_type AS ENUM ('text', 'image');

-- Message sender types
CREATE TYPE message_sender AS ENUM ('user', 'ai', 'assistant');

-- Notification types
CREATE TYPE notification_type AS ENUM (
    'recipe_recommendation', 
    'expiration_warning', 
    'low_stock', 
    'new_recipe', 
    'review', 
    'achievement', 
    'system'
);

-- =========================================
-- CORE TABLES
-- =========================================

-- Users table (main user authentication and basic info)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT,
    email_verified BOOLEAN DEFAULT false,
    phone VARCHAR(20),
    phone_verified BOOLEAN DEFAULT false,
    last_sign_in_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User profiles table (extended user information)
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    image_url TEXT,
    saved_recipes_count INTEGER DEFAULT 0,
    posts_count INTEGER DEFAULT 0,
    is_notifications_enabled BOOLEAN DEFAULT true,
    language VARCHAR(10) DEFAULT 'id', -- Indonesian by default
    is_dark_mode_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_profiles
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (id = auth.uid());

CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (id = auth.uid());

-- Recipe categories (normalized table)
CREATE TABLE recipe_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    name_id VARCHAR(100), -- Indonesian name
    name_en VARCHAR(100), -- English name
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Main recipes table
CREATE TABLE recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE, -- SEO-friendly URL slug
    image_url TEXT,
    rating DECIMAL(3,2) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    review_count INTEGER DEFAULT 0,
    estimated_cost VARCHAR(50), -- e.g., "Rp25.000"
    cook_time VARCHAR(50), -- e.g., "25 menit"
    prep_time VARCHAR(50), -- preparation time
    total_time VARCHAR(50), -- total cooking time
    servings INTEGER,    difficulty_level VARCHAR(20), -- 'easy', 'medium', 'hard'
    description TEXT,
    nutrition_info JSONB, -- Nutritional information
    tips TEXT, -- Cooking tips
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    is_featured BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Junction table for recipe categories (many-to-many)
CREATE TABLE recipe_category_mappings (
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES recipe_categories(id) ON DELETE CASCADE,
    PRIMARY KEY (recipe_id, category_id)
);

-- Recipe ingredients
CREATE TABLE recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    quantity VARCHAR(50),
    unit VARCHAR(50),
    price VARCHAR(50), -- estimated price
    image_url TEXT,
    is_optional BOOLEAN DEFAULT false,
    notes TEXT,
    order_index INTEGER DEFAULT 0, -- for ordering ingredients
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Recipe instructions/steps
CREATE TABLE recipe_instructions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    step_number INTEGER NOT NULL,
    instruction_text TEXT NOT NULL,
    video_url TEXT,
    image_url TEXT,
    estimated_time VARCHAR(50), -- Time for this step
    temperature VARCHAR(50), -- Cooking temperature if applicable
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- PANTRY MANAGEMENT
-- =========================================

-- Pantry item categories
CREATE TABLE pantry_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    name_id VARCHAR(100), -- Indonesian name
    name_en VARCHAR(100), -- English name
    description TEXT,
    icon VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User pantry items
CREATE TABLE pantry_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    image_url TEXT,
    quantity VARCHAR(50),
    unit VARCHAR(50),
    price VARCHAR(50),
    category_id INTEGER REFERENCES pantry_categories(id),
    storage_location VARCHAR(100), -- 'Pantry', 'Refrigerator', 'Freezer', etc.
    total_quantity INTEGER,
    low_stock_alert BOOLEAN DEFAULT false,
    expiration_alert BOOLEAN DEFAULT true,
    expiration_date DATE,
    purchase_date DATE,
    last_used_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Kitchen tools/equipment
CREATE TABLE kitchen_tools (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    name_id VARCHAR(255), -- Indonesian name
    name_en VARCHAR(255), -- English name
    description TEXT,
    image_url TEXT,
    category VARCHAR(100), -- 'Cooking', 'Baking', 'Prep', etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User's kitchen tools (many-to-many)
CREATE TABLE user_kitchen_tools (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    tool_id INTEGER REFERENCES kitchen_tools(id) ON DELETE CASCADE,
    acquired_date DATE,
    notes TEXT,
    PRIMARY KEY (user_id, tool_id)
);

-- =========================================
-- USER INTERACTIONS
-- =========================================

-- User saved recipes
CREATE TABLE saved_recipes (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    saved_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT, -- Personal notes about the recipe
    PRIMARY KEY (user_id, recipe_id)
);

-- Recipe reviews and ratings
CREATE TABLE recipe_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating DECIMAL(3,2) NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    images JSONB, -- Array of image URLs
    is_verified_purchase BOOLEAN DEFAULT false,
    helpful_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(recipe_id, user_id) -- One review per user per recipe
);

-- Cooking session tracking
CREATE TABLE cooking_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    current_step INTEGER DEFAULT 1,
    total_steps INTEGER,
    notes TEXT,
    rating DECIMAL(3,2) CHECK (rating >= 1 AND rating <= 5), -- Rating after completion
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- COMMUNITY FEATURES
-- =========================================

-- Community posts
CREATE TABLE community_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT,
    image_url TEXT,
    category VARCHAR(100),
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tagged ingredients in community posts
CREATE TABLE post_tagged_ingredients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    ingredient_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Community post likes
CREATE TABLE post_likes (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, post_id)
);

-- Community post comments
CREATE TABLE post_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES post_comments(id) ON DELETE CASCADE, -- For nested comments
    content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Comment likes
CREATE TABLE comment_likes (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES post_comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, comment_id)
);

-- =========================================
-- CHAT/AI ASSISTANT
-- =========================================

-- Chat conversations
CREATE TABLE chat_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255), -- Optional conversation title
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Chat messages
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES chat_conversations(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type message_type NOT NULL DEFAULT 'text',
    sender message_sender NOT NULL,
    image_url TEXT,
    is_rated_positive BOOLEAN,
    is_rated_negative BOOLEAN,
    metadata JSONB, -- Additional metadata for AI responses
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- NOTIFICATIONS
-- =========================================

-- User notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type notification_type NOT NULL,
    image_url TEXT,
    action_url TEXT, -- Deep link URL
    related_item_id UUID, -- ID of related item (recipe, pantry item, etc.)
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- SEARCH AND RECOMMENDATIONS
-- =========================================

-- User search history
CREATE TABLE search_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    query TEXT NOT NULL,
    search_type VARCHAR(50) DEFAULT 'text', -- 'text', 'image', 'voice'
    results_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Recipe recommendations tracking
CREATE TABLE recipe_recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    recommendation_type VARCHAR(50) NOT NULL, -- 'pantry_based', 'preference', 'trending', etc.
    score DECIMAL(5,4), -- Recommendation score
    was_clicked BOOLEAN DEFAULT false,
    was_saved BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- ADMIN AND ANALYTICS
-- =========================================

-- Admin users
CREATE TABLE admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'moderator', -- 'admin', 'moderator', 'content_creator'
    permissions JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Analytics events
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    event_name VARCHAR(255) NOT NULL,
    properties JSONB,
    session_id VARCHAR(255),
    device_info JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- INDEXES FOR PERFORMANCE
-- =========================================

-- User indexes
CREATE INDEX idx_user_profiles_created_at ON user_profiles(created_at);

-- Recipe indexes
CREATE INDEX idx_recipes_rating ON recipes(rating DESC);
CREATE INDEX idx_recipes_created_at ON recipes(created_at DESC);
CREATE INDEX idx_recipes_slug ON recipes(slug);
CREATE INDEX idx_recipes_is_featured ON recipes(is_featured);
CREATE INDEX idx_recipes_is_published ON recipes(is_published);

-- Full-text search indexes
CREATE INDEX idx_recipes_name_trgm ON recipes USING gin(name gin_trgm_ops);
CREATE INDEX idx_recipes_description_trgm ON recipes USING gin(description gin_trgm_ops);
CREATE INDEX idx_recipe_ingredients_name_trgm ON recipe_ingredients USING gin(name gin_trgm_ops);

-- Pantry indexes
CREATE INDEX idx_pantry_items_user_id ON pantry_items(user_id);
CREATE INDEX idx_pantry_items_expiration_date ON pantry_items(expiration_date);
CREATE INDEX idx_pantry_items_category_id ON pantry_items(category_id);

-- Community indexes
CREATE INDEX idx_community_posts_user_id ON community_posts(user_id);
CREATE INDEX idx_community_posts_created_at ON community_posts(created_at DESC);
CREATE INDEX idx_community_posts_category ON community_posts(category);

-- Review indexes
CREATE INDEX idx_recipe_reviews_recipe_id ON recipe_reviews(recipe_id);
CREATE INDEX idx_recipe_reviews_user_id ON recipe_reviews(user_id);
CREATE INDEX idx_recipe_reviews_rating ON recipe_reviews(rating DESC);
CREATE INDEX idx_recipe_reviews_created_at ON recipe_reviews(created_at DESC);

-- Chat indexes
CREATE INDEX idx_chat_messages_conversation_id ON chat_messages(conversation_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);
CREATE INDEX idx_chat_conversations_user_id ON chat_conversations(user_id);

-- Notification indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- Analytics indexes
CREATE INDEX idx_analytics_events_user_id ON analytics_events(user_id);
CREATE INDEX idx_analytics_events_event_name ON analytics_events(event_name);
CREATE INDEX idx_analytics_events_created_at ON analytics_events(created_at);

-- =========================================
-- TRIGGERS FOR AUTOMATED UPDATES
-- =========================================

-- Function to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at columns
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

CREATE TRIGGER update_post_comments_updated_at BEFORE UPDATE ON post_comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_conversations_updated_at BEFORE UPDATE ON chat_conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update recipe rating when reviews are added/updated/deleted
CREATE OR REPLACE FUNCTION update_recipe_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE recipes 
    SET 
        rating = COALESCE((
            SELECT ROUND(AVG(rating)::numeric, 2)
            FROM recipe_reviews 
            WHERE recipe_id = COALESCE(NEW.recipe_id, OLD.recipe_id)
        ), 0),
        review_count = (
            SELECT COUNT(*)
            FROM recipe_reviews 
            WHERE recipe_id = COALESCE(NEW.recipe_id, OLD.recipe_id)
        )
    WHERE id = COALESCE(NEW.recipe_id, OLD.recipe_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Triggers for recipe rating updates
CREATE TRIGGER update_recipe_rating_on_review_insert
    AFTER INSERT ON recipe_reviews
    FOR EACH ROW EXECUTE FUNCTION update_recipe_rating();

CREATE TRIGGER update_recipe_rating_on_review_update
    AFTER UPDATE ON recipe_reviews
    FOR EACH ROW EXECUTE FUNCTION update_recipe_rating();

CREATE TRIGGER update_recipe_rating_on_review_delete
    AFTER DELETE ON recipe_reviews
    FOR EACH ROW EXECUTE FUNCTION update_recipe_rating();

-- Function to update post comment count
CREATE OR REPLACE FUNCTION update_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE community_posts 
    SET comment_count = (
        SELECT COUNT(*)
        FROM post_comments 
        WHERE post_id = COALESCE(NEW.post_id, OLD.post_id)
    )
    WHERE id = COALESCE(NEW.post_id, OLD.post_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Triggers for comment count updates
CREATE TRIGGER update_post_comment_count_on_insert
    AFTER INSERT ON post_comments
    FOR EACH ROW EXECUTE FUNCTION update_post_comment_count();

CREATE TRIGGER update_post_comment_count_on_delete
    AFTER DELETE ON post_comments
    FOR EACH ROW EXECUTE FUNCTION update_post_comment_count();

-- Function to update post like count
CREATE OR REPLACE FUNCTION update_post_like_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE community_posts 
    SET like_count = (
        SELECT COUNT(*)
        FROM post_likes 
        WHERE post_id = COALESCE(NEW.post_id, OLD.post_id)
    )
    WHERE id = COALESCE(NEW.post_id, OLD.post_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Triggers for like count updates
CREATE TRIGGER update_post_like_count_on_insert
    AFTER INSERT ON post_likes
    FOR EACH ROW EXECUTE FUNCTION update_post_like_count();

CREATE TRIGGER update_post_like_count_on_delete
    AFTER DELETE ON post_likes
    FOR EACH ROW EXECUTE FUNCTION update_post_like_count();

-- Function to update user stats
CREATE OR REPLACE FUNCTION update_user_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Update saved recipes count
    UPDATE user_profiles 
    SET saved_recipes_count = (
        SELECT COUNT(*)
        FROM saved_recipes 
        WHERE user_id = user_profiles.id
    );
    
    -- Update posts count
    UPDATE user_profiles 
    SET posts_count = (
        SELECT COUNT(*)
        FROM community_posts 
        WHERE user_id = user_profiles.id
    );
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- =========================================
-- SEED DATA - BASIC CATEGORIES
-- =========================================

-- Insert recipe categories
INSERT INTO recipe_categories (name, name_id, name_en) VALUES
('Makanan Utama', 'Makanan Utama', 'Main Course'),
('Makanan Penutup', 'Makanan Penutup', 'Dessert'),
('Minuman', 'Minuman', 'Beverages'),
('Sup', 'Sup', 'Soup'),
('Tradisional', 'Tradisional', 'Traditional'),
('Pedas', 'Pedas', 'Spicy'),
('Manis', 'Manis', 'Sweet'),
('Sayuran', 'Sayuran', 'Vegetable'),
('Daging', 'Daging', 'Meat'),
('Ayam', 'Ayam', 'Chicken'),
('Ikan', 'Ikan', 'Fish'),
('Seafood', 'Seafood', 'Seafood'),
('Nasi', 'Nasi', 'Rice'),
('Mie', 'Mie', 'Noodles'),
('Kue', 'Kue', 'Cake');

-- Insert pantry categories
INSERT INTO pantry_categories (name, name_id, name_en, icon) VALUES
('Sayuran', 'Sayuran', 'Vegetables', 'vegetables'),
('Buah-buahan', 'Buah-buahan', 'Fruits', 'fruits'),
('Daging', 'Daging', 'Meat', 'meat'),
('Susu & Olahan', 'Susu & Olahan', 'Dairy', 'dairy'),
('Biji-bijian', 'Biji-bijian', 'Grains', 'grains'),
('Bumbu & Rempah', 'Bumbu & Rempah', 'Spices', 'spices'),
('Roti & Kue', 'Roti & Kue', 'Bakery', 'bakery'),
('Makanan Kaleng', 'Makanan Kaleng', 'Canned', 'canned'),
('Protein', 'Protein', 'Protein', 'protein'),
('Lainnya', 'Lainnya', 'Other', 'other');

-- Insert common Indonesian kitchen tools
INSERT INTO kitchen_tools (name, name_id, name_en, category) VALUES
('Wajan', 'Wajan', 'Wok', 'Cooking'),
('Cobek', 'Cobek', 'Mortar and Pestle', 'Prep'),
('Kukusan', 'Kukusan', 'Steamer', 'Cooking'),
('Panci', 'Panci', 'Pot', 'Cooking'),
('Penggorengan', 'Penggorengan', 'Frying Pan', 'Cooking'),
('Parutan', 'Parutan', 'Grater', 'Prep'),
('Blender', 'Blender', 'Blender', 'Prep'),
('Rice Cooker', 'Rice Cooker', 'Rice Cooker', 'Cooking'),
('Kompor Gas', 'Kompor Gas', 'Gas Stove', 'Cooking'),
('Pisau', 'Pisau', 'Knife', 'Prep'),
('Talenan', 'Talenan', 'Cutting Board', 'Prep'),
('Saringan', 'Saringan', 'Strainer', 'Prep');

-- =========================================
-- VIEWS FOR COMMON QUERIES
-- =========================================

-- Popular recipes view
CREATE VIEW popular_recipes AS
SELECT r.*, 
       COALESCE(array_agg(DISTINCT rc.name) FILTER (WHERE rc.name IS NOT NULL), '{}') as categories
FROM recipes r
LEFT JOIN recipe_category_mappings rcm ON r.id = rcm.recipe_id
LEFT JOIN recipe_categories rc ON rcm.category_id = rc.id
WHERE r.is_published = true
GROUP BY r.id
ORDER BY r.rating DESC, r.review_count DESC;

-- Recent recipes view
CREATE VIEW recent_recipes AS
SELECT r.*, 
       COALESCE(array_agg(DISTINCT rc.name) FILTER (WHERE rc.name IS NOT NULL), '{}') as categories
FROM recipes r
LEFT JOIN recipe_category_mappings rcm ON r.id = rcm.recipe_id
LEFT JOIN recipe_categories rc ON rcm.category_id = rc.id
WHERE r.is_published = true
GROUP BY r.id
ORDER BY r.created_at DESC;

-- User dashboard view
CREATE VIEW user_dashboard AS
SELECT 
    up.id,
    up.name,
    up.saved_recipes_count,
    up.posts_count,
    COUNT(DISTINCT pi.id) as pantry_items_count,
    COUNT(DISTINCT pi.id) FILTER (WHERE pi.expiration_date <= CURRENT_DATE + INTERVAL '3 days') as expiring_items_count,
    COUNT(DISTINCT n.id) FILTER (WHERE n.is_read = false) as unread_notifications_count
FROM user_profiles up
LEFT JOIN pantry_items pi ON up.id = pi.user_id
LEFT JOIN notifications n ON up.id = n.user_id
GROUP BY up.id, up.name, up.saved_recipes_count, up.posts_count;

-- =========================================
-- FUNCTIONS FOR BUSINESS LOGIC
-- =========================================

-- Function to get recipe recommendations based on pantry items
CREATE OR REPLACE FUNCTION get_pantry_based_recommendations(user_uuid UUID, limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
    recipe_id UUID,
    recipe_name VARCHAR,
    matching_ingredients_count BIGINT,
    total_ingredients_count BIGINT,
    match_percentage DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    WITH user_pantry AS (
        SELECT LOWER(name) as ingredient_name
        FROM pantry_items 
        WHERE user_id = user_uuid
    ),
    recipe_matches AS (
        SELECT 
            r.id,
            r.name,
            COUNT(ri.id) as total_ingredients,
            COUNT(up.ingredient_name) as matching_ingredients
        FROM recipes r
        JOIN recipe_ingredients ri ON r.id = ri.recipe_id
        LEFT JOIN user_pantry up ON LOWER(ri.name) LIKE '%' || up.ingredient_name || '%'
        WHERE r.is_published = true
        GROUP BY r.id, r.name
        HAVING COUNT(ri.id) > 0
    )
    SELECT 
        rm.id,
        rm.name,
        rm.matching_ingredients,
        rm.total_ingredients,
        ROUND((rm.matching_ingredients::DECIMAL / rm.total_ingredients::DECIMAL) * 100, 2)
    FROM recipe_matches rm
    WHERE rm.matching_ingredients > 0
    ORDER BY 
        (rm.matching_ingredients::DECIMAL / rm.total_ingredients::DECIMAL) DESC,
        rm.matching_ingredients DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get expiring pantry items
CREATE OR REPLACE FUNCTION get_expiring_items(user_uuid UUID, days_ahead INTEGER DEFAULT 7)
RETURNS TABLE (
    item_id UUID,
    item_name VARCHAR,
    expiration_date DATE,
    days_until_expiration INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pi.id,
        pi.name,
        pi.expiration_date,
        (pi.expiration_date - CURRENT_DATE)::INTEGER
    FROM pantry_items pi
    WHERE pi.user_id = user_uuid 
      AND pi.expiration_date IS NOT NULL
      AND pi.expiration_date <= CURRENT_DATE + INTERVAL '1 day' * days_ahead
      AND pi.expiration_date >= CURRENT_DATE
    ORDER BY pi.expiration_date ASC;
END;
$$ LANGUAGE plpgsql;

-- =========================================
-- COMMENTS
-- =========================================

COMMENT ON DATABASE postgres IS 'Rasain - Indonesian Recipe & Cooking Assistant App Database';

COMMENT ON TABLE user_profiles IS 'User profiles and authentication data';
COMMENT ON TABLE recipes IS 'Recipe information with Indonesian cuisine focus';
COMMENT ON TABLE recipe_ingredients IS 'Ingredients required for each recipe';
COMMENT ON TABLE recipe_instructions IS 'Step-by-step cooking instructions';
COMMENT ON TABLE pantry_items IS 'User pantry inventory management';
COMMENT ON TABLE community_posts IS 'User-generated content and recipe sharing';
COMMENT ON TABLE chat_messages IS 'AI assistant conversation history';
COMMENT ON TABLE notifications IS 'User notifications for various app events';
COMMENT ON TABLE recipe_reviews IS 'User reviews and ratings for recipes';

-- =========================================
-- COMPLETION MESSAGE
-- =========================================

-- Database schema creation completed
SELECT 'Rasain App PostgreSQL Database Schema Created Successfully!' as status;
