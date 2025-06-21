# 🚀 PowerShell Timer Seeder - Browser Method

## 📋 Overview

Script PowerShell yang menggunakan browser Chrome/default untuk setup database timer, **TANPA menggunakan operator `&&`** dan menggunakan syntax PowerShell native.

## 📁 Files Available

### 1. **`quick_timer_setup.ps1`** ⚡ (Recommended)
Script paling sederhana dan cepat:
- ✅ Copy SQL ke clipboard otomatis  
- ✅ Buka browser ke Supabase dashboard
- ✅ Instruksi step-by-step yang jelas
- ✅ Pure PowerShell syntax (no `&&`)

### 2. **`setup_database_timer.ps1`** 🔧 (Advanced)  
Script lengkap dengan fitur advanced:
- ✅ Parameter untuk custom database URL
- ✅ Chrome detection dan fallback
- ✅ Manual copy option jika clipboard gagal
- ✅ Verification queries

### 3. **`open_sql_seeder.ps1`** 🌐 (Browser Focus)
Script khusus untuk membuka browser:
- ✅ Deteksi instalasi Chrome
- ✅ Auto-open dashboard
- ✅ Display SQL content untuk copy manual

## 🎯 Cara Penggunaan

### Method 1: Quick Setup (Recommended)
```powershell
# Navigate to project directory
cd "d:\KULIAH\SEMESTER 4\provis\tugas 3\rasain_app"

# Run the quick setup script
.\quick_timer_setup.ps1
```

### Method 2: Advanced Setup
```powershell
# Basic usage
.\setup_database_timer.ps1

# With custom database URL
.\setup_database_timer.ps1 -DatabaseUrl "https://your-project.supabase.co" -OpenBrowser

# Silent mode (no browser opening)
.\setup_database_timer.ps1
```

### Method 3: Browser Only
```powershell
# Just open browser and show SQL
.\open_sql_seeder.ps1
```

## 📝 Step-by-Step Process

### 1. **Run PowerShell Script**
```powershell
.\quick_timer_setup.ps1
```

### 2. **Browser Opens Automatically**
- Script akan membuka Chrome atau default browser
- Otomatis navigate ke `https://supabase.com/dashboard`

### 3. **SQL Copied to Clipboard**
- SQL content otomatis di-copy ke clipboard
- Siap untuk paste dengan `Ctrl+V`

### 4. **Execute in Dashboard**
- Login ke Supabase project
- Pilih project "rasain-database"  
- Click "SQL Editor" di sidebar
- Paste SQL dengan `Ctrl+V`
- Click "Run" untuk execute

### 5. **Verify Results**
```sql
SELECT COUNT(*) as total,
       COUNT(CASE WHEN timer_minutes > 0 THEN 1 END) as with_timer
FROM recipe_instructions;
```

## 🛠 Technical Features

### PowerShell Native Commands Used:
- ✅ `Test-Path` - Check file existence
- ✅ `Get-Content` - Read SQL file  
- ✅ `Set-Clipboard` - Copy to clipboard
- ✅ `Start-Process` - Open browser
- ✅ `Write-Host` - Colored output
- ✅ `Get-Command` - Detect Chrome
- ✅ **NO `&&` operators used!**

### Browser Compatibility:
- 🟢 **Chrome** - Primary target dengan auto-detection
- 🟢 **Edge** - Fallback option
- 🟢 **Firefox** - Via default browser
- 🟢 **Any Default** - Universal fallback

### Error Handling:
- ✅ File existence check
- ✅ Clipboard fallback dengan manual copy
- ✅ Browser fallback options
- ✅ Clear error messages dengan colored output

## 🎨 Output Features

### Color Coding:
- 🟢 **Green** - Success messages
- 🟡 **Yellow** - Warnings/info  
- 🔴 **Red** - Errors
- 🔵 **Cyan** - Step headers
- ⚪ **White** - Instructions

### User Experience:
- ✅ Clear step-by-step instructions
- ✅ Visual progress indicators
- ✅ Copy-paste ready commands
- ✅ Verification queries provided
- ✅ Manual fallback options

## 🔍 Troubleshooting

### Issue: "Script cannot be loaded"
```powershell
# Enable script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: "Chrome not found"
```powershell
# Script will automatically fallback to default browser
# Or manually go to: https://supabase.com/dashboard
```

### Issue: "Clipboard failed"
```powershell
# Script will display SQL content for manual copy
# Copy the displayed SQL manually
```

### Issue: "SQL file not found"
```powershell
# Make sure you're in the correct directory
Get-Location
# Should show: d:\KULIAH\SEMESTER 4\provis\tugas 3\rasain_app
```

## 📊 Expected Results

After running the seeder successfully:

```sql
-- Before seeder
timer_minutes: NULL, NULL, NULL, NULL...

-- After seeder  
timer_minutes: 5, 10, 15, 2, 8...
```

### Timer Values Applied:
- **Step 1 (Prep)**: 2-5 minutes
- **Step 2 (Cooking)**: 5-20 minutes  
- **Step 3 (Advanced)**: 7-25 minutes
- **Step 4 (Finishing)**: 1-15 minutes
- **Step 5+ (Serving)**: 2-30 minutes

## 🎉 Success Criteria

✅ **Browser opens** to Supabase dashboard  
✅ **SQL copied** to clipboard automatically  
✅ **Clear instructions** displayed in PowerShell  
✅ **No `&&` operators** used (PowerShell native only)  
✅ **Error handling** for common issues  
✅ **Verification queries** provided  
✅ **Manual fallbacks** available  

## 🚀 Next Steps

After successful seeder execution:

1. **Test in Flutter App** - Lihat timer di cooking mode
2. **Verify Data** - Check timer_minutes values in database  
3. **User Testing** - Test cooking experience dengan timer
4. **Customize Values** - Adjust timer sesuai preference

---

## 💡 Pro Tips

- **Run as Administrator** jika ada permission issues
- **Check PowerShell version**: `$PSVersionTable.PSVersion`
- **Use Chrome** untuk best compatibility
- **Bookmark dashboard** untuk akses cepat
- **Test queries** di SQL Editor sebelum deploy

**Status**: ✅ **READY TO USE - NO && OPERATORS!**
