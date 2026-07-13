# Generates CodeRecall brand assets into assets/branding/ using System.Drawing.
# Run from the repo root:  powershell -File tool\branding\generate.ps1
# Then:  dart run flutter_launcher_icons && dart run flutter_native_splash:create

Add-Type -AssemblyName System.Drawing

$out = Join-Path $PSScriptRoot "..\..\assets\branding"
New-Item -ItemType Directory -Force $out | Out-Null

function New-Canvas([int]$size) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    return $bmp, $g
}

function Draw-Glyph($g, [int]$size, [System.Drawing.Color]$color, [double]$scale) {
    # "</>" glyph, centered. scale = glyph height relative to canvas.
    $fontSize = [float]($size * $scale)
    $font = New-Object System.Drawing.Font("Consolas", $fontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Object System.Drawing.SolidBrush($color)
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = [System.Drawing.StringAlignment]::Center
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center
    $rect = New-Object System.Drawing.RectangleF(0, 0, $size, $size)
    $g.DrawString("</>", $font, $brush, $rect, $fmt)
    $font.Dispose(); $brush.Dispose(); $fmt.Dispose()
}

$teal = [System.Drawing.Color]::FromArgb(255, 0, 105, 107)     # #00696B
$tealDark = [System.Drawing.Color]::FromArgb(255, 0, 54, 56)   # #003638
$white = [System.Drawing.Color]::White

# 1) Full legacy icon: gradient background + glyph (1024x1024)
$bmp, $g = New-Canvas 1024
$gradRect = New-Object System.Drawing.Rectangle(0, 0, 1024, 1024)
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($gradRect, $teal, $tealDark, 55.0)
$g.FillRectangle($grad, $gradRect)
Draw-Glyph $g 1024 $white 0.42
$bmp.Save((Join-Path $out "icon_full.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$grad.Dispose(); $g.Dispose(); $bmp.Dispose()

# 2) Adaptive-icon foreground: glyph on transparency, sized for the ~66% safe zone (1024x1024)
$bmp, $g = New-Canvas 1024
Draw-Glyph $g 1024 $white 0.30
$bmp.Save((Join-Path $out "icon_fg.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

# 3) Splash logo: glyph on transparency, Android-12 sizing (1152x1152, content in center 768 circle)
$bmp, $g = New-Canvas 1152
Draw-Glyph $g 1152 $white 0.26
$bmp.Save((Join-Path $out "splash_logo.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

Write-Output "Wrote icon_full.png, icon_fg.png, splash_logo.png to $out"
