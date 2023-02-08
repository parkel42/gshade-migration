$gshadereg = "HKLM:\SOFTWARE\GShade"

if (-not (Test-Path $gshadereg)){
	echo "`n`nGShade is not installed or is already uninstalled. You do not need to run this script."
	Read-Host -Prompt "Press enter to exit."
	exit
}

while (1){
	echo "Instructions on how to find the full path of your Final Fantasy XIV installation:"
	echo "https://gist.github.com/ry00001/3e2e63b986cb0c673645ea42ffafcc26#wheres-the-game-folder"
	echo "Thanks to rika (@lostkagamine) for providing the instructions which this script is based off of.`n`n"
	echo "Example: C:\Program Files (x86)\SquareEnix\FINAL FANTASY XIV - A Realm Reborn\game\"
	$installdir = Read-Host -Prompt "Please paste the path of your Final Fantasy XIV Installation here, and press enter"
	
	if (Test-Path $installdir){
		$installdir = $installdir.TrimEnd('game\')
		break
	}
	else{
		echo "`n`nInstallation path not found. Please try again."
		Read-Host -Prompt "Press enter to continue..."
		Clear-Host
	}
}

echo "`n`nBacking up gshade-presets and gshade-shaders..."
$backupdir = "$env:USERPROFILE\gshade-backup\"

if (-not (Test-Path $backupdir)){
	mkdir "$backupdir"
	mkdir "$backupdir\installer"
	mkdir "$backupdir\custom-shaders"
	cp -Recurse "C:\Program Files\GShade\gshade-shaders" "$backupdir"
	cp -Recurse "$installdir\game\gshade-presets" "$backupdir"
}
else{
	rm -Recurse "$backupdir\*"
	mkdir "$backupdir\installer"
	mkdir "$backupdir\custom-shaders"
	cp -Recurse "C:\Program Files\Gshade\gshade-shaders" "$backupdir"
	cp -Recurse "$installdir\game\gshade-presets" "$backupdir"
}

echo "`n`nUninstalling GShade. Please follow the uninstallation instructions in the window that appears."
echo "DO NOT restart your computer when prompted."
Start-Process -Wait "C:\Program Files\GShade\GShade Uninstaller.exe"

echo "Cleaning up after GShade..."

if (Test-Path $installdir\game\d3d11.dll){
	rm "$installdir\game\d3d11.dll"
}

if (Test-Path $installdir\game\dxgi.dll){
	rm "$installdir\game\dxgi.dll"
}

if (Test-Path $installdir\game\gshade-presets){
	rm -Recurse "$installdir\game\gshade-presets"
}

if (Test-Path $installdir\game\gshade-addons){
	rm -Recurse "$installdir\game\gshade-addons"
}

echo "`n`nDownloading ReShade and other shaders. This process may take a while, you can go grab a coffee in the meantime!`n"
echo "Downloading ReShade 5.6.0..."
iwr "http://static.reshade.me/downloads/ReShade_Setup_5.6.0_Addon.exe" -OutFile "$backupdir\installer\ReShade_Setup_5.6.0_Addon.exe"
echo "Downloading KeepUI.fx..."
iwr "https://cdn.discordapp.com/attachments/1072202729692340245/1072202794494333038/KeepUI.fx" -OutFile "$backupdir\custom-shaders\KeepUI.fx"
echo "Downloading Tools.fxh, Canvas.fxh and Stats.fxh..."
iwr "https://cdn.discordapp.com/attachments/1072202729692340245/1072293221763403816/tools_shaders_canvas.zip" -OutFile "$backupdir\custom-shaders\tools_shaders_canvas.zip"

Expand-Archive "$backupdir\custom-shaders\tools_shaders_canvas.zip" "$backupdir\custom-shaders\"

echo "`n`nInstalling ReShade. Please follow the installation instructions in the window that appears."
echo "The full path of the Final Fantasy XIV executable that you should be targeting is $installdir\game\ffxiv_dx11.exe"
Start-Process -Wait "$backupdir\installer\ReShade_Setup_5.6.0_Addon.exe"

echo "`n`nMigrating GShade stuff to ReShade..."
if (Test-Path "$installdir\game\reshade-shaders"){
	mv "$installdir\game\reshade-shaders" "$installdir\game\reshade-shaders_backup"
	cp -Recurse "$backupdir\gshade-shaders" "$installdir\game\reshade-shaders"
	cp "$backupdir\custom-shaders\*.fx" "$installdir\game\reshade-shaders\shaders"
	cp "$backupdir\custom-shaders\*.fxh" "$installdir\game\reshade-shaders\shaders"
}
else{
	cp -Recurse "$backupdir\gshade-shaders" "$installdir\game\reshade-shaders"
	cp "$backupdir\custom-shaders\*.fx" "$installdir\game\reshade-shaders\shaders"
	cp "$backupdir\custom-shaders\*.fxh" "$installdir\game\reshade-shaders\shaders"
}

if (Test-Path "$installdir\game\reshade-presets"){
	mv "$installdir\game\reshade-presets" "$installdir\game\reshade-presets_backup"
	cp -Recurse "$backupdir\gshade-presets" "$installdir\game\reshade-presets"
}
else{
	cp -Recurse "$backupdir\gshade-presets" "$installdir\game\reshade-presets"
}

echo "`n`nSetting texture and effect search paths in reshade.ini..."
$reshadeini = "$installdir\game\reshade.ini"
$contents = Get-Content $reshadeini
$contents -replace "SearchPaths.*$", "SearchPaths=$installdir\game\reshade-shaders\**" | Out-File $reshadeini

echo "`n`nDone! Launch the game and try it out!"
echo "`n`nIf you want to clean up the backup files, you can find them in these directories: "
echo "GShade Backup: $backupdir (contains gshade-presets, gshade-shaders, ReShade installer and custom shaders (KeepUI etc.))"
echo "ReShade presets backup: $installdir\game\reshade-presets_backup"
echo "ReShade shaders backup: $installdir\game\reshade-shaders_backup"

echo "`n`nIf you want to, you can remove the GShade folder located at C:\Program Files\GShade since the uninstaller does not seem to do it."
