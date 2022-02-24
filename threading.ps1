$docs = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name Personal | Select-Object -ExpandProperty Personal
$ini = Get-Content "$docs\My Games\FalloutNV\Fallout.ini"
$inidef = Get-Content "$env:fnv_path\Fallout_default.ini"
Set-ItemProperty -Path "$docs\My Games\FalloutNV\Fallout.ini" -Name IsReadOnly -Value $false
Set-ItemProperty -Path "$env:fnv_path\Fallout_default.ini" -Name IsReadOnly -Value $false
$inidef = $inidef -replace 'iNumHWThreads=2', "iNumHWThreads=$env:cores" -replace 'iNumHavokThreads=2', "iNumHavokThreads=$env:cores" > "$docs\My Games\FalloutNV\Fallout.ini"
$ini = $ini -replace 'iNumHWThreads=2', "iNumHWThreads=$env:cores" -replace 'iNumHavokThreads=2', "iNumHavokThreads=$env:cores" > "$env:fnv_path\Fallout_default.ini"
