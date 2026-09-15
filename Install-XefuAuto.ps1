<#
    XefuAuto - installer
    Copies the scripts and the original xefu files to an Xbox 360 (Aurora)
    over FTP.

    Simple use:    double-click Install.bat and type the console IP
    Advanced use:  .\Install-XefuAuto.ps1 -Ip 192.168.0.10 -Quiet
#>
param(
    [string]$Ip = "",
    [string]$User = "xboxftp",
    [string]$Password = "xboxftp",
    [switch]$Quiet,
    [switch]$SkipXefu
)

$ErrorActionPreference = "Stop"
$Base = Split-Path -Parent $MyInvocation.MyCommand.Path

function Say($txt, $color = "Gray") { Write-Host $txt -ForegroundColor $color }

Say ""
Say "  ============================================" Cyan
Say "   XefuAuto - automatic per-game xefu" Cyan
Say "  ============================================" Cyan
Say ""

if (-not $Ip) {
    $Ip = Read-Host "Console IP (e.g. 192.168.0.10)"
}
if (-not $Ip) { Say "No IP given. Exiting." Red; exit 1 }

# ---------- FTP ----------
function Send-File($localPath, $ftpTarget) {
    $uri = "ftp://$Ip$ftpTarget"
    for ($t = 1; $t -le 3; $t++) {
        try {
            $req = [System.Net.FtpWebRequest]::Create($uri)
            $req.Credentials = New-Object System.Net.NetworkCredential($User, $Password)
            $req.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
            $req.UseBinary = $true
            $req.UsePassive = $true
            $req.KeepAlive = $false
            $req.Timeout = 30000
            $bytes = [System.IO.File]::ReadAllBytes($localPath)
            $req.ContentLength = $bytes.Length
            $s = $req.GetRequestStream()
            $s.Write($bytes, 0, $bytes.Length)
            $s.Close()
            $resp = $req.GetResponse()
            $resp.Close()
            return $true
        } catch {
            if ($t -eq 3) { Say "   FAILED: $ftpTarget -- $($_.Exception.Message)" Red; return $false }
            Start-Sleep -Milliseconds 800
        }
    }
    return $false
}

function New-FtpFolder($ftpTarget) {
    try {
        $req = [System.Net.FtpWebRequest]::Create("ftp://$Ip$ftpTarget")
        $req.Credentials = New-Object System.Net.NetworkCredential($User, $Password)
        $req.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
        $req.UsePassive = $true
        $req.KeepAlive = $false
        $req.Timeout = 15000
        $resp = $req.GetResponse(); $resp.Close()
    } catch { }   # already exists: fine
}

# ---------- connection test ----------
Say "Connecting to $Ip ..." Yellow
try {
    $req = [System.Net.FtpWebRequest]::Create("ftp://$Ip/")
    $req.Credentials = New-Object System.Net.NetworkCredential($User, $Password)
    $req.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $req.UsePassive = $true; $req.KeepAlive = $false; $req.Timeout = 15000
    $resp = $req.GetResponse(); $resp.Close()
    Say "   connected." Green
} catch {
    Say "   COULD NOT CONNECT: $($_.Exception.Message)" Red
    Say ""
    Say "   Check that:" Yellow
    Say "   - the console is on and sitting on the Aurora dash (not in a game)"
    Say "   - the IP is correct (Aurora shows it under Settings > Network)"
    Say "   - the FTP user/password are right (default xboxftp/xboxftp)"
    exit 1
}

# ---------- 1. xefu files ----------
$xefuTarget = "/HddX/Compatibility/XefuBackup"
if (-not $SkipXefu) {
    $xefuDir = Join-Path $Base "Xefu"
    if (Test-Path $xefuDir) {
        Say ""
        Say "1) Sending original xefu files (this can take a few minutes)..." Yellow
        New-FtpFolder $xefuTarget
        $files = Get-ChildItem $xefuDir -Filter *.xex | Sort-Object Name
        $i = 0
        foreach ($a in $files) {
            $i++
            Write-Host ("   [{0}/{1}] {2} " -f $i, $files.Count, $a.Name) -NoNewline
            if (Send-File $a.FullName "$xefuTarget/$($a.Name)") {
                Write-Host "ok" -ForegroundColor Green
            }
        }
    }
} else {
    Say ""
    Say "1) Xefu files: skipped (-SkipXefu)" DarkGray
}

# ---------- 2. scripts ----------
Say ""
Say "2) Sending Aurora scripts..." Yellow
New-FtpFolder "/Game/User/Scripts/Content"
New-FtpFolder "/Game/User/Scripts/Content/Subtitles"
New-FtpFolder "/Game/User/Scripts/Utility"
New-FtpFolder "/Game/User/Scripts/Utility/XefuAuto"

$map = @(
    @{ L = "Aurora\User\Scripts\Content\Subtitles\XefuAuto.lua"; R = "/Game/User/Scripts/Content/Subtitles/XefuAuto.lua" },
    @{ L = "Aurora\User\Scripts\Utility\XefuAuto\Main.lua";      R = "/Game/User/Scripts/Utility/XefuAuto/Main.lua" },
    @{ L = "Aurora\User\Scripts\Utility\XefuAuto\MenuSystem.lua"; R = "/Game/User/Scripts/Utility/XefuAuto/MenuSystem.lua" },
    @{ L = "Aurora\User\Scripts\Utility\XefuAuto\icon.png";      R = "/Game/User/Scripts/Utility/XefuAuto/icon.png" }
)
foreach ($m in $map) {
    $local = Join-Path $Base $m.L
    if (-not (Test-Path $local)) { Say "   MISSING from package: $($m.L)" Red; continue }
    Write-Host "   $(Split-Path $m.R -Leaf) " -NoNewline
    if (Send-File $local $m.R) { Write-Host "ok" -ForegroundColor Green }
}

# ---------- 3. enabled by default ----------
# XefuAuto ships enabled; it only turns off if xefu_auto_off.txt exists
# (created by the panel under Back > Scripts > Xefu Auto).

# ---------- done ----------
Say ""
Say "  ============================================" Cyan
Say "   INSTALLED!" Green
Say "  ============================================" Cyan
Say ""
Say "  One last step on the console (only once):" Yellow
Say ""
Say "   1. Restart Aurora"
Say "   2. Pick any Xbox Classic game, press Y then A,"
Say "      and choose the 'xefu: ...' line"
Say ""
Say "  That's it. From then on the xefu switches by itself," Green
Say "  following whichever game you select in the list." Green
Say ""
Say "  To turn it on/off: Back > Scripts > Xefu Auto" DarkGray
Say ""
if (-not $Quiet) { Read-Host "Press Enter to exit" }
