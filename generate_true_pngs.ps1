Add-Type -AssemblyName System.Drawing
$img = New-Object System.Drawing.Bitmap(192, 192)
$gfx = [System.Drawing.Graphics]::FromImage($img)
$gfx.Clear([System.Drawing.Color]::Purple)
$gfx.Dispose()
$mipmaps = Get-ChildItem "C:\Users\Desktop\Projects\stira\android\app\src\main\res\mipmap-*" -Directory
foreach($dir in $mipmaps) {
    $img.Save((Join-Path $dir.FullName "ic_calculator.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $img.Save((Join-Path $dir.FullName "ic_finance.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $img.Save((Join-Path $dir.FullName "ic_notes.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $img.Save((Join-Path $dir.FullName "ic_weather.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $img.Save((Join-Path $dir.FullName "ic_launcher.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $img.Save((Join-Path $dir.FullName "launcher_icon.png"), [System.Drawing.Imaging.ImageFormat]::Png)
}
$img.Dispose()
echo "True PNG icons generated successfully."
