$nvhr = & "$PSScriptRoot\Mods\cpu_info.exe" | Select-Object -Last 2 | Select-Object -First 1
$nvhr = $nvhr -replace ' => Use ', '' -replace ' <=', ''
$nvhr = $nvhr.Remove($nvhr.Length - 1)
cpi "$PSScriptRoot\Mods\$nvhr\d3dx9_38.dll" "$env:fnv_path\d3dx9_38.dll"
