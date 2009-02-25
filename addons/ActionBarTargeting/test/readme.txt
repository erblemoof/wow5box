Test Setup:
1) Download LUA standalone from http://luabinaries.luaforge.net/download.html
2) [optional] Add LUA bin folder to your path
3) [optional] Create a PowerShell alias lua => lua5.1.exe
4) Run PowerShell or cmd.exe
5) cd to this directory
6) {lua} ActionBarTargetingTests.lua, where {lua} is either the alias from 3 or the full path

Results should look like this:

test> lua .\ActionBarTargetingTests.lua
>>>>>>>>> AbtTests
>>> AbtTests:test_BarPairs
>>> AbtTests:test_CreateFollowMacro
>>> AbtTests:test_CreateHealingTargetMacro
>>> AbtTests:test_CreateMacro
>>> AbtTests:test_CreateOffensiveTargetMacro
>>> AbtTests:test_CreateTargetMainMacro
>>> AbtTests:test_CreateTargetMainTargetMacro
>>> AbtTests:test_FirstIndexOf
>>> AbtTests:test_JoinBarConditions
>>> AbtTests:test_MaxBar
>>> AbtTests:test_PlayerIndex

=========================================================
Success : 100% - 11 / 11