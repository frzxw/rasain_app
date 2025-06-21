# 🛠️ SUPABASE RLS POLICY FIX

## 🚨 Error yang Terjadi:
```
PostgrestException(message: new row violates row-level security policy for table "user_profiles", code: 42501)
```

## 🔍 Penyebab:
Row-Level Security (RLS) policy di Supabase untuk table `user_profiles` tidak mengizinkan user baru untuk melakukan INSERT pada table tersebut.

## 🛠️ Solusi di Kode Flutter:
✅ **Sudah diperbaiki di AuthService:**
- Menangani error RLS policy dengan graceful fallback
- Membuat basic user profile locally jika database insert gagal
- User tetap bisa login dan menggunakan aplikasi

## 🔧 Solusi di Supabase Dashboard:
Untuk mengatasi masalah ini secara permanen, perlu mengatur RLS policy di Supabase:

### 1. **Login ke Supabase Dashboard:**
   - Buka https://supabase.com
   - Login ke project: quxpdapjcslwlxhzcxkv

### 2. **Pergi ke Table Editor:**
   - Pilih table `user_profiles`
   - Klik tab "RLS" (Row Level Security)

### 3. **Tambahkan Policy untuk INSERT:**
```sql
-- Policy untuk mengizinkan user membuat profile sendiri
CREATE POLICY "Users can create their own profile" 
ON user_profiles 
FOR INSERT 
WITH CHECK (auth.uid() = id);
```

### 4. **Tambahkan Policy untuk SELECT:**
```sql
-- Policy untuk mengizinkan user melihat profile sendiri
CREATE POLICY "Users can view their own profile" 
ON user_profiles 
FOR SELECT 
USING (auth.uid() = id);
```

### 5. **Tambahkan Policy untuk UPDATE:**
```sql
-- Policy untuk mengizinkan user update profile sendiri
CREATE POLICY "Users can update their own profile" 
ON user_profiles 
FOR UPDATE 
USING (auth.uid() = id);
```

### 6. **Tambahkan Policy untuk DELETE:**
```sql
-- Policy untuk mengizinkan user hapus profile sendiri
CREATE POLICY "Users can delete their own profile" 
ON user_profiles 
FOR DELETE 
USING (auth.uid() = id);
```

## 🚀 **Alternatif Cepat - Nonaktifkan RLS Sementara:**
Jika ingin solusi cepat untuk testing:

1. **Pergi ke Table Editor > user_profiles**
2. **Klik "Settings" di kanan atas table**
3. **Toggle OFF "Enable RLS"**

⚠️ **Peringatan:** Menonaktifkan RLS membuat data kurang aman untuk production.

## ✅ **Status Saat Ini:**
- ✅ Aplikasi Flutter sudah diperbaiki untuk menangani error RLS
- ✅ User tetap bisa register dan login meski ada error RLS
- ✅ Profile dibuat secara lokal jika database insert gagal
- 🔄 **Perlu:** Setup RLS policy di Supabase untuk solusi permanen

## 🎯 **Untuk Testing:**
1. Coba register user baru
2. Aplikasi akan menangani error RLS dengan baik
3. User tetap bisa masuk ke HomeScreen
4. Setup RLS policy di Supabase untuk solusi permanen
