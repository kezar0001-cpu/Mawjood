# Script to run Mawjood on Web with Supabase credentials from .env
# Usage: .\run_web.ps1

$envFile = ".env"

if (!(Test-Path $envFile)) {
    Write-Error ".env file not found!"
    exit 1
}

$url = ""
$key = ""

Get-Content $envFile | ForEach-Object {
    if ($_ -match '^\s*SUPABASE_URL\s*=\s*(.*)\s*$') {
        $url = $matches[1]
    }
    if ($_ -match '^\s*SUPABASE_ANON_KEY\s*=\s*(.*)\s*$') {
        $key = $matches[1]
    }
}

if ([string]::IsNullOrEmpty($url) -or [string]::IsNullOrEmpty($key)) {
    Write-Error "Could not find SUPABASE_URL or SUPABASE_ANON_KEY in .env"
    exit 1
}

Write-Host "🚀 Launching Mawjood (Web)..."
Write-Host "📍 Supabase URL: $url"
Write-Host "🔑 Supabase Key: (Loaded)"

flutter run -d chrome --dart-define=SUPABASE_URL=$url --dart-define=SUPABASE_ANON_KEY=$key
