Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("c:\Users\Desktop\Projects\stira\assets\icon\app_icon.png")
$img.Save("c:\Users\Desktop\Projects\stira\assets\icon\app_icon_fixed.png", [System.Drawing.Imaging.ImageFormat]::Png)
$img.Dispose()
Move-Item "c:\Users\Desktop\Projects\stira\assets\icon\app_icon_fixed.png" "c:\Users\Desktop\Projects\stira\assets\icon\app_icon.png" -Force
echo "App icon fixed as true PNG."
