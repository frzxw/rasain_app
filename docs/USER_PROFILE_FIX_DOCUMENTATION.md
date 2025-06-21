# 🔧 User Profile RLS Error Fix

## Masalah

Saat melakukan registrasi, terjadi error:

```
POST https://quxpdapjcslwlxhzcxkv.supabase.co/rest/v1/user_profiles 401 (Unauthorized)
Error creating user profile: PostgrestException(message: new row violates row-level security policy for table "user_profiles", code: 42501, details: , hint: null)
```

## Penyebab

1. **Schema Issue**: Tabel `user_profiles` menggunakan referensi ke custom `users` table, bukan built-in `auth.users` table
2. **RLS Policy Issue**: Policy keamanan tidak sesuai dengan implementasi auth Supabase
3. **Timing Issue**: Profile dibuat sebelum session auth benar-benar established

## Solusi

### 1. Jalankan SQL Fix di Supabase Dashboard

Buka Supabase Dashboard → SQL Editor dan jalankan file `user_profiles_fix.sql`:

```sql
-- Drop existing table and recreate with proper structure
DROP TABLE IF EXISTS user_profiles CASCADE;

CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    image_url TEXT,
    saved_recipes_count INTEGER DEFAULT 0,
    posts_count INTEGER DEFAULT 0,
    is_notifications_enabled BOOLEAN DEFAULT true,
    language VARCHAR(10) DEFAULT 'id',
    is_dark_mode_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Create proper policies
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can view other profiles" ON user_profiles
    FOR SELECT USING (true);

-- Auto-create profile trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, name, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
        NEW.email
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### 2. Update Auth Service

File `auth_service.dart` telah diupdate dengan:

- **Better Error Handling**: Menangani RLS error dengan graceful fallback
- **Improved Debugging**: Lebih banyak log untuk debugging
- **Timing Fix**: Menambah delay untuk memastikan auth session established
- **Upsert Usage**: Menggunakan upsert untuk menghindari conflict

### 3. Cara Test

1. **Restart App**: Setelah menjalankan SQL fix
2. **Test Registration**: Coba daftar dengan email/password baru
3. **Check Logs**: Periksa debug logs untuk memastikan profile dibuat
4. **Verify Database**: Cek di Supabase dashboard apakah profile tersimpan

### 4. Alternative Manual Fix

Jika masih error, bisa matikan RLS sementara untuk testing:

```sql
-- Disable RLS temporarily (ONLY FOR DEVELOPMENT)
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;
```

**⚠️ PENTING**: Jangan gunakan ini di production!

### 5. Verification Query

Untuk memastikan semuanya bekerja:

```sql
-- Check if user profiles are created properly
SELECT * FROM user_profiles ORDER BY created_at DESC LIMIT 5;

-- Check RLS policies
SELECT * FROM pg_policies WHERE tablename = 'user_profiles';
```

## Tips

1. **Development**: Bisa disable RLS untuk development testing
2. **Production**: Pastikan RLS enabled dengan policy yang benar
3. **Monitoring**: Check logs di Supabase untuk auth issues
4. **Backup**: Selalu backup data sebelum menjalankan schema changes

## Status Check

Setelah implementasi fix:

- ✅ Schema updated to reference auth.users
- ✅ RLS policies fixed
- ✅ Auto-profile creation trigger added
- ✅ Auth service improved with better error handling
- ✅ Timing issues addressed
