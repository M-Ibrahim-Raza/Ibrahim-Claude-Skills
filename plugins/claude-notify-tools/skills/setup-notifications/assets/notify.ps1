# claude-notify - Claude Code notification hook (Windows, Windows PowerShell 5.1+)
#
# Hook mode   : Claude Code pipes the hook JSON on stdin.
#               powershell.exe -NoProfile -ExecutionPolicy Bypass -File notify.ps1
# Test mode   : notify.ps1 -Test done|needs|error   (bypasses filters, prints what happened)
# Direct mode : notify.ps1 -Title .. -Body .. -Kind done|needs|error -Channels desktop,sound [-SkipIfFocused]
#               (used by notify.sh under WSL / Git Bash, and internally to play alerts in the background)
#
# Settings live in notify.conf next to this script and are re-read on every call.
# Kill switch: $env:CLAUDE_NOTIFY = '0'.  Bypass filters for piped test JSON: $env:CLAUDE_NOTIFY_FORCE = '1'.
# Never blocks Claude: always exits 0 and prints nothing in hook mode.

param(
    [string]$Title,
    [string]$Body,
    [string]$Kind,
    [string]$Channels,
    [string]$Volume,
    [string]$SoundFile,
    [switch]$SkipIfFocused,
    [string]$Test,
    [string]$Payload
)

$ErrorActionPreference = 'SilentlyContinue'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfPath = Join-Path $ScriptDir 'notify.conf'
$StateDir = Join-Path ([IO.Path]::GetTempPath()) 'claude-notify'
$LogPath = Join-Path $StateDir 'notify.log'
$TestMode = [bool]$Test
$Script:Debug = $false

# ---------------------------------------------------------------- helpers
function Get-Conf([string]$Key, [string]$Default) {
    if (-not (Test-Path -LiteralPath $ConfPath)) { return $Default }
    $val = $null
    foreach ($line in [IO.File]::ReadAllLines($ConfPath)) {
        if ($line -match "^\s*$([regex]::Escape($Key))\s*=(.*)$") {
            $val = ($Matches[1] -replace '\s+#.*$', '').Trim()
        }
    }
    if ([string]::IsNullOrEmpty($val)) { return $Default }
    return $val
}
function Test-True([string]$v) { return @('true', '1', 'yes', 'on') -contains "$v".Trim().ToLower() }
function Write-Log([string]$msg) {
    if ($Script:Debug -or $TestMode) {
        try {
            New-Item -ItemType Directory -Force -Path $StateDir | Out-Null
            Add-Content -LiteralPath $LogPath -Value ("{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg) -Encoding UTF8
        } catch {}
    }
    if ($TestMode) { Write-Output $msg }
}
function Get-Now { return [int64][DateTimeOffset]::UtcNow.ToUnixTimeSeconds() }
function Limit-Text([string]$s, [int]$n) {
    if ($n -le 0 -or -not $s) { return '' }
    $s = ($s -replace '[\r\n\t]+', ' ').Trim()
    if ($s.Length -gt $n) { return $s.Substring(0, $n) + [char]0x2026 }
    return $s
}
function Get-Prop($obj, [string]$name) {
    if ($null -eq $obj) { return '' }
    $p = $obj.PSObject.Properties[$name]
    if ($null -eq $p -or $null -eq $p.Value) { return '' }
    return [string]$p.Value
}

# ---------------------------------------------------------------- focus detection
function Test-TerminalFocused {
    try {
        if (-not ('CNWin32' -as [type])) {
            Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class CNWin32 {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint pid);
}
'@
        }
        $fgPid = [uint32]0
        [void][CNWin32]::GetWindowThreadProcessId([CNWin32]::GetForegroundWindow(), [ref]$fgPid)
        if ($fgPid -eq 0) { return $false }

        # 1) Is the focused window's process an ancestor of this hook? (works for native Windows sessions)
        $parents = @{}
        foreach ($p in (Get-CimInstance Win32_Process -Property ProcessId, ParentProcessId)) { $parents[[uint32]$p.ProcessId] = [uint32]$p.ParentProcessId }
        $cur = [uint32]$PID
        for ($i = 0; $i -lt 50 -and $cur -ne 0; $i++) {
            if ($cur -eq $fgPid) { return $true }
            if (-not $parents.ContainsKey($cur)) { break }
            $cur = $parents[$cur]
        }

        # 2) Called from WSL/Git Bash (-SkipIfFocused): the process tree doesn't cross into the
        #    terminal, so fall back to "is a terminal or IDE the foreground app".
        if ($SkipIfFocused) {
            $name = (Get-Process -Id $fgPid).ProcessName.ToLower()
            $terms = @('windowsterminal', 'openconsole', 'conhost', 'code', 'code - insiders', 'cursor', 'windsurf',
                'wezterm-gui', 'alacritty', 'mintty', 'tabby', 'hyper', 'warp', 'idea64', 'pycharm64', 'webstorm64', 'rider64')
            if ($terms -contains $name) { return $true }
        }
    } catch {}
    return $false
}

