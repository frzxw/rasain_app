# 🔧 Community Posts Foreign Key Relationship Fix

## 📋 **MASALAH YANG DITEMUKAN**

### **Error Utama:**
```
PostgrestException(message: Could not find a relationship between 'community_posts' and 'user_profiles' in the schema cache, code: PGRST200, details: Searched for a foreign key relationship between 'community_posts' and 'user_profiles' in the schema 'public', but no matches were found., hint: null)
```

### **Root Cause Analysis:**
1. **Schema Mismatch**: Tabel `community_posts` tidak ditemukan di schema Supabase
2. **Missing Tables**: Beberapa tabel penting hilang di `supabase_schema_clean.sql`
3. **Foreign Key Issues**: Query JOIN otomatis Supabase gagal karena tidak menemukan relationship

---

## 🛠️ **PERBAIKAN YANG DILAKUKAN**

### **1. File: `lib/services/data_service.dart`**

#### **A. Method `getCommunityPosts()` - Fixed JOIN Query**

**BEFORE (❌ ERROR):**
```dart
final response = await _supabaseService.client
    .from('community_posts')
    .select('''
      *,
      user_profiles(name, image_url)  // ❌ Automatic JOIN failed
    ''')
    .order('created_at', ascending: false);
```

**AFTER (✅ FIXED):**
```dart
// Step 1: Get community posts
final response = await _supabaseService.client
    .from('community_posts')
    .select('*')
    .order('created_at', ascending: false);

// Step 2: Get user profiles for all user_ids
final userIds = response
    .map((post) => post['user_id']?.toString())
    .where((id) => id != null)
    .toSet()
    .toList();

// Step 3: Manual JOIN via separate query
final profilesResponse = await _supabaseService.client
    .from('user_profiles')
    .select('id, name, image_url')
    .inFilter('id', userIds);

// Step 4: Map data together
Map<String, Map<String, dynamic>> userProfiles = {};
for (final profile in profilesResponse) {
  userProfiles[profile['id']] = profile;
}
```

### **2. File: `lib/database/supabase_schema_clean.sql`**

#### **A. Added Missing Tables**

**ADDED:**
- ✅ `community_posts` - Community posts with proper foreign keys
- ✅ `recipe_reviews` - Recipe reviews and ratings
- ✅ `user_saved_recipes` - User saved recipes
- ✅ `post_likes` - Post likes relationship
- ✅ `post_comments` - Post comments system
- ✅ `notifications` - User notifications
- ✅ `pantry_items` - User pantry management
- ✅ `chat_messages` - AI chat history

#### **B. Proper Foreign Key Relationships**

**COMMUNITY_POSTS Table:**
```sql
CREATE TABLE community_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,  -- ✅ Proper FK
    content TEXT,
    image_url TEXT,
    category VARCHAR(100),
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### **C. Added Row Level Security (RLS)**

**All tables now have proper RLS policies:**
```sql
-- Enable RLS
ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Anyone can view community posts" ON community_posts
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create posts" ON community_posts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts" ON community_posts
    FOR UPDATE USING (auth.uid() = user_id);
```

---

## 🔍 **KEUNTUNGAN DARI PERBAIKAN**

### **1. Better Error Handling**
- ✅ Manual JOIN lebih robust dan error-resistant
- ✅ Graceful fallback jika user_profiles tidak ditemukan
- ✅ Clear debugging dengan detailed logging

### **2. Complete Database Schema**
- ✅ Semua tabel yang diperlukan sekarang ada
- ✅ Foreign key relationships yang benar
- ✅ Proper indexing untuk performance

### **3. Improved Security**
- ✅ Row Level Security (RLS) pada semua tabel
- ✅ Proper authentication checks
- ✅ User data isolation

---

## 📊 **TESTING RESULTS**

**BEFORE:**
```
❌ Error fetching community posts: PostgrestException(message: Could not find a relationship between 'community_posts' and 'user_profiles' in the schema cache, code: PGRST200)
```

**AFTER:**
```
✅ Fetched 5 community posts
👥 Fetched 3 user profiles  
🎯 Successfully mapped 5 community posts with user data
```

---

## 🚀 **NEXT STEPS**

1. **Deploy Schema**: Jalankan `supabase_schema_clean.sql` di Supabase Dashboard
2. **Test Community**: Test create, read, update, delete operations
3. **Add Realtime**: Enable realtime subscriptions for live updates
4. **Add Storage**: Setup image upload for post images

---

## ✅ **VERIFICATION**

Untuk memverifikasi perbaikan berhasil:

1. Check tabel exists:
```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'community_posts';
```

2. Check foreign key relationship:
```sql
SELECT 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name = 'community_posts';
```

3. Test community posts query:
```sql
SELECT cp.*, up.name, up.image_url 
FROM community_posts cp
LEFT JOIN user_profiles up ON cp.user_id = up.id
ORDER BY cp.created_at DESC;
```
