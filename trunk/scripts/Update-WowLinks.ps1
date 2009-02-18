#--------------------------------------------------------------------------------------------------
# Module:
#       Update-WowLinks.ps1
#
# Description:
#       Update symbolic links for a given char / realm / game copy
#--------------------------------------------------------------------------------------------------

param
(
    [string[]] $chars = '*',
    [string[]] $wows = @('c:\wow1', 'c:\wow2', 'c:\wow3', 'c:\wow4', 'c:\wow5'),
    [string] $realm = "Kil'jaeden",
    [string] $account = 'JAMIEEI',
    [string] $sourceRoot = 'c:\multiboxing',
    [switch] $create                            # create any missing files
)

function Link-WowItem([string] $src, [string] $dest)
{
    # Create the source file if necessary
    if (-not (test-path $src)) {
        if ($create) { $null > $src } else {
            "`tSource not found: $src"
            return
        }
    }

    # Backup the destination file
    if (test-path $dest) {
        $old = $dest -replace '\.\w+$', '.old'
        copy-item $dest $old -force
        erase $dest > $null
    }
    
    mklink $src $dest > $null
    "`t$dest"
}

foreach ($wow in $wows)
{
    $wowIndex = $wow[-1]

    # Get the character list
    $realmRoot = join-path $wow "WTF\Account\$account\$realm"
    if ($chars.length -eq 1 -and $chars[0] -eq '*') {
        $wowChars = @(dir $realmRoot | foreach { $_.Name })
    } else {
        $wowChars = $chars
    }
    
    foreach ($char in $wowChars) {
        "Updating links for $char..."

        $charRoot = "$realmRoot\$char"

        Link-WowItem "$sourceRoot\config\AddOns$wowIndex.txt" "$charRoot\AddOns.txt"
        Link-WowItem "$sourceRoot\macros\$char.txt" "$charRoot\macros-cache.txt"
    }
}
