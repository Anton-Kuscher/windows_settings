# Set-ExecutionPolicy RemoteSigned
Add-Type -AssemblyName System.Drawing

# Get current wallpaper path from registry
$wallpaperPath = (Get-ItemProperty -Path 'HKCU:\Control Panel\Desktop').Wallpaper

# Load, rotate 180°, save
$img = [System.Drawing.Image]::FromFile($wallpaperPath)
$img.RotateFlip([System.Drawing.RotateFlipType]::Rotate180FlipNone)
$rotatedPath = "$env:TEMP\wallpaper_rotated.jpg"
$img.Save($rotatedPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$img.Dispose()

# Re-apply as wallpaper via Win32 API
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
$SPI_SETDESKWALLPAPER = 0x0014
$SPIF_UPDATEINIFILE = 0x01
$SPIF_SENDCHANGE = 0x02
[Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $rotatedPath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)