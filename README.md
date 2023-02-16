# Purpose
This script is largely based on the GShade -> ReShade migration instructions provided by [rika](https://twitter.com/lostkagamine), which can be found here: 
https://gist.github.com/ry00001/3e2e63b986cb0c673645ea42ffafcc26

This repository contains a PowerShell script to automatically migrate GShade to ReShade for FFXIV. This has only been tested in PowerShell 7, but it *should* work with older versions of PowerShell.

This script will also work if you have uninstalled GShade previously.

Note: Please *do not* restart your computer when prompted to do so by the GShade uninstaller.

# What Does This Do?
## If GShade is still installed:
1. Backs up the gshade-presets and gshade-shaders folder to {YOUR USER PROFILE}\gshade-backup.
2. Downloads ReShade 5.6.0 + addons and necessary/custom shaders.
3. Runs the GShade uninstaller.
4. Runs the ReShade installer.
5. Moves the GShade backup files into the appropriate location, as well as the various shader files.
6. Modifies the default ReShade.ini file to set the EffectSearchPaths and TextureSearchPaths.

## If you have already uninstalled GShade:
1. Downloads ReShade 5.6.0 + addons, necessary/custom shaders and gshade-presets/shaders.
2. Runs the ReShade installer.
3. Moves the downloaded GShade folders into the appropriate location, as well as the various shader files.
4. Modifies the default ReShade.ini file to set the EffectSearchPaths and TextureSearchPaths.

**Note - the zip file containing the custom shaders may be flagged as malware by Windows Defender (it didn't for me). The file is safe according to [VirusTotal](https://www.virustotal.com/gui/file/84bb9c44c60f9a2d4f146d95c2661be91529fe3ab0469c718bfa80bb6006bd9e/detection), though.**

# How To Use
1. Download the script by clicking on the green code button, then clicking on Download Zip.
	
	![image](https://user-images.githubusercontent.com/50959479/217788175-bbbb478a-3ba6-4170-8e73-0ce23a2719e4.png)

2. Extract the `gshade-migration-main` folder anywhere you like.
3. Navigate into the `gshade-migration-main` folder, then hold down Shift and right click, then click on "Open PowerShell Window here".
	
	![image](https://user-images.githubusercontent.com/50959479/217268541-b8f83957-2823-4d72-b258-1fce1c0dfe58.png)

3. Run the script by typing in `.\gshade-migration.ps1` in the console window.
	
	![image](https://user-images.githubusercontent.com/50959479/217268966-39c55952-ec22-4724-9bc9-7dc002fb376b.png)

4. Follow the instructions provided in the console window.
