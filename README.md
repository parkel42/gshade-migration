# Purpose
PowerShell script to automatically migrate GShade to ReShade for FFXIV. This has only been tested in PowerShell 7, but it *should* work with older versions of PowerShell.

This script is largely based on the GShade -> ReShade migration instructions provided by [rika](https://twitter.com/lostkagamine), which can be found here: 
https://gist.github.com/ry00001/3e2e63b986cb0c673645ea42ffafcc26

# What Does This Do?
1. Backs up the gshade-presets and gshade-shaders folder to {YOUR USER PROFILE}\gshade-backup.
2. Runs the GShade uninstaller.
3. Downloads ReShade 5.6.0 + addons, KeepUI.fx, Tools.fxh, Canvas.fxh and Stats.fxh.
4. Runs the ReShade installer.
5. Moves the GShade backup files into the appropriate location, as well as the various shader files.
6. Modifies the default ReShade.ini file to set the EffectSearchPaths and TextureSearchPaths.

# How To Use
1. Download the script and save it somewhere on your computer.
2. Navigate to the download location using File Explorer, then hold down Shift and right click, then click on "Open PowerShell Window" here.
3. Run the script by typing in ./gshade-migration.ps1.
4. Follow the instructions provided in the console window.
