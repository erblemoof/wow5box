# Get the WoW password from the registry or prompt for it
param
(
    [switch] $reset
)

$regkey = 'HKCU:\Software\Chorizotarian\Multiboxing\'
Ensure-Path $regkey

$encStr = (get-itemproperty $regkey).WowPassword
if ($reset -or ($encStr -eq $null))
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

$pwd