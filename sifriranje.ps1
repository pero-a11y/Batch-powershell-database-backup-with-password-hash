$geslo = "!Maribor2024"
$sifrirajgeslo = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($geslo))
Set-Content -Path "pass.txt" -Value "DB_PASSWORD=$sifrirajgeslo" -Force
