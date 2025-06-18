-- QUICK FIX DATABASE - COPY PASTE SATU PER SATU
-- Jalankan di Supabase Dashboard > SQL Editor
-- JANGAN jalankan sekaligus, tapi satu per satu

-- STEP 1: Grant permissions basic
GRANT USAGE ON SCHEMA public TO anon;

-- STEP 2: Grant table permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO anon;

-- STEP 3: Disable RLS untuk recipes
ALTER TABLE recipes DISABLE ROW LEVEL SECURITY;

-- STEP 4: Test query - harus berhasil
SELECT COUNT(*) as total_recipes FROM recipes;

-- STEP 5: Cek struktur table recipes
SELECT column_name FROM information_schema.columns WHERE table_name = 'recipes';

-- STEP 6: Drop kitchen_tools jika ada error
DROP TABLE IF EXISTS kitchen_tools;

-- STEP 7: Buat kitchen_tools baru
CREATE TABLE kitchen_tools (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    category VARCHAR(100),
    description TEXT
);

-- STEP 8: Insert data kitchen_tools
INSERT INTO kitchen_tools (name, category, description) VALUES ('Pisau Chef', 'Cutting', 'Pisau serbaguna');

-- STEP 9: Grant permission kitchen_tools
GRANT SELECT, INSERT, UPDATE, DELETE ON kitchen_tools TO anon;

-- STEP 10: Test final - pastikan berhasil
SELECT 'SUCCESS!' as status, COUNT(*) as recipes FROM recipes;
