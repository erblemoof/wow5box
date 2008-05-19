#--------------------------------------------------------------------------------------------------
# Module:
#       Run-Tests.ps1
#
# Description:
#       Runs unit tests
#
# Author:
#       Chorizotarian
#--------------------------------------------------------------------------------------------------

param
(
    $testFiles = '.\*.lua'
)

$lua = 'C:\lua\lua5_1_3\lua5.1.exe'

# run the tests
$resultText = dir $testFiles | foreach {
    &$lua $_.FullName
}

# TEMP: Just print the results & exit
$resultText

if ($false) {

# parse text results
foreach ($line in $resultText) {
    if ($line -match '>>>>>>>>>\s+(?<testClass>\w+)')
    {
        $matches.testClass
    }
}

# print the results all pretty-like

}