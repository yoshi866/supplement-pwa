$src = "C:\Users\maika\suppl-app\make_icons.ps1"
$tmp = [System.IO.Path]::GetTempFileName() + ".ps1"
$txt = [System.IO.File]::ReadAllText($src, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($tmp, $txt, [System.Text.Encoding]::Unicode)
& powershell -NoProfile -ExecutionPolicy Bypass -File $tmp
