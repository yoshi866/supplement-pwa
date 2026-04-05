Add-Type -AssemblyName System.Drawing

$outDir = "C:\Users\maika\suppl-app\icons"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function New-Icon {
    param([int]$size, [string]$filePath, [bool]$maskable = $false)

    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode   = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    # ── 背景 ──
    $bgColor = [System.Drawing.Color]::FromArgb(255, 15, 23, 42)  # #0f172a
    $g.Clear($bgColor)

    if ($maskable) {
        # maskable: 全面塗りつぶし（セーフゾーン内にデザイン）
        $accentBrush = New-Object System.Drawing.SolidBrush(
            [System.Drawing.Color]::FromArgb(255, 99, 102, 241))
        $g.FillRectangle($accentBrush, 0, 0, $size, $size)
        $accentBrush.Dispose()
    } else {
        # 角丸背景
        $r    = [int]($size * 0.22)
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $path.AddArc(0, 0, $r*2, $r*2, 180, 90)
        $path.AddArc($size - $r*2, 0, $r*2, $r*2, 270, 90)
        $path.AddArc($size - $r*2, $size - $r*2, $r*2, $r*2, 0, 90)
        $path.AddArc(0, $size - $r*2, $r*2, $r*2, 90, 90)
        $path.CloseFigure()

        $bgBrush = New-Object System.Drawing.SolidBrush(
            [System.Drawing.Color]::FromArgb(255, 30, 41, 59))  # #1e293b
        $g.FillPath($bgBrush, $path)
        $bgBrush.Dispose()
        $path.Dispose()
    }

    # ── カプセル（薬）を描く ──
    $margin  = if ($maskable) { [int]($size * 0.28) } else { [int]($size * 0.22) }
    $inner   = $size - $margin * 2
    $capW    = [int]($inner * 0.65)
    $capH    = [int]($inner * 0.30)
    $capX    = $margin + [int](($inner - $capW) / 2)
    $capY    = $margin + [int](($inner - $capH) / 2) - [int]($size * 0.04)
    $capR    = $capH  # 完全な半円にする

    # カプセル左半分 (インディゴ)
    $indBrush = New-Object System.Drawing.SolidBrush(
        [System.Drawing.Color]::FromArgb(255, 99, 102, 241))   # #6366f1
    $capPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $capPath.AddArc($capX, $capY, $capR, $capH, 90, 180)
    $capPath.AddLine($capX + $capR/2, $capY, $capX + $capW - $capR/2, $capY)
    $capPath.AddLine($capX + $capW/2, $capY, $capX + $capW/2, $capY + $capH)
    $capPath.AddLine($capX + $capW/2, $capY + $capH, $capX + $capR/2, $capY + $capH)
    $capPath.CloseFigure()
    $g.FillPath($indBrush, $capPath)
    $indBrush.Dispose()
    $capPath.Dispose()

    # カプセル右半分 (シアン)
    $cyanBrush = New-Object System.Drawing.SolidBrush(
        [System.Drawing.Color]::FromArgb(255, 34, 211, 238))   # #22d3ee
    $capPath2 = New-Object System.Drawing.Drawing2D.GraphicsPath
    $capPath2.AddLine($capX + $capW/2, $capY, $capX + $capW - $capR/2, $capY)
    $capPath2.AddArc($capX + $capW - $capR, $capY, $capR, $capH, 270, 180)
    $capPath2.AddLine($capX + $capW - $capR/2, $capY + $capH, $capX + $capW/2, $capY + $capH)
    $capPath2.CloseFigure()
    $g.FillPath($cyanBrush, $capPath2)
    $cyanBrush.Dispose()
    $capPath2.Dispose()

    # カプセル中央の境界線（白）
    $whitePen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, [float]($size * 0.014))
    $g.DrawLine($whitePen, $capX + $capW/2, $capY + 1, $capX + $capW/2, $capY + $capH - 1)
    $whitePen.Dispose()

    # ── 下部テキスト「サプリ」── (小さいサイズでは省略)
    if ($size -ge 256) {
        $txtSize  = [int]($size * 0.105)
        $font     = New-Object System.Drawing.Font("Yu Gothic UI", $txtSize,
                        [System.Drawing.FontStyle]::Bold)
        $txtBrush = New-Object System.Drawing.SolidBrush(
                        [System.Drawing.Color]::FromArgb(200, 148, 163, 184))
        $txtY     = $capY + $capH + [int]($size * 0.06)
        $sf = New-Object System.Drawing.StringFormat
        $sf.Alignment = [System.Drawing.StringAlignment]::Center
        $g.DrawString("サプリ", $font, $txtBrush,
            [System.Drawing.RectangleF]::new(0, $txtY, $size, $size - $txtY), $sf)
        $font.Dispose(); $txtBrush.Dispose(); $sf.Dispose()
    }

    $g.Dispose()
    $bmp.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "  生成: $filePath ($size x $size)" -ForegroundColor Gray
}

Write-Host "アイコン生成中..." -ForegroundColor Cyan
New-Icon -size 192  -filePath "$outDir\icon-192.png"  -maskable $false
New-Icon -size 512  -filePath "$outDir\icon-512.png"  -maskable $false
New-Icon -size 512  -filePath "$outDir\icon-maskable.png" -maskable $true
Write-Host "完了" -ForegroundColor Green
