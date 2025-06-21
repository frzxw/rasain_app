# PowerShell script untuk setup database timer tanpa command-line tools
# Script ini menggunakan browser dan copy-paste method

param(
    [string]$DatabaseUrl = "",
    [switch]$OpenBrowser
)

Clear-Host

Write-Host "🍳 RECIPE TIMER SEEDER SETUP" -ForegroundColor Green -BackgroundColor Black
Write-Host "============================" -ForegroundColor Green
Write-Host ""

# Function to open URL in browser
function Open-DatabaseDashboard {
    param([string]$url = "")
    
    if ($url -eq "") {
        $url = "https://supabase.com/dashboard"
    }
    
    Write-Host "🌐 Opening browser to database dashboard..." -ForegroundColor Yellow
    
    # Try Chrome first, then default browser
    $chromeExe = Get-ChildItem "C:\Program Files*\Google\Chrome\Application\chrome.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($chromeExe) {
        Start-Process $chromeExe.FullName $url
    } else {
        Start-Process $url
    }
    
    Start-Sleep -Seconds 3
}

# Function to copy SQL to clipboard
function Copy-SqlToClipboard {
    param([string]$filePath)
    
    if (Test-Path $filePath) {
        try {
            $content = Get-Content $filePath -Raw -Encoding UTF8
            $content | Set-Clipboard
            return $true
        } catch {
            return $false
        }
    }
    return $false
}

# Main execution
Write-Host "🔍 Checking for SQL seeder file..." -ForegroundColor Cyan

$sqlFile = "simple_timer_seeder.sql"
$fullPath = Join-Path (Get-Location) $sqlFile

if (-not (Test-Path $fullPath)) {
    Write-Host "❌ Error: SQL file not found!" -ForegroundColor Red
    Write-Host "Expected: $fullPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please make sure you're in the correct directory and the file exists." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found SQL seeder file: $sqlFile" -ForegroundColor Green
Write-Host ""

# Copy SQL to clipboard
Write-Host "📋 Copying SQL to clipboard..." -ForegroundColor Cyan
$copied = Copy-SqlToClipboard -filePath $fullPath

if ($copied) {
    Write-Host "✅ SQL successfully copied to clipboard!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Could not copy to clipboard. You'll need to copy manually." -ForegroundColor Yellow
}

Write-Host ""

# Open browser if requested
if ($OpenBrowser -or $DatabaseUrl -ne "") {
    if ($DatabaseUrl -ne "") {
        Open-DatabaseDashboard -url $DatabaseUrl
    } else {
        Open-DatabaseDashboard
    }
}

# Display instructions
Write-Host "📝 STEP-BY-STEP INSTRUCTIONS:" -ForegroundColor Magenta
Write-Host "=============================" -ForegroundColor Magenta
Write-Host ""

Write-Host "1. 🌐 Browser should open to your database dashboard" -ForegroundColor White
Write-Host "   If not, go to: https://supabase.com/dashboard" -ForegroundColor Gray
Write-Host ""

Write-Host "2. 🔑 Login to your project dashboard" -ForegroundColor White
Write-Host "   Select your 'rasain-database' project" -ForegroundColor Gray
Write-Host ""

Write-Host "3. 📊 Navigate to SQL Editor" -ForegroundColor White
Write-Host "   Click 'SQL Editor' in the left sidebar" -ForegroundColor Gray
Write-Host ""

Write-Host "4. 📝 Paste the SQL" -ForegroundColor White
if ($copied) {
    Write-Host "   The SQL is already copied - just press Ctrl+V" -ForegroundColor Gray
} else {
    Write-Host "   Copy the SQL content from: $sqlFile" -ForegroundColor Gray
}
Write-Host ""

Write-Host "5. ▶️  Execute the SQL" -ForegroundColor White
Write-Host "   Click the 'Run' button or press Ctrl+Enter" -ForegroundColor Gray
Write-Host ""

Write-Host "6. ✅ Verify the results" -ForegroundColor White
Write-Host "   Check that timer_minutes values were updated" -ForegroundColor Gray
Write-Host ""

# Display verification queries
Write-Host "🔍 VERIFICATION QUERIES:" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Query 1 - Check total updated records:" -ForegroundColor Yellow
Write-Host "SELECT COUNT(*) as total_instructions," -ForegroundColor White
Write-Host "       COUNT(CASE WHEN timer_minutes > 0 THEN 1 END) as with_timer," -ForegroundColor White
Write-Host "       AVG(timer_minutes) as avg_timer" -ForegroundColor White
Write-Host "FROM recipe_instructions;" -ForegroundColor White
Write-Host ""

Write-Host "Query 2 - Sample data with timers:" -ForegroundColor Yellow
Write-Host "SELECT step_number, instruction_text, timer_minutes" -ForegroundColor White
Write-Host "FROM recipe_instructions" -ForegroundColor White
Write-Host "WHERE timer_minutes > 0" -ForegroundColor White
Write-Host "ORDER BY step_number" -ForegroundColor White
Write-Host "LIMIT 10;" -ForegroundColor White
Write-Host ""

# Display SQL content for manual copy if needed
if (-not $copied) {
    Write-Host "📄 SQL CONTENT (copy this manually):" -ForegroundColor Red
    Write-Host "====================================" -ForegroundColor Red
    Write-Host ""
    
    $sqlContent = Get-Content $fullPath -Raw
    Write-Host $sqlContent -ForegroundColor White
    
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Red
}

Write-Host ""
Write-Host "💡 TIPS:" -ForegroundColor Green
Write-Host "- The seeder is safe to run multiple times" -ForegroundColor White
Write-Host "- It only updates NULL or 0 timer values" -ForegroundColor White
Write-Host "- Timer values are in minutes (e.g., 5 = 5 minutes)" -ForegroundColor White
Write-Host "- Values are calculated based on cooking methods and step numbers" -ForegroundColor White
Write-Host ""

Write-Host "🎉 After running the seeder, your Flutter app will show:" -ForegroundColor Green
Write-Host "- Timer countdown for each cooking step" -ForegroundColor White
Write-Host "- Visual progress indicators" -ForegroundColor White
Write-Host "- Cooking mode with step-by-step timing" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
