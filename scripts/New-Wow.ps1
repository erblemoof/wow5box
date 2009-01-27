#--------------------------------------------------------------------------------------------------
# Module:
#       New-Wow.ps1
#
# Description:
#       Creates a new copy of World of Warcraft at the specified location. Uses Vista symbolic links
#       (mklink) to minimize file duplication.
#
#       Could probably be modified to run on XP by replacing the mklink reference below with the XP
#       equivalent (linkd?). I don't have an XP install anymore, so I can't test this.
#
# Setup:
#       1) Download and install Windows PowerShell:
#           http://www.microsoft.com/windowsserver2003/technologies/management/powershell/default.mspx
#       2) Run PowerShell as administrator
#       3) Set your script execultion policy to run local scripts without a digital signature:
#           Get-Help About_Signing
#           Set-ExecutionPolicy RemoteSigned
#       4) Copy New-Wow.ps1 to somewhere in your path OR replace "new-wow" in the examples below
#          with the script path.
#
# Examples:
#       Copy default WoW location to c:\wow1:
#           new-wow c:\wow1
#
#       Copy default WoW location to c:\wow1 and c:\wow2:
#           new-wow c:\wow1,c:\wow2
#
#       Copy existing cuctem WoW location c:\wow1 to c:\wow2 and c:\wow3:
#           new-wow c:\wow2,c:\wow3 -sourcePath c:\wow1
#
#       If the script is not in your path:
#           c:\somedir\new-wow.ps1 c:\wow1
#
#       You can also use switches (standard PowerShell functionality):
#           new-wow -path c:\wow1,c:\wow2,c:\wow3 -source c:\oldwow
#
#       Please be careful with -force -- it will automatically delete everything under the destination
#       path:
#           new-wow c:\wow1 -force
#                            ^-- *** deletes c:\wow1 and replaces it with a new copy of WoW! ***
#--------------------------------------------------------------------------------------------------

param
(
    [string[]] $path = $(throw 'Must specify one or more destination paths'),
    [string] $sourcePath = "${env:ProgramFiles(x86)}\World of Warcraft",
    [switch] $force,
    [switch] $repair
)

# validate input parameters
foreach ($p in $path)
{
    if (Test-Path $p)
    {
        if ($force) { remove-item $p -recurse -force } else {
            throw "Destination path already exists: $p"
        }
    }
}
if (-not (Test-Path $sourcePath)) { throw 'Source directory does not exist' }

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

function Join-String([string[]] $stringArray, [string] $separator = ' ')
{
    if ($stringArray -ne $null) { [string]::Join($separator, $stringArray) } else { $null }
}

# Creates a Vista symbolic link by calling cmd.exe mklink
function New-SymbolicLink(
    [string] $link = $(throw 'Must supply a link path'),
    [string] $target = $(throw 'Must supply a target path')
) {
    if (test-path $link) { throw "Link path already exists: $link" }
    if (-not (test-path $target)) { throw "Target does not exist: $target" }

    # If the target is a directory make a directory symlink. Otherwise make a file link
    $d = ""
    if (test-path $target -type Container) { $d = '/d' }

    if ([Environment]::OSVersion.Version.Major -ge 6)
    {
        cmd /c "mklink $d `"$link`" `"$target`"" > $null
    }
    else
    {
        cmd /c "junction $d `"$link`" `"$target`"" > $null
    }
}

# Copy WoW files using relative paths
function Copy-WowFile([string] $relativePath)
{
    if (test-path $relativePath) { throw "Destination path exists: $relativePath" }

    $path = (join-path $sourcePath $relativePath)
    if (-not (test-path $path -type Leaf)) { throw "Invalid source path: $path" }
    
    copy-item $path $relativePath
}

# Link WoW files/folders using relative paths
function New-WowLink([string] $relativePath, [switch] $createDir)
{
    $path = (join-path $sourcePath $relativePath)
    if (-not (test-path $path)) { mkdir $path }
    
    New-SymbolicLink -link $relativePath -target $path
}

#--------------------------------------------------------------------------------------------------
# Script
#--------------------------------------------------------------------------------------------------

# iterate through the list of destination paths
$iPath = 0
foreach ($p in $path)
{
    write-progress 'Creating WoW copies' -status "$p - $($iPath+1)/$($path.Length)" -percentComplete `
        (100 * $iPath / $path.Length)
    
    # Set the working directory to the destination path
    mkdir $p > $null
    push-location $p

    # Copy the WoW launcher directly to avoid Windows explorer sortcut wierdness
    Copy-WowFile Launcher.exe
    
    # Link all of the other binaries except patches, which can be omitted
    get-childitem $sourcePath\* -include *.exe,*.dll -exclude *patch.exe,*-downloader.exe,Launcher.exe |
        foreach { New-WowLink $_.Name }
    
    if (-not $repair)
    {
        # Other linkable dirs
        @( 'Cache', 'Data', 'Interface') | foreach { New-WowLink $_ }
        
        # Optional dirs that might not exist
        @( 'Patches', 'Screenshots' ) | foreach { New-WowLink $_ -createDir }
        
        # Copy the WTF directory (settings)
        $wtf = (join-path $sourcePath WTF)
        copy-item $wtf WTF -recurse
    }

    pop-location
    ++$iPath
}