function Test-QuietHours([string]$range) {
    if (-not $range -or $range -notmatch '^\s*(\d{1,2}):?(\d{2})\s*-\s*(\d{1,2}):?(\d{2})\s*$') { return $false }
    $s = [int]$Matches[1] * 100 + [int]$Matches[2]
    $e = [int]$Matches[3] * 100 + [int]$Matches[4]
    $c = [int](Get-Date -Format 'HHmm')
    if ($s -le $e) { return ($c -ge $s -and $c -lt $e) }
    return ($c -ge $s -or $c -lt $e)
}

# ---------------------------------------------------------------- channels
function Send-Desktop([string]$t, [string]$b) {
    # 1) Native WinRT toast (Windows PowerShell 5.1), shown under the "Windows PowerShell" app id.
    try {
        [void][Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
        [void][Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
        $xml = "<toast><visual><binding template='ToastGeneric'><text>{0}</text><text>{1}</text></binding></visual><audio silent='true'/></toast>" -f `
            [Security.SecurityElement]::Escape($t), [Security.SecurityElement]::Escape($b)
        $doc = New-Object Windows.Data.Xml.Dom.XmlDocument
        $doc.LoadXml($xml)
        $toast = New-Object Windows.UI.Notifications.ToastNotification $doc
        $appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
        return 'toast'
    } catch {}
    # 2) BurntToast module, if installed (works in PowerShell 7 too).
    try {
        if (Get-Module -ListAvailable -Name BurntToast) {
            Import-Module BurntToast -ErrorAction Stop
            New-BurntToastNotification -Text $t, $b -Silent -ErrorAction Stop
            return 'burnttoast'
        }
    } catch {}
    # 3) Legacy balloon tip.
    try {
        Add-Type -AssemblyName System.Windows.Forms, System.Drawing
        $n = New-Object System.Windows.Forms.NotifyIcon
        $n.Icon = [System.Drawing.SystemIcons]::Information
        $n.BalloonTipTitle = $t
        $n.BalloonTipText = $(if ($b) { $b } else { ' ' })
        $n.Visible = $true
        $n.ShowBalloonTip(6000)
        Start-Sleep -Seconds 6
        $n.Dispose()
        return 'balloon'
    } catch {}
    throw 'no desktop notification method worked'
}

function Send-Sound([string]$file, [double]$vol) {
    if (-not (Test-Path -LiteralPath $file)) { throw "sound file not found: $file" }
    # MediaPlayer honours volume; SoundPlayer is the always-available fallback (full volume).
    if ($vol -lt 0.99) {
        try {
            Add-Type -AssemblyName PresentationCore
            $mp = New-Object System.Windows.Media.MediaPlayer
            $mp.Volume = $vol
            $mp.Open([Uri]$file)
            $mp.Play()
            Start-Sleep -Milliseconds 1400
            $mp.Close()
            return 'mediaplayer'
        } catch {}
    }
    $sp = New-Object System.Media.SoundPlayer $file
    $sp.PlaySync()
    return 'soundplayer'
}

function Send-Ntfy([string]$t, [string]$b, [string]$priority, [string]$tags) {
    $topic = $env:CLAUDE_NOTIFY_NTFY_TOPIC
    if (-not $topic) { $topic = Get-Conf 'ntfy_topic' '' }
    if (-not $topic) { throw 'no topic (set CLAUDE_NOTIFY_NTFY_TOPIC or ntfy_topic)' }
    $server = (Get-Conf 'ntfy_server' 'https://ntfy.sh').TrimEnd('/')
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    # HTTP headers must be ASCII: emoji travel as ntfy Tags instead.
    $asciiTitle = ($t -replace '[^\x20-\x7E]', '').Trim()
    $headers = @{ Title = $asciiTitle; Priority = $priority; Tags = $tags }
    if ($env:CLAUDE_NOTIFY_NTFY_TOKEN) { $headers['Authorization'] = "Bearer $($env:CLAUDE_NOTIFY_NTFY_TOKEN)" }
    $msg = $(if ($b) { $b } else { $asciiTitle })
    Invoke-RestMethod -Method Post -Uri "$server/$topic" -Headers $headers -TimeoutSec 8 `
        -ContentType 'text/plain; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($msg)) | Out-Null
    return 'ntfy'
}

function Invoke-Channels($a) {
    # $a: hashtable with Title, Body, NtfyTitle, Kind, Channels(array), Volume, SoundFile, Priority, Tags
    foreach ($c in $a.Channels) {
        try {
            switch ($c) {
                'desktop' { $how = Send-Desktop $a.Title $a.Body; Write-Log "sent: desktop ($how)" }
                'sound' { $how = Send-Sound $a.SoundFile ([double]$a.Volume); Write-Log "sent: sound ($how)" }
                'ntfy' { [void](Send-Ntfy $a.NtfyTitle $a.Body $a.Priority $a.Tags); Write-Log 'sent: ntfy' }
            }
        } catch { Write-Log "failed: $c - $($_.Exception.Message)" }
    }
}

function Get-SoundFile([string]$k) {
    switch ($k) {
        'needs' { return (Get-Conf 'sound_needs_you' (Join-Path $ScriptDir 'sounds\needs-you.wav')) }
        'error' { return (Get-Conf 'sound_error' (Join-Path $ScriptDir 'sounds\error.wav')) }
        default { return (Get-Conf 'sound_done' (Join-Path $ScriptDir 'sounds\done.wav')) }
    }
}

# ---------------------------------------------------------------- main
function Main {
    $Script:Debug = Test-True (Get-Conf 'debug' 'false')

    # Background worker: payload written by hook mode below.
    if ($Payload) {
        try {
            $p = Get-Content -LiteralPath $Payload -Raw -Encoding UTF8 | ConvertFrom-Json
            Remove-Item -LiteralPath $Payload -Force
            $a = @{ Title = $p.Title; Body = $p.Body; NtfyTitle = $p.NtfyTitle; Kind = $p.Kind; Channels = @($p.Channels)
                Volume = $p.Volume; SoundFile = $p.SoundFile; Priority = $p.Priority; Tags = $p.Tags }
            Invoke-Channels $a
        } catch { Write-Log "payload worker failed: $($_.Exception.Message)" }
        return
    }

    # Direct mode (from notify.sh on WSL / Git Bash): local channels only, filters already applied.
    if ($Title) {
        $chans = @(($Channels -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        if ($SkipIfFocused -and (Test-TerminalFocused)) {
            $chans = @($chans | Where-Object { $_ -ne 'desktop' -and $_ -ne 'sound' })
            Write-Log 'terminal focused: skipped desktop+sound'
        }
        if (-not $Kind) { $Kind = 'done' }
        $snd = $(if ($SoundFile) { $SoundFile } else { Get-SoundFile $Kind })
        $vol = $(if ($Volume) { $Volume } else { Get-Conf 'sound_volume' '0.6' })
        Invoke-Channels @{ Title = $Title; Body = $Body; NtfyTitle = $Title; Kind = $Kind; Channels = $chans
            Volume = $vol; SoundFile = $snd; Priority = 'default'; Tags = '' }
        return
    }

    if ($env:CLAUDE_NOTIFY -eq '0' -and -not $TestMode) { return }
    if (-not (Test-True (Get-Conf 'enabled' 'true'))) { Write-Log "disabled (enabled=false in $ConfPath)"; return }

    $force = (Test-True $env:CLAUDE_NOTIFY_FORCE)
    $key = ''; $kindV = 'done'; $emoji = ''; $short = ''; $detail = ''; $tags = ''; $prio = 'default'
    $evt = ''; $ntype = ''; $session = ''; $cwd = ''

    if ($TestMode) {
        $force = $true; $evt = 'Test'; $session = 'test'; $cwd = (Get-Location).Path
        switch ($Test) {
            'needs' { $kindV = 'needs'; $emoji = [char]::ConvertFromUtf32(0x1F510); $short = 'test: needs you'; $tags = 'closed_lock_with_key'; $prio = 'high' }
            'error' { $kindV = 'error'; $emoji = [char]::ConvertFromUtf32(0x274C); $short = 'test: error'; $tags = 'x'; $prio = 'high' }
            default { $kindV = 'done'; $emoji = [char]::ConvertFromUtf32(0x2705); $short = 'test: done'; $tags = 'white_check_mark' }
        }
        $detail = 'This is a claude-notify test alert.'
    } else {
        try {
            [Console]::InputEncoding = [Text.Encoding]::UTF8
            $raw = [Console]::In.ReadToEnd()
            $j = $raw | ConvertFrom-Json
        } catch { return }
        if ($null -eq $j) { return }
        $evt = Get-Prop $j 'hook_event_name'
        $ntype = Get-Prop $j 'notification_type'
        $session = Get-Prop $j 'session_id'
        $cwd = Get-Prop $j 'cwd'
        $message = Get-Prop $j 'message'

        switch ($evt) {
            'UserPromptSubmit' {
                if ($session) {
                    New-Item -ItemType Directory -Force -Path $StateDir | Out-Null
                    Set-Content -LiteralPath (Join-Path $StateDir "$session.start") -Value (Get-Now)
                }
                return
            }
            'Notification' {
                switch ($ntype) {
                    'permission_prompt' { $key = 'permission'; $kindV = 'needs'; $emoji = [char]::ConvertFromUtf32(0x1F510); $short = 'needs permission'; $detail = $message; $tags = 'closed_lock_with_key'; $prio = 'high' }
                    'idle_prompt' { $key = 'idle'; $kindV = 'needs'; $emoji = [char]::ConvertFromUtf32(0x23F3); $short = 'waiting for your input'; $detail = $message; $tags = 'hourglass_flowing_sand'; $prio = 'high' }
                    'elicitation_dialog' { $key = 'elicitation'; $kindV = 'needs'; $emoji = [char]::ConvertFromUtf32(0x1F4DD); $short = 'MCP server needs input'; $detail = $message; $tags = 'memo'; $prio = 'high' }
                    default { return }
                }
            }
            'PreToolUse' {
                if ((Get-Prop $j 'tool_name') -ne 'AskUserQuestion') { return }
                $q = ''
                try { $q = [string]$j.tool_input.questions[0].question } catch {}
                $key = 'question'; $kindV = 'needs'; $emoji = [char]::ConvertFromUtf32(0x2753); $short = 'Claude asked a question'; $detail = $q; $tags = 'question'; $prio = 'high'
            }
            'Stop' {
                if ($j.stop_hook_active -eq $true) { return }
                $key = 'stop'; $kindV = 'done'; $emoji = [char]::ConvertFromUtf32(0x2705); $short = 'done'; $tags = 'white_check_mark'
                $detail = Limit-Text (Get-Prop $j 'last_assistant_message') ([int](Get-Conf 'summary_chars' '150'))
            }
            'StopFailure' {
                $err = Get-Prop $j 'error'; if (-not $err) { $err = 'API error' }
                $key = 'failure'; $kindV = 'error'; $emoji = [char]::ConvertFromUtf32(0x274C); $short = "stopped ($err)"; $tags = 'x'; $prio = 'high'
                $detail = Limit-Text (Get-Prop $j 'last_assistant_message') 150
            }
            'SessionEnd' {
                if ($session) { Remove-Item -LiteralPath (Join-Path $StateDir "$session.start"), (Join-Path $StateDir "$session.last") -Force -ErrorAction SilentlyContinue }
                $r = Get-Prop $j 'reason'
                $key = 'session_end'; $kindV = 'done'; $emoji = [char]::ConvertFromUtf32(0x1F44B); $short = 'session ended'; $tags = 'wave'; $prio = 'low'
                if ($r) { $detail = "reason: $r" }
            }
            default { return }
        }
        $def = $(if ($key -eq 'session_end') { 'false' } else { 'true' })
        if (-not (Test-True (Get-Conf "event_$key" $def))) { Write-Log "$evt/$key`: event disabled"; return }
    }

    $project = $(if ($cwd) { Split-Path -Leaf $cwd } else { 'claude' })
    $chans = New-Object System.Collections.ArrayList
    if (Test-True (Get-Conf 'channel_desktop' 'true')) { [void]$chans.Add('desktop') }
    if (Test-True (Get-Conf 'channel_sound' 'true')) { [void]$chans.Add('sound') }
    if (Test-True (Get-Conf 'channel_ntfy' 'false')) { [void]$chans.Add('ntfy') }

    if (-not $force) {
        $now = Get-Now
        # dedupe (never drop errors)
        $dd = [int](Get-Conf 'dedupe_seconds' '5')
        if ($dd -gt 0 -and $kindV -ne 'error' -and $session) {
            $lastFile = Join-Path $StateDir "$session.last"
            if (Test-Path -LiteralPath $lastFile) {
                $last = [int64](Get-Content -LiteralPath $lastFile -TotalCount 1)
                if (($now - $last) -lt $dd) { Write-Log "$evt`: deduped ($($now - $last)s since last alert)"; return }
            }
        }
        # minimum turn length for Stop
        $min = [int](Get-Conf 'min_turn_seconds' '120')
        $startFile = Join-Path $StateDir "$session.start"
        if ($evt -eq 'Stop' -and $min -gt 0 -and $session -and (Test-Path -LiteralPath $startFile)) {
            $dur = $now - [int64](Get-Content -LiteralPath $startFile -TotalCount 1)
            if ($dur -lt $min) {
                $drop = @((Get-Conf 'min_turn_channels' 'ntfy') -split '[,\s]+' | Where-Object { $_ })
                foreach ($d in $drop) { $chans.Remove($d) }
                Write-Log "Stop: short turn (${dur}s < ${min}s), dropped: $($drop -join ',')"
            }
        }
        if ((Test-True (Get-Conf 'ntfy_only_idle_and_errors' 'false')) -and $key -ne 'idle' -and $kindV -ne 'error') { $chans.Remove('ntfy') }
        if (Test-QuietHours (Get-Conf 'quiet_hours' '')) { $chans.Remove('sound'); Write-Log 'quiet hours: sound muted' }
        if ((Test-True (Get-Conf 'skip_local_when_focused' 'true')) -and ($chans.Contains('desktop') -or $chans.Contains('sound'))) {
            if (Test-TerminalFocused) { $chans.Remove('desktop'); $chans.Remove('sound'); Write-Log 'terminal focused: skipped desktop+sound' }
        }
    }

    $title = "$emoji $project`: $short"
    Write-Log ("{0}{1} [windows] -> '{2}' | {3} | {4}" -f $evt, $(if ($ntype) { "/$ntype" } else { '' }), ($chans -join ' '), $title, $detail)
    if ($chans.Count -eq 0) { return }
    if ($session) {
        New-Item -ItemType Directory -Force -Path $StateDir | Out-Null
        Set-Content -LiteralPath (Join-Path $StateDir "$session.last") -Value (Get-Now)
    }

    $work = @{ Title = $title; Body = $detail; NtfyTitle = "$project`: $short"; Kind = $kindV; Channels = @($chans)
        Volume = (Get-Conf 'sound_volume' '0.6'); SoundFile = (Get-SoundFile $kindV); Priority = $prio; Tags = $tags }

    if ($TestMode) { Invoke-Channels $work; return }

    # Hand the work to a hidden background PowerShell so Claude is not kept waiting
    # on sound playback or the network. Falls back to running inline.
    try {
        New-Item -ItemType Directory -Force -Path $StateDir | Out-Null
        $pf = Join-Path $StateDir ("payload-{0}.json" -f [guid]::NewGuid().ToString('N'))
        [IO.File]::WriteAllText($pf, ($work | ConvertTo-Json -Compress), (New-Object Text.UTF8Encoding $false))
        $exe = Join-Path $PSHOME 'powershell.exe'
        if (-not (Test-Path -LiteralPath $exe)) { $exe = 'powershell.exe' }
        Start-Process -FilePath $exe -WindowStyle Hidden -ArgumentList @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-Payload', "`"$pf`"")
    } catch {
        Invoke-Channels $work
    }
}

try { Main } catch { Write-Log "error: $($_.Exception.Message)" }
exit 0
