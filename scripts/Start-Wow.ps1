#--------------------------------------------------------------------------------------------------
# Module:
#       Start-Wow.ps1
#
# Description:
#       Launches WoW and passes list of process IDs to AHK
#
#       TRICKY: Don't run as admin or Logitech mouse software won't work.
#
# Author:
#       Chorizotarian
#--------------------------------------------------------------------------------------------------

param (
    $teamId = 0,
    [string] $configPath = 'WowConfig.xml',
    [switch] $reset
)

$configContent = get-content $configPath
$config = [xml] [string]::join("`n", $configContent)

# Get the game command info
$progName = $config.WowConfig.StartCommand.fileName
$progArgs = $config.WowConfig.StartCommand.args

# Get the game instance configs
$gameInstances = @($config.WowConfig.GameInstances.Game)
$password = Get-WowPassword

# Get the team
$teams = @($config.WowConfig.Teams.Team)
if ($teamId -is [int])
{
    $team = $teams[$teamId]
}
else
{
    $team = $teams | where { $_.id.ToLower().StartsWith($teamId) }
}
if ($team -eq $null) { throw "Invalid team ID: $teamId" }

# Create a hashtable for the list of running games, if not already created
if ($reset -or $global:runningGames -eq $null) { $global:runningGames = @{} }

# Win32 constants used below
$gwlStyle = -16                         # GWL_STYLE
$wsThickframe = 0x00040000              # WS_THICKFRAME
$wsCaption = 0x00C00000                 # WS_CAPTION
$swpFramechanged = 0x0020               # SWP_FRAMECHANGED
$wmKeydown = 0x0100                     # WM_KEYDOWN
$wmKeyup = 0x0101                       # WM_KEYUP
$wmChar = 0x0102                        # WM_CHAR

function Send-String([IntPtr] $hWnd, [string] $s)
{
    $s.ToCharArray() | foreach {
        Send-Message $hWnd $wmKeydown $_ > $null
        Send-Message $hWnd $wmChar $_ > $null
        Send-Message $hWnd $wmKeyup $_ > $null
    }
}

# Get screen info
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') > $null
$screens = [System.Windows.Forms.Screen]::AllScreens

# Get WoW password
$password = Get-WowPassword

# Launch game instances
$i = 0
$pids = @()
foreach ($toon in $team.Toon) {
    $game = $gameInstances[$i++]
    "Launching $($toon.name) in $($game.id)..."
   
    # See if the game instance is already running
    $process = $global:runningGames[$game.id]
    if ($process -ne $null)
    {
        if ($process.HasExited) {
            "`tRemoving exited process $($process.Id) from the running list for $($game.id)"
            $global:runningGames[$game.id] = $null
            $process = $null
        }
        else 
        {
            "`tAlready running in process $($process.Id)"
        }
        
        # Only login if the team has changed
        $login = ($global:lastTeamId -ne $team.id)
    }

    # Otherwise launch in a new process
    if ($process -eq $null)
    {
        $process = new-object System.Diagnostics.Process
        $process.StartInfo.Arguments = $progArgs
        $process.StartInfo.CreateNoWindow = $true
        $process.StartInfo.FileName = join-path $game.folder $progName
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.WorkingDirectory = $game.folder
        if (-not $process.Start()) { throw "`tProcess failed to start" }

        $global:runningGames[$game.id] = $process
        "`tStarted in process $($process.Id)"

        # Set window style
        if (-not $process.WaitForInputIdle(10000)) { "`tProcess.WaitForInputIdle timed out" }
        $hWnd = $process.MainWindowHandle
        [IntPtr] $oldStyle = Get-WindowLongPtr $hWnd $gwlStyle
        [IntPtr] $stylesToRemove = -bnot ($wsThickframe -bor $wsCaption)
        [IntPtr] $newStyle = $oldStyle -band $stylesToRemove
        Set-WindowLongPtr $hWnd $gwlStyle $newStyle > $null
        
        # Set window position
        $screen = $screens[$game.monitor]
        $b = $screen.Bounds
        $x = $b.left + $game.left
        $y = $b.top + $game.top
        Set-WindowPos $hWnd $x $y $game.width $game.height $swpFramechanged > $null
        
        # Always login
        $login = $true
    }
    
    # Log in
    if ($login)
    {
        $hWnd = $process.MainWindowHandle
        Send-String $hWnd $toon.account
        Send-String $hWnd "`t"
        Send-String $hWnd $password
        Send-String $hWnd "`n`r"
    }
    
    # Save process ID for AHK
    $pids += $process.Id
}

# Pass comma-separated list of WoW process IDs to AHK
$pids
$pidStr = $pids -join ','
.\Wow.ahk $pidStr $pwd

# Save the team so we can detect changes on subsequent runs
$global:lastTeamId = $team.id
