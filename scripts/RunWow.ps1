#--------------------------------------------------------------------------------------------------
# Module:
#       RunWow.ps1
#
# Description:
#       Launches WoW and passes list of process IDs to AHK
#
# Author:
#       Chorizotarian
#
#--------------------------------------------------------------------------------------------------

param (
    [int[]] $ids = 1..5,        # list of WoW folder IDs to run
    [switch] $promptPassword    # prompt for password
)

function Join-String([string[]] $strArray, [string] $sep = ' ')
{
    if ($strArray -ne $null) { [string]::Join($sep, $strArray) } else { $null }
}

# Gets the most recent WoW process ID
function Get-LastWowPid
{
    $p = @(get-process -name wow | sort StartTime -descending)
    $p[0].Id
}

function Set-WowPid([int] $id, [int] $wowPid = (Get-LastWowPid))
{
    set-variable "wow$id" $wowPid -scope global
}

function Get-WowPid([int] $id)
{
    $v = @(get-variable -include "wow$id" -scope global)
    if ($v.Length -eq 1)
    {
        $wowPid = $v[0].Value
        $p = @(get-process | where { $_.Id -eq $wowPid })
        if (($p.Length -eq 1) -and ($p[0].Name -eq 'wow')) { $wowPid }
            else { clear-variable "wow$id" -scope global }
    }
}

function Test-Wow([int] $id)
{
    (Get-WowPid $id) -ne $null
}

function Get-WowCount
{
    @(get-process | where { $_.Name -eq 'wow'}).Length
}

# Ensure that the path exists, creating it if necessary
function Ensure-Path($path)
{
    if (-not (test-path $path))
    {
        $parent = (split-path $path)
        Ensure-Path $parent
        mkdir $path
    }
}

# Launch WoW via Maximizer
foreach ($id in $ids) {
    $wowPid = Get-WowPid $id
    if ($wowPid -ne $null) { "WoW $id = $wowPid" }
    else
    {
        "Launching WoW $id ..."
        &"c:\wow$id\Maximizer.exe"
        
        # Wait for wow.exe
        $nWow = Get-WowCount
        $maxWait = [DateTime]::Now + [TimeSpan]::FromSeconds(5)
        $success = $false
        do
        {
            $success = (Get-WowCount -gt $nWow)     # new wow has been launched
            start-sleep -mil 100
        }
        while (-not $success -and ([DateTime]::Now -le $maxWait))
        
        # wait for maximizer to move the window
        if ($success) {
            "`tsuccess"
            Set-WowPid $id
            start-sleep -sec 5
        }
        else { throw "`tfailure" }
    }
}

# Make a comma-separated list of WoW process IDs
$pids = @($ids | foreach { Get-WowPid $_ })
$pids
$pidStr = join-string $pids ','

# Get the WoW password from the registry or prompt for it
$regkey = 'HKCU:\Software\Chorizotarian\Multiboxing\'
Ensure-Path $regkey

$encStr = (get-itemproperty $regkey).WowPassword
if ($promptPassword -or ($secStr -eq $null))
{
    # Read the password securely and write an encrypted version to the registry
    $secStr = read-host 'Enter WoW password' -asSecureString
    $encStr = ConvertFrom-SecureString $secStr
    set-itemproperty -path $regkey -name 'WowPassword' -value $encStr
}

# Covert the password to a regular string
$secStr = ConvertTo-SecureString $encStr
if ($secStr -is [Security.SecureString])
{
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secStr)
    $pwd = [Runtime.InteropServices.Marshal]::PtrToStringUni($ptr)
    if ($ptr -is [IntPtr]) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
}

# Pass data to AHK
.\Wow.ahk $pidStr $pwd