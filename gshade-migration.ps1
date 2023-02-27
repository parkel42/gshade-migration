#variable definitions
$gshadereg = "HKLM:\SOFTWARE\GShade"

if (Test-Path $gshadereg){
	$gshadedir = Get-ItemProperty $gshadereg | Select-Object -ExpandProperty instdir
}
else{
	$gshadedir = $null
}

$backupdir = "$env:USERPROFILE\gshade-backup\"

#function definitions
function BackupGShade{
	echo "`n`nBacking up gshade-presets and gshade-shaders..."

	cp -Recurse "$gshadedir\gshade-shaders" "$backupdir"
	cp -Recurse "$installdir\gshade-presets" "$backupdir"
}

function DownloadStuff{
	echo "`n`nDownloading ReShade and other shaders. This process may take a while, you can go grab a coffee in the meantime!`n"
	echo "Downloading ReShade 5.6.0..."
	iwr "https://reshade.me/downloads/ReShade_Setup_5.6.0_Addon.exe" -OutFile "$backupdir\installer\ReShade_Setup_Addon.exe"

	echo "Downloading custom/fixed shaders..."
	iwr "https://kagamine.tech/shade/fixed_shaders.zip" -OutFile "$backupdir\custom-shaders\fixed_shaders.zip"
	Expand-Archive "$backupdir\custom-shaders\fixed_shaders.zip" "$backupdir\custom-shaders\"
	
	if (-not (Test-Path $backupdir\gshade-shaders) -or -not (Test-Path $backupdir\gshade-presets)){
		echo "Downloading GShade Shaders and Presets..."
		iwr "https://kagamine.tech/shade/gshade.zip" -OutFile "$backupdir\gshade.zip"
		Expand-Archive "$backupdir\gshade.zip" "$backupdir\" -Force
	}
}

#main
while (1){
	echo "Instructions on how to find the full path of your Final Fantasy XIV installation:"
	echo "https://gist.github.com/ry00001/3e2e63b986cb0c673645ea42ffafcc26#wheres-the-game-folder"
	echo "Thanks to rika (@lostkagamine) for providing the instructions which this script is based off of.`n`n"
	echo "Example: C:\Program Files (x86)\SquareEnix\FINAL FANTASY XIV - A Realm Reborn\game\"
	$installdir = Read-Host -Prompt "Please paste the path of your Final Fantasy XIV Installation here, and press enter"
	
	if (Test-Path "$installdir\ffxiv_dx11.exe"){
		$installdir = $installdir.TrimEnd('\')
		break
	}
	else{
		echo "`n`nInstallation path not found. Please try again."
		Read-Host "Press enter to continue..."
		Clear-Host
	}
}

#create folders
if (-not (Test-Path $backupdir)){
	mkdir "$backupdir" | Out-Null
}
else{
	rm -Recurse "$backupdir\*" | Out-Null
}

mkdir "$backupdir\installer" | Out-Null
mkdir "$backupdir\custom-shaders" | Out-Null

if ($gshadedir){
	BackupGShade
	DownloadStuff
	
	echo "`n`nUninstalling GShade. Please follow the uninstallation instructions in the window that appears."
	echo "DO NOT restart your computer when prompted."
	Start-Process -Wait "$gshadedir\GShade Uninstaller.exe"
}
else{
	DownloadStuff
}

#cleanup after gshade
echo "Cleaning up GShade..."

#only remove if dll is a gshade dll
if (Test-Path "$installdir\d3d11.dll"){
	if ($(Get-ItemProperty "$installdir\d3d11.dll" | Select-Object VersionInfo) -match "GShade"){
		rm "$installdir\d3d11.dll"
	}
}

#only remove if dll is a gshade dll
if (Test-Path "$installdir\dxgi.dll"){
	if ($(Get-ItemProperty "$installdir\dxgi.dll" | Select-Object VersionInfo) -match "GShade"){
		rm "$installdir\dxgi.dll"
	}
}

if (Test-Path "$installdir\gshade-presets"){
	rm -Recurse "$installdir\gshade-presets"
}

if (Test-Path "$installdir\gshade-addons"){
	rm -Recurse "$installdir\gshade-addons"
}

if (Test-Path "$env:PUBLIC\GShade Custom Shaders"){
	rm -Recurse "$env:PUBLIC\GShade Custom Shaders"
}

#install reshade and migrate
echo "`n`nInstalling ReShade. Please follow the installation instructions in the window that appears."
echo "The full path of the Final Fantasy XIV executable that you should be targeting is $installdir\ffxiv_dx11.exe"
Start-Process -Wait "$backupdir\installer\ReShade_Setup_Addon.exe"

echo "`n`nMigrating GShade stuff to ReShade..."
if (Test-Path "$installdir\reshade-shaders"){
	mv "$installdir\reshade-shaders" "$installdir\reshade-shaders_backup"
}

if (Test-Path "$installdir\reshade-presets"){
	mv "$installdir\reshade-presets" "$installdir\reshade-presets_backup"
}

#moving shaders
cp -Recurse "$backupdir\gshade-shaders" "$installdir\reshade-shaders"
cp -Force "$backupdir\custom-shaders\*.fx" "$installdir\reshade-shaders\shaders"
cp -Force "$backupdir\custom-shaders\*.fxh" "$installdir\reshade-shaders\shaders"

#moving presets
cp -Recurse "$backupdir\gshade-presets" "$installdir\reshade-presets"

echo "`n`nSetting texture and effect search paths in reshade.ini..."
$reshadeini = "$installdir\reshade.ini"
[System.Collections.ArrayList]$contents = Get-Content $reshadeini
$generalindex = ($contents | Select-String "\[GENERAL\]").LineNumber

$search1 = $contents | Select-String "EffectSearchPaths"
$search2 = $contents | Select-String "TextureSearchPaths"

if ($search1){
	$contents = $contents -replace "EffectSearchPaths.*$", "EffectSearchPaths=$installdir\reshade-shaders\**"
}
else{
	$contents.Insert($generalindex, "EffectSearchPaths=$installdir\reshade-shaders\**")
}

if ($search2){
	$contents = $contents -replace "TextureSearchPaths.*$", "TextureSearchPaths=$installdir\reshade-shaders\**"
	
}
else{
	$contents.Insert($generalindex, "TextureSearchPaths=$installdir\reshade-shaders\**")
}

$contents | Out-File "$reshadeini"

echo "`n`nDone! Launch the game and try it out!"
echo "`n`nIf you want to clean up the backup files, you can find them in these directories: "
echo "1. GShade Backup/Temp Folder: $backupdir (contains gshade-presets, gshade-shaders, ReShade installer and custom shaders (KeepUI etc.))"
echo "2. ReShade presets backup: $installdir\reshade-presets_backup"
echo "3. ReShade shaders backup: $installdir\reshade-shaders_backup"

if ($gshadedir){
	echo "`n`nIf you want to, you can also proceed to remove:"
	echo "1. The GShade folder located at $gshadedir since the uninstaller does not seem to do it."
	echo "2. The automated GShade backup files found at $env:PUBLIC\GShade Backups."
}
