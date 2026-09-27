# Original typographic Workshop cover; no third-party artwork or game changes.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$taskOutput = Join-Path $PSScriptRoot '../release/workshop/preview.png'
$taskBitmap = [System.Drawing.Bitmap]::new(1024, 576)
$taskGraphics = [System.Drawing.Graphics]::FromImage($taskBitmap)
$taskGraphics.SmoothingMode = 'AntiAlias'
$taskGraphics.TextRenderingHint = 'AntiAliasGridFit'
$taskBounds = [System.Drawing.Rectangle]::new(0, 0, 1024, 576)
$taskBackground = [System.Drawing.Drawing2D.LinearGradientBrush]::new($taskBounds, [System.Drawing.Color]::FromArgb(13,28,29), [System.Drawing.Color]::FromArgb(38,28,18), 25)
$taskGraphics.FillRectangle($taskBackground, $taskBounds)
$taskGold = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(237,194,116))
$taskLight = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(230,229,209))
$taskMuted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(162,172,157))
$taskForest = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(30,55,44))
for ($i=0; $i -lt 14; $i++) {
    $x = $i * 84 - 25
    $h = 90 + ($i % 4) * 23
    $points = [System.Drawing.Point[]]@([System.Drawing.Point]::new($x,560), [System.Drawing.Point]::new($x+43,560-$h), [System.Drawing.Point]::new($x+86,560))
    $taskGraphics.FillPolygon($taskForest, $points)
}
$taskBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(156,119,60), 2)
$taskGraphics.DrawRectangle($taskBorder, 24, 24, 975, 527)
$taskFormat = [System.Drawing.StringFormat]::new()
$taskFormat.Alignment = 'Center'
$taskFont = [System.Drawing.Font]::new('Georgia', 98, [System.Drawing.FontStyle]::Bold)
$taskSubFont = [System.Drawing.Font]::new('Segoe UI', 28, [System.Drawing.FontStyle]::Bold)
$taskEditionFont = [System.Drawing.Font]::new('Segoe UI', 23)
$taskSmallFont = [System.Drawing.Font]::new('Segoe UI', 15)
$taskGraphics.DrawString('ENFOS', $taskFont, $taskGold, [System.Drawing.RectangleF]::new(30,104,964,160), $taskFormat)
$taskGraphics.DrawString('TEAM SURVIVAL', $taskSubFont, $taskLight, [System.Drawing.RectangleF]::new(30,276,964,52), $taskFormat)
$taskGraphics.DrawLine($taskBorder, 335, 348, 689, 348)
$taskGraphics.DrawString('SametC Edition', $taskEditionFont, $taskGold, [System.Drawing.RectangleF]::new(30,367,964,50), $taskFormat)
$taskGraphics.DrawString('V1.0.0  /  DOTA 2 CUSTOM GAME', $taskSmallFont, $taskMuted, [System.Drawing.RectangleF]::new(30,453,964,36), $taskFormat)
$taskBitmap.Save($taskOutput, [System.Drawing.Imaging.ImageFormat]::Png)
foreach ($taskResource in @($taskGraphics,$taskBitmap,$taskBackground,$taskGold,$taskLight,$taskMuted,$taskForest,$taskBorder,$taskFormat,$taskFont,$taskSubFont,$taskEditionFont,$taskSmallFont)) { $taskResource.Dispose() }
Write-Output $taskOutput
