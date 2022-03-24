$docs = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name Personal | Select-Object -ExpandProperty Personal
$ini = Get-Content "$docs\My Games\FalloutNV\Fallout.ini"
$inidef = Get-Content "$env:fnv_path\Fallout_default.ini"
$cores = WMIC CPU Get NumberOfCores | select -Skip 2
if ($cores -gt 6) {$cores = 6}
Set-ItemProperty -Path "$docs\My Games\FalloutNV\Fallout.ini" -Name IsReadOnly -Value $false
Set-ItemProperty -Path "$env:fnv_path\Fallout_default.ini" -Name IsReadOnly -Value $false
$inidef = $inidef -replace 'iNumHWThreads=2', "iNumHWThreads=$cores" -replace 'iNumHavokThreads=2', "iNumHavokThreads=$cores" > "$docs\My Games\FalloutNV\Fallout.ini"
$ini = $ini -replace 'iNumHWThreads=2', "iNumHWThreads=$cores" -replace 'iNumHavokThreads=2', "iNumHavokThreads=$cores" > "$env:fnv_path\Fallout_default.ini"
